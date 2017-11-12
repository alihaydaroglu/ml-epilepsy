
function [stg, mea, channelsinblock, Channels] = setup(stg, mea)
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
end

