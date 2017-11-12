%% FLAGS

DEBUG = 1; %no devices, just run with data
SVM = 1; %1 for 2-class, 0 for threshold
SHORT_FTR = 1; % 1: small feature set

%% Set up SVM
model_path = 'C:\Users\Ali\Documents\ISML\MEA Data\20170718_400_0_CL\twoclassmodel-e10.mat'
model_file = load(model_path);
model = model_file.best_model;
mus = model_file.mu;
sigmas = model_file.sigma;

%% Connect to Devices
if ~DEBUG
[stg mea] = connect(f_sampling);
[status, analogchannels, digitalchannels, checksumchannels, timestampchannels, channelsinblock] = mea.GetChannelLayout(0);

else 
in_file = 'C:\Users\Ali\Documents\ISML\MEA Data\20170718_400_0_CL\file6tag28.mat';
file_in = load(in_file);
data_in = file_in.data;
data_point = 1;
end

%% Set Sampling Rate, Save Path, File Tag
f_sampling = 10000;
save_path = 'C:\Users\Ali\Documents\ISML\MEA Data\20170718_400_0_CL\';

file_tag = file_tag + 1; %set this before you run

file_size = 1200; %number of windows saved to each file
n_input_window = 500; %number of samples taken in with each window
n_files = 10; %number of files to record, set to -1 for infinite

fprintf(['Saving ' num2str(file_size * n_input_window / f_sampling) ' second recording files to '])
fprintf(regexprep(save_path, '\\', '\\\\'))
fprintf("\n")

%% Choose Channels of Interest
channels_to_watch = 1:60;%38:43;
n_channels = length(channels_to_watch);


%% Set Filter Coefficients and EDM parameters
n_taps = 255;   

if ~SHORT_FTR
    alphas = [0.1 0.5 1 2 4 6 8 ];%10 12 14 16];
    bands = [ 0.5 1;
                1 1.5;
                1.5 2;
                2 3;
                3 4;
                4 5;
                5 6;
                6 7;
                7 8;
                8 10;
                10 12;
                12 15;
                15 20;
                20 25;];
else
    alphas = [0.1 0.5 1 3 6 8 ];
    bands = [
                1 3;
                3 5;
                5 7;
                7 10;
                10 15
                15 25;];
end


n_bands = length(bands);
n_alphas = length(alphas);

edms = zeros(n_channels, n_bands, n_alphas);
edm_alt = zeros(n_channels, n_bands * n_alphas);
edm_all = zeros(file_size, n_bands * n_alphas);
n_input_buff = n_input_window * 3 + n_taps + 1;
input_window = zeros(n_channels, n_input_window + n_taps + 1);
input_buff = zeros(n_channels,n_input_buff);
filtered_window = zeros(n_channels, n_input_window + n_taps + 1);

data = zeros(n_channels+1, file_size*n_input_window);
stimulus_flag = false;
stimulus_recover = 0;

%% Setup filters

