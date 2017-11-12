function best_model = train_2class(data_path, file_num, electrodes, decimator)

PRELABELLED = 1;
DEBUG = 0;
SMALL_FTR = 1;

%% ONE CLASS PRE-RUN %%
%use first file as baseline
baseline_file_num = char(file_num (1));
electrode = electrodes(1);

model_file = [data_path 'oneclassmodel-e' num2str(electrode,'%02d') '.mat'];
twoclass_file = [data_path 'twoclassmodel-e' num2str(electrode,'%02d') '.mat'];
e = 1;

%[t, d, pl] = apply_1class(model_file, data_path, char(file_num(1)), electrode);
%% Annotation of Seizures %%
if PRELABELLED == 0
    
    for f = 1:length(file_num)
        train_1class( data_path, baseline_file_num, electrode);
        fig_a = figure;
        [t, d, pl] = apply_1class(model_file, data_path, char(file_num(f)), electrode);
        f_sampling = 1/(t(2)-t(1));
        fc = [55 65];
        [b,a] = butter(10,fc/(f_sampling/2), 'stop');
        d_filt = d;%filter(b,a,d);

        min_separation = floor(0.1 * f_sampling);
        non_baseline = pl < 0.3;
        non_baseline = ~bwareaopen(~non_baseline, min_separation);
        [labelled_regions, n_regions] = bwlabel(non_baseline);
        plot(t,labelled_regions)
        uiwait(fig_a);
        seizures = zeros(2);
        s = 1;
        for i = 1:n_regions
            n_ins = 2;
            ind = find(labelled_regions == i);
            start = ind(1) - floor(f_sampling*0.5);
            fin = ind(1) + floor(f_sampling*3);
            if start < 1, start = 1; end
            if fin > length(d), fin = length(d); end
            if fin < ind(length(ind)), fin = ind(length(ind)); n_ins = 10; end

            h = figure('pos',[50 200 1500 600]);
            yyaxis left
            plot(t(start:fin), d_filt(start:fin))

            xlim([t(start), t(fin)]);
            ylim([-8000 8000]);
            yyaxis right
            plot(t(start:fin), labelled_regions(start:fin) ~= 0);
            ylim ([-0.5 1.5])
            [x,y] = ginput(n_ins);
            if length(x) == 2
                seizures(s,:) = x;
                s = s + 1;
            end
            x = [];
            close(h);

        end
        total_time = t(fin)-t(start);
        save([data_path 'szr-'  'e' num2str(electrodes(e),'%02d') '-' char(file_num(f))], 'seizures', 'total_time');
    end
end
%% TWO CLASS %%
%% Create Labels
labels = zeros(length(file_num), 100);
f = 1;
e = 1;
% for f = 1:length(file_num)   
% 
f_sampling = 10000 %25000/decimator;
% file_name = ['data' num2str(file_num(f), '%04i') '.mcd'];


%% Read and ML

d = load([data_path char(file_num(f))]);
data = d.data;
dddd = save_features(data_path, 'eatures', electrodes, decimator, SMALL_FTR, data );
szrs = load([data_path 'szr-' 'e' num2str(electrode,'%02d') '-' char(file_num(f))]);
szrs_file = zeros(1,2);
arts_file = zeros(1,2);
s = 1;
a = 1;
for i = 1:length(szrs.seizures)
    if szrs.seizures(i,1) < szrs.seizures(i,2)
        i
        szrs_file(s,:) = szrs.seizures(i,:);
        s = s + 1;  
    else 
        arts_file(a,:) = [szrs.seizures(i,2), szrs.seizures(i,1)];
        a = a + 1;
    end
end


data_labels = zeros(size(data,2),1);
for i = 1:size(szrs_file,1)
    data_labels(floor(szrs_file(i,1)*f_sampling):floor(szrs_file(i,2)*f_sampling)) = 1;
end

feature_path = [data_path 'edm-features-e' num2str(electrodes(e), '%02i') '.mat'];
features = load(feature_path);
[feature_set, mu, sigma] = zscore(features.se_concat);
n_szrs_file = size(szrs_file,1);

