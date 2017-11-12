%% Connect to Devices and Streaming Setup

% Function to initiate connection with the two 
[stg mea] = connect();

% try
%     [stg, mea, channelsinblock, Channels] = setup(stg, mea);
% catch ME
%     clean_stop(mea, stg);
%     rethrow(ME);
% end

%% Setup section until setup(stg,mea) actually works.

% Setup MEA recording parameters
% cleanupObj = onCleanup(@()mea_cleanup(mea));
% mea.SendStop();
[status,hwchannels]=mea.HWInfo().GetNumberOfHWADCChannels();
status = mea.SetNumberOfChannels(hwchannels);
[status, analogchannels, digitalchannels, checksumchannels, timestampchannels, channelsinblock] = mea.GetChannelLayout(0);
mea.SetSampleRate(50000, 1, 0);
mea.SetSelectedChannels(channelsinblock, 50000, 5000, Mcs.Usb.SampleSizeNet.SampleSize16Unsigned, channelsinblock);
mea.StartDacq();

%% Online signal processing


decimator = 1; 
lo_freq = 5;
hi_freq = 10;
sampling_freq = 5e+04 / decimator;

Wn = [lo_freq hi_freq] / ( sampling_freq / 2);
[b, a] = butter(5, Wn, 'bandpass');
p_lfp = zeros(channelsinblock,1);
st = rr;


while(rr - st < 1)
    rr = rr + 1    
    % Data Collection
    time_window = 500;
    decimated_t = time_window / decimator;
    run_time = 100;
    rew_resolution = 100;
    data_all = zeros(channelsinblock, time_window * run_time);
    stim_marker = zeros(channelsinblock, time_window * run_time);
    
    data_flt = zeros(channelsinblock, time_window * run_time);
    rewd_all = zeros(channelsinblock, time_window * run_time / rew_resolution);
    %h = figure;
    n = 0;
    sizes = zeros(channelsinblock, run_time);
    
    while n < run_time
           
         % Send a check pulse and put a marker on stim_marker
         if n == 10
            %SendStreamingData(stg, 8);
            fprintf("STIMULATE!\n")
            stim_marker(:, (n)*time_window) = 1000000;
            for i = 1:15
            send_stimulus(stg,8,0);
            end
         end
        i = 0;
        
        %Loop through 60 channels to get all frames
        while i < channelsinblock - 1
            try
                frames_available = mea.ChannelBlock_AvailFrames(i);
                if frames_available >= time_window
                    
                    
                    
                    [data, read] = mea.ChannelBlock_ReadFramesUI16(i, time_window);
                    d = double(data) - 32768;
                    
                   
                    sizes(i+1,n+1) = length(d);
                    
                    %Use this to catch error (rarely happens, don't know why)
                    if sizes(i+1, n+1) ~= time_window
                        d = linspace(0,0,time_window);
                    end
                    d_flt = filtfilt(b,a,d);
                        
                  
                    data_all(i+1, n * length(d_flt) + 1 : (n+1) * length(d_flt)) = d;
                    data_flt(i+1, n * length(d_flt) + 1 : (n+1) * length(d_flt)) = d_flt;
                    %x = zeros(100000,10000);
                    
                    
                    [r, p_lfp(i+1)] = get_frame_reward(d_flt, 0.2, p_lfp(i+1));
                    rewd_all(i+1, n * length(r) + 1 : (n + 1) * length(r)) = r;
                    
                    i = i + 1;
                end
            catch ME
                fprintf("Error. Disconnecting Devices.")
                 
                
                clean_stop(mea,stg);
                rethrow(ME)
            end


        end
        n = n + 1;
    end
   
    
    %filename = ['C:\Users\Ali\Documents\ISML\MEA Data\20170620_400_2\run' int2str(rr) '.mat'];
    %save(filename, 'data_all', 'data_flt', 'rewd_all');
    
end
plot_mea(data_all, stim_marker, rewd_all, 50000, [24, 22, 20, 19, 21]);
clean_stop(mea,stg);