window = kaiser(n_taps+1,0.5);   
filters = zeros(n_bands, n_taps + 1);
for i = 1:n_bands
    fclow = bands(i,1);
    fchigh = bands(i,2);
    filters(i,:) = fir1(n_taps, [fclow fchigh]./(f_sampling/2), window');
end

%% SVM Output Processing

n_mean_window = 2;
svm_threshold = 0.4;
mean_window = zeros(n_mean_window, 1);
mean_point = 1;
mov_mean = 0;

labels_all = zeros(file_size,1);
%% Debug stuff

filt_online = zeros(n_bands,length(data_in));
debug_ftr = zeros(n_bands * n_alphas, length(data_in));
debug_ctr = 1;



%% Data Collection loop
avg = 0;
t = 0;
f = 0;
tic
prevfs = zeros(n_channels, 1);
STOP = false;
while ~STOP%(f < n_files || n_files == -1) %~STOP %
  
    %% Collect data from electrodes (or file if DEBUG == 1)
    t = t + 1;
    
    
    input_window(:, 1:n_taps) = input_window(:, n_input_window - n_taps + 1 : n_input_window);

    
    if DEBUG
        input_window(:, n_taps + 1 : n_input_window + n_taps)  = data_in(:, data_point:data_point+n_input_window-1);
        data_point = data_point + n_input_window;
        data(1:60, (t-1)*n_input_window + 1 : t * n_input_window) = input_window(:, n_taps + 1 : n_input_window + n_taps);
        if data_point + n_input_window > size(data_in,2)
            STOP = true;
        end
    
    else
        i = 1;
        while i < n_channels
            frames_available = mea.ChannelBlock_AvailFrames(channels_to_watch(i));

            if frames_available >= n_input_window
                prevfs(i) = frames_available;
                [d, read] = mea.ChannelBlock_ReadFramesUI16(channels_to_watch(i), n_input_window);
                try
                input_window(i, n_taps + 1 : n_input_window + n_taps)  = double(d) - 32768;
                data(i, (t-1)*n_input_window + 1 : t * n_input_window) = input_window(i, n_taps + 1 : n_input_window + n_taps);
                catch
                    fprintf("size error on %d \n", i);
                end

                i = i + 1;
            end
        end
    
    end
    

    %% Filter and do EDM
        save_debug_ctr = debug_ctr;
    
        for i = 1:n_bands
            for j = 10
                filtered_window(j,:) = filter(filters(i,:), 1, input_window(j, :));
                %filt_online(i,data_point:data_point+n_input_window - 1) = filtered_window(j,n_taps + 2: n_input_window + n_taps + 1);
                %debug_ctr = save_debug_ctr;
                for k = 1:n_input_window
                    
                    %filtered_window(j,k) = dot(input_window(j, k:k+n_taps), filters(i,:)) ;
                    for l = 1:n_alphas
                        %only keep one moment of edm in memory
%                         edms(j,i,l)
%                         alphas(l)
%                         filtered_window(j,k)
%                         
                        
                        edms(j, i, l) = edms(j, i, l) - (1/2^alphas(l)) * ( edms(j, i, l) - abs(filtered_window(j,k+n_taps+1)) );
                        edm_alt(j, ((i-1)*n_alphas)+l) = edms(j, i, l);
                        
                        %debug_ftr( ((i-1)*n_alphas)+l, debug_ctr) = edms(j,i,l);
                       
                        
                        if isnan(edms(j, i, l)) || isinf(edms(j,i,l))
                            fprintf('fuck');
                        end
                        
                    end
                    debug_ctr = debug_ctr + 1;
                end
            end
        end
        %edm_all(t, :) = edm_alt(10,:);

    %% Check if stimulus necessary
    electrode_to_watch = 10;
    
    if SVM
        to_predict = (edm_alt(electrode_to_watch, :) - mus) ./ sigmas;
        [predicted_labels, accuracy, decision_values] = svmpredict(zeros(1,1), double(to_predict), model, '-q');
        
        labels_all(t) = predicted_labels;
        
        
        mean_window(mean_point) = predicted_labels;
        
        mov_mean = mean(mean_window);%mov_mean - mean_window(mod(mean_point, n_mean_window) + 1)/n_mean_window + mean_window(mod(mean_point-1,n_mean_window) + 1)/n_mean_window;
        mean_point = mod(mean_point, n_mean_window) + 1;

        %stim_condition = mov_mean > svm_threshold;
        stim_condition = mov_mean > svm_threshold;
%        stim_condition = stim_condition + (predicted_labels == 1);
%         if stim_condition > 0
%             fprintf("WOWOWOWOWOWOWOWOWOOW");
%         end
        
    else
        stim_condition = (abs(mean(data(elect,:)) - avg) > 3*avg);
        stim_condition = min(input_window(elect,:)) < -1500;
    end

    %% Cooloff Settings
    
    if stim_condition  && stimulus_recover == 0
        stimulus_flag = logical(1);

        stimulus_recover = 25;
        
    end

    if stimulus_recover > 0
        stimulus_recover = stimulus_recover - 1;
    end     


    
    
    %% Stimulate if flag is up!
    if stimulus_flag
        if ~DEBUG
            fwrite(stg,uint8(1));
            fprintf('Stimulation file: %d, progress: %f \n', f, t/file_size);
        end
        data(n_channels+1,  t * n_input_window : t * n_input_window + 999) = ones(1,1000);
        
        stimulus_flag = false;
        %plot(data(17,:))
    end


    %% Save data into file at regular intervals
    if t > file_size - 1
        toc
        tic
        save_file = [save_path 'file' num2str(f) 'tag' num2str(file_tag) '.mat'];
        
        save(save_file, 'data');
        fprintf("Saved \n");
        f = f + 1;
        t = 0;
    end
end
%%
figure(4)
hold on;
yyaxis left;
plot(data(10,:), 'r')
yyaxis right;
plot(data(n_channels+1,:), 'b');
hold off;


%% Plot
% y_scale = 10000;
% %plot(data);
% figure(1)
% for i = 1:25
%     subplot(5,5,i);
%     plot(data(i, :));
%     title(num2str(i));
%     ylim([-y_scale y_scale])
% end
% figure(2)
% for i = 1:25
%     subplot(5,5,i);
%     plot(data(25 + i, :));
%     
%     title(num2str(i+25));
%     ylim([-y_scale y_scale])
% end
% figure(3)
% for i = 1:16
%     subplot(4,4,i);
%     plot(data(50 + i, :));
%     
%     title(num2str(i+50));
%     ylim([-y_scale y_scale])
% end
% 
% 
