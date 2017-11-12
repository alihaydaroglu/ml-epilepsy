
Channels = 8;

dll = NET.addAssembly([pwd '\mcs\McsUsbNet.dll']);
import Mcs.Usb.*

deviceList = CMcsUsbListNet();
deviceList.Initialize(DeviceEnumNet.MCS_STG_DEVICE);

fprintf('Found %d STGs\n', deviceList.GetNumberOfDevices());


for i=1:deviceList.GetNumberOfDevices()
   SerialNumber = char(deviceList.GetUsbListEntry(i-1).SerialNumber);
   fprintf('Serial Number: %s\n', SerialNumber);
end

device = CStg200xStreamingNet(50000);
device.Connect(deviceList.GetUsbListEntry(0));

device.SetVoltageMode();

device.EnableContinousMode();
device.SetOutputRate(50000);

dwMemory = device.GetTotalMemory();            % obtain total memory available

ntrigger = device.GetNumberOfTriggerInputs();  % obtain number of triggers in this STG

stgTriggercapacity = NET.createArray('System.UInt32', ntrigger);
for i = 1:ntrigger
    stgTriggercapacity(i) = 50000;
end
device.SetCapacity(stgTriggercapacity);            % setup the STG

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

channelmap(1) = 2^(Channels)-1; % assign all channels to trigger 1
syncoutmap(1) = 0;   % No Syncout
autostart(1) = 0;
callbackThreshold(1) = 50; % 50% of buffer size

device.SetupTrigger(channelmap, syncoutmap, digoutmap, autostart, callbackThreshold);


device.StartLoop();

pause(1)

device.SendStart(1);

for i = 1:15
    %SendStreamingData(device, Channels); % as long as one likes
    send_stimulus(device, Channels, 0)
    pause(0.01);
end

device.SendStop(1);
device.StopLoop();


device.Disconnect();

%delete(deviceList);
%delete(device);




function space = SendStreamingData(device, Channels)

    for channel = 0 : Channels - 1

        space = device.GetDataQueueSpace(channel);
        
        while space > 1000
            % Calc Sin-Wave (16 bits) lower bits will be removed according resolution
            sinVal = 30000 * sin(2.0 * (1:1000) * pi / 1000 * (channel + 1));
            data = NET.convertArray(sinVal, 'System.Int16');
            device.EnqueueData(channel, data);
            space = device.GetDataQueueSpace(channel);
        end
    end
end
