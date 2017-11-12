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
cleanupObj = onCleanup(@()mea_cleanup(mea));
mea.SendStop();
[status,hwchannels]=mea.HWInfo().GetNumberOfHWADCChannels();
status = mea.SetNumberOfChannels(hwchannels);
[status, analogchannels, digitalchannels, checksumchannels, timestampchannels, channelsinblock] = mea.GetChannelLayout(0);
mea.SetSampleRate(50000, 1, 0);
mea.SetSelectedChannels(channelsinblock, 50000, 5000, Mcs.Usb.SampleSizeNet.SampleSize16Unsigned, channelsinblock);
mea.StartDacq();


% Setup STG Parameters
stg.SetVoltageMode();
stg.EnableContinousMode();
stg.SetOutputRate(50000);
dwMemory = stg.GetTotalMemory();            % obtain total memory available
ntrigger = stg.GetNumberOfTriggerInputs();  % obtain number of triggers in this STG
stgTriggercapacity = NET.createArray('System.UInt32', ntrigger);
for i = 1:ntrigger
    stgTriggercapacity(i) = 50000;
end
stg.SetCapacity(stgTriggercapacity);            % setup the STG
channelmap = NET.createArray('System.UInt32', ntrigger);
syncoutmap = NET.createArray('System.UInt32', ntrigger);
digoutmap = NET.createArray('System.UInt32', ntrigger);
autostart = NET.createArray('System.UInt32', ntrigger);
callbackThreshold = NET.createArray('System.UInt32', ntrigger);
for i = 1:ntrigger
    channelmap(i) = 0;
    syncoutmap(i) = 0;
    digoutmap(i) = 0;
    autostart(i) = 0;
    callbackThreshold(i) = 0;
end
Channels = 8;
channelmap(1) = 2^(Channels)-1; % assign all channels to trigger 1
syncoutmap(1) = 0;   % No Syncout
autostart(1) = 0;
callbackThreshold(1) = 50; % 50% of buffer size
stg.SetupTrigger(channelmap, syncoutmap, digoutmap, autostart, callbackThreshold);
stg.StartLoop();
pause(1)
stg.SendStart(1);

%% Online signal processing

% Unused for now. Tried the built-in decimate function to lower the
% sampling rate of the streamed data by a factor of 100x (= decimator). It
% took too long, probably because of some mistake I made. Things work fine
% with the oversampled datac
decimator = 1; 
lo_freq = 10;
hi_freq = 30;
sampling_freq = 5e+04 / decimator;

Wn = [1 100] / ( sampling_freq / 2);
[b, a] = butter(2, Wn, 'bandpass');
p_lfp = zeros(channelsinblock,1);
st = rr;


while(rr - st < 1)
    rr = rr + 1    
    % Data Collection
    time_window = 500;
    decimated_t = time_window / decimator;
    run_time = 2000;
    rew_resolution = 250;
    data_all = zeros(channelsinblock, time_window * run_time);
    data_flt = zeros(channelsinblock, time_window * run_time);
    rewd_all = zeros(channelsinblock, time_window * run_time / rew_resolution);
    %h = figure;
    n = 0;
    sizes = zeros(channelsinblock, run_time);
    
    while n < run_time
        
         if n > 3 && max(data_flt(40,(n-1) * length(d_flt) : n * length(d_flt))) > 100
            %SendStreamingData(stg, 8);

            %Marker to see where we give stimulus command
            data_all(:, n*time_window) = -1000000;
            fprintf("STIMULUS! %d\n", n)
            
            %actually send the stimulus
            for i = 1:15
            send_stimulus(stg,8,0);
            end
            
            
         end
        i = 0;
        while i < channelsinblock - 1
            try
                frames_available = mea.ChannelBlock_AvailFrames(i);
                if frames_available >= time_window
                    
                    
                    
                    [data, read] = mea.ChannelBlock_ReadFramesUI16(i, time_window);
                    d = double(data) - 32768;
                    
                   
                    sizes(i+1,n+1) = length(d);
                    if sizes(i+1, n+1) ~= time_window
                        d = linspace(0,0,time_window);
                        d_flt = d;
                    end
                    d_flt = filtfilt(b,a,d);
                  
                    data_all(i+1, n * length(d_flt) + 1 : (n+1) * length(d_flt)) = d;
                    data_flt(i+1, n * length(d_flt) + 1 : (n+1) * length(d_flt)) = d_flt;
                    %x = zeros(100000,10000);
                    
                    
                    [r, p_lfp(i+1)] = get_frame_reward(d_flt, 0.3, p_lfp(i+1));
                    rewd_all(i+1, n * length(r) + 1 : (n + 1) * length(r)) = r;
                    
                    
    %                 if (i == 8) && (abs(mean(single(data))) > 700)
    %                     plot(single(data) - 32768)
    %                     axis([0 5000 -800 800])
    %                     savefig(h, ['C:\Users\Ali\Documents\ISML\MEA Data\Testing\spike' int2str(n) '.fig'])
    %                     fprintf('saved')
    %                     %SendSltreamingData(stg);
    %                 end



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
   

    
end
%Saving File
fprintf('Save File');
filename = ['C:\Users\Ali\Documents\ISML\MEA Data\20170623_400_0\run' int2str(rr) '.mat'];
save(filename, 'data_all', 'data_flt', 'rewd_all');
plot_mea(data_all, data_flt, rewd_all, 50000,40:44);
clean_stop(mea,stg);