n_cross_validations = 4;
blob_size = floor(n_szrs_file/n_cross_validations);


% 
cs = [0.1, 1, 10, 100, 500, 1000, 1500, 2000];
gs = [0.00001, 0.0001, 0.001, 0.01, 0.025, 0.05, 0.1, 0.5];

% cs = [7500, 10000, 15000]
% gs = [0.00075, 0.001, 0.0025, 0.005]

% cs = 10000;
% gs = 0.001;


acc_all = zeros(length(cs), length(gs));
sen_all = zeros(length(cs), length(gs));
spc_all = zeros(length(cs), length(gs));
prc_all = zeros(length(cs), length(gs));

max_samples = 10000;

%Random sampling stays same over different parameters
rand_train = zeros(n_cross_validations, length(data_labels));
rand_hold = zeros(n_cross_validations, length(data_labels));

max_acc = 0;
best_model = 0;
for c = 1:length(cs)
    for g = 1:length(gs)
        
        fprintf(['\n \n ############### Testing c: ' num2str(c) ' g: ' num2str(g) '############## \n\n'])
        
        acc_trial = zeros(n_cross_validations,1);
        sen_trial = zeros(n_cross_validations,1);
        spc_trial = zeros(n_cross_validations,1);
        prc_trial = zeros(n_cross_validations,1);
        for i = 1:n_cross_validations
            
            holdout_start = floor(szrs_file((i-1)*blob_size+1,1) * f_sampling);
            holdout_end = floor(szrs_file((i)*blob_size + 1, 1) * f_sampling);
            if holdout_end > size(data_labels,1)
                holdout_end = size(data_labels,1)
            end
            
            
            train1_start = 1;
            train1_end = holdout_start - 1;
            train2_start = holdout_end + 1;
            train2_end = size(feature_set,1);

            holdout_ftr = feature_set(holdout_start:holdout_end, :);
            holdout_lbl = data_labels(holdout_start:holdout_end);
            
            
            if train1_end <= train1_end
                train_ftr = feature_set(train2_start:train2_end, :);
                train_lbl = data_labels(train2_start:train2_end);
            elseif (train2_start >= length(data_labels))
                train_ftr = feature_set(train1_start:train1_end);
                train_lbl = data_labels(train2_start:train2_end);
            else
                train_ftr = [feature_set(train1_start:train1_end); feature_set(train2_start:train2_end)];
                train_lbl = [data_labels(train1_start:train1_end); data_labels(train2_start:train2_end)];
            end

            if c == 1 && g == 1
                
                rand_train(i,1:size(train_lbl,1)) = randperm(size(train_lbl,1));
                rand_hold(i,1:size(holdout_lbl,1)) = randperm(size(holdout_lbl,1));
                
            end
            
            samp_to_use = max_samples;
            if size(train_lbl,1) < max_samples
                samp_to_use = size(train_lbl);
            end
            train_lbl = downsample(double(train_lbl(:, 1)), 100);
            train_ftr = downsample(double(train_ftr(:, :)), 100);
            samp_to_use = max_samples;
            if size(holdout_lbl,1) < max_samples
                samp_to_use = size(holdout_lbl);
            end
            holdout_lbl = double(holdout_lbl(rand_hold(i,1:samp_to_use),:));
            holdout_ftr = double(holdout_ftr(rand_hold(i,1:samp_to_use),:));
            %fprintf("     Training CV %d \n", i);
            libsvm_options = ['-s 0 -t 2 -h 0 -c ' num2str(cs(c)) ' -g ' num2str(gs(g)) ' -q' ];
            
            model = svmtrain(train_lbl, train_ftr, libsvm_options);
            
            
            %% Debug plots
            
            if DEBUG
            
                col = data_labels;
                z = zeros(size(t));



                hold on;
                yyaxis left;
                colormap winter;
                surface([t(train1_start:train1_end); t(train1_start:train1_end)],[d.data(electrode, train1_start:train1_end);d.data(electrode, train1_start:train1_end)],[z(train1_start:train1_end);z(train1_start:train1_end)],[2*col(train1_start:train1_end)';2*col(train1_start:train1_end)'],...
                    'facecol','no',...
                    'edgecol','interp',...
                    'linew',0.5);
                surface([t(train2_start:train2_end);t(train2_start:train2_end)],[d.data(electrode, train2_start:train2_end);d.data(electrode, train2_start:train2_end)],[z(train2_start:train2_end);z(train2_start:train2_end)],[2*col(train2_start:train2_end)';2*col(train2_start:train2_end)'],...
                    'facecol','no',...
                    'edgecol','interp',...
                    'linew',0.5);

                surface([t(holdout_start:holdout_end);t(holdout_start:holdout_end)],[d.data(electrode, holdout_start:holdout_end);d.data(electrode, holdout_start:holdout_end)],[z(holdout_start:holdout_end);z(holdout_start:holdout_end)],[(2*col(holdout_start:holdout_end) + 1)';(2*col(holdout_start:holdout_end) + 1)'],...
                    'facecol','no',...
                    'edgecol','interp',...
                    'linew',0.5);


                hold off
            end          
            %% Validate
            fprintf("CV %d: ", i);
            [predicted_label, accuracy, decision_values] = svmpredict(holdout_lbl, holdout_ftr, model, []);
            
            
            % Analyze result
            REAL_LABEL = holdout_lbl;
            PRED_LABEL = predicted_label;

            false_positives = 0;
            false_negatives = 0;
            true_positives = 0;
            true_negatives = 0;
            real_positives = 0;
            real_negatives = 0;
            detected_positives = 0;
            detected_negatives = 0;

            NUM_INPUT_VECTORS = size(REAL_LABEL,1);
            for j = 1:NUM_INPUT_VECTORS;

                if (REAL_LABEL(j) == 1) 
                    real_positives = real_positives + 1;
                    if (PRED_LABEL(j) == 0) 
                        false_negatives = false_negatives + 1;
                    else 
                        true_positives = true_positives + 1;
                    end
                end

                if (REAL_LABEL(j) == 0) 
                    real_negatives = real_negatives + 1;
                    if (PRED_LABEL(j) == 1) 
                        false_positives = false_positives + 1;
                    else 
                        true_negatives = true_negatives + 1;
                    end
                end

                if (PRED_LABEL(j) == 1) 
                    detected_positives = detected_positives + 1;
                end

                if (PRED_LABEL(j) == 0) 
                    detected_negatives = detected_negatives + 1;
                end

            end
            
            acc_trial(i) = (((true_positives+true_negatives) / NUM_INPUT_VECTORS) * 100);
            sen_trial(i) = ((true_positives/(true_positives+false_negatives))*100);
            spc_trial(i) = ((true_negatives/(true_negatives+false_positives))*100);
            prc_trial(i) = ((true_positives/(true_positives+false_positives))*100);
            

        end
        
        acc_all(c,g) = mean(acc_trial);
        sen_all(c,g) = mean(sen_trial);
        spc_all(c,g) = mean(spc_trial);
        prc_all(c,g) = mean(prc_trial);
        
        fprintf("ACCURACY : %f     SENSITIVITY: %f     SPECIFICITY: %f      PRECISION: %f" , acc_all(c,g), sen_all(c,g), spc_all(c,g), prc_all(c,g));
        
        if  prc_all(c,g) > max_acc %use sensitivity instead of accuracy
            max_acc = prc_all(c,g);
            
            libsvm_options = ['-s 0 -t 2 -h 0 -c ' num2str(cs(c)) ' -g ' num2str(gs(g)) ' -q' ];
            
            best_model = svmtrain(downsample(double(data_labels(:, 1)), 100), downsample(double(feature_set(:, :)), 100), libsvm_options);
            
            save(twoclass_file, 'best_model', 'mu', 'sigma');
            twoclass_file

        end
        
        
    end
end

%% Plot
fig_sweep = figure(9);
s = surf(log(cs)/log(2), log(gs)/log(2), sen_all);
set(s,'edgecolor','none');
xlabel('C');
ylabel('G');
zlabel('Accuracy');

end
%     



