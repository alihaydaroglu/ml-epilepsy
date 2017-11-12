function [stg, mea] = connect(f_sampling)
stg = serial('COM4','BaudRate',115200);
fclose(instrfind);
% Import DLL - change path if necessary!
assembly = NET.addAssembly(['C:\Users\Ali\Documents\ISML\ALI_USRA17\MatLab\mcs\McsUsbNet.dll']);
import Mcs.Usb.*

mea = Mcs.Usb.CMeaUSBDeviceNet();
stg = serial('COM4','BaudRate',115200);
try
%% STG4004 over Arduino + Serial
    fopen(stg);
%% USB-ME64


    % Create Device Objects - USBME64

    
    %Expected serial numbers - change for new devices!
    mea_serial = '00069';

    % Attempt to Find Devices 
    device_list = CMcsUsbListNet();
    device_list.Initialize(DeviceEnumNet.MCS_DEVICE_ANY);
    device_list.Initialize(DeviceEnumNet.MCS_DEVICE_ANY);
    n_devices = device_list.GetNumberOfDevices();

    if n_devices < 1
        error('Found no devices')
        return
    end
    
    fprintf('Found %d devices \n', n_devices)
    
    % Determine which device ID corresponds to which device
%     for i = 1:n_devices
%        serial_num = char(device_list.GetUsbListEntry(i-1).SerialNumber);
%        fprintf('Serial Number for device %d: %s\n', i, serial_num);
%        
%        if serial_num == stg_serial
%            stg_id = i - 1;
%        
%        elseif (serial_num == mea_serial)
%            mea_id = i - 1;
%        end          
%     end 
    mea_id = 0;
    % Get the status of the devices - must be 0
    mea_status = mea.Connect(device_list.GetUsbListEntry(mea_id));

    % For now, need to get both devices to connect to continue
    % If it fails, throw and error
    if (mea_status == 0)
        fprintf('Both Connections OK \n')
    else
        mea_error = CMcsUsbNet.GetErrorText(mea_status);


        mea.Disconnect();
        disp(mea_error)
        error('Could not connect. MEA Status: %d \n', mea_status)
    
    end
    mea.SendStop();
    [status,hwchannels]=mea.HWInfo().GetNumberOfHWADCChannels();
    status = mea.SetNumberOfChannels(hwchannels);
    [status, analogchannels, digitalchannels, checksumchannels, timestampchannels, channelsinblock] = mea.GetChannelLayout(0);
    mea.SetSampleRate(f_sampling, 1, 0);
    mea.SetSelectedChannels(channelsinblock, f_sampling, 5000, Mcs.Usb.SampleSizeNet.SampleSize16Unsigned, channelsinblock);
    mea.StartDacq();
catch ME
    try 
    clean_stop(mea, stg);
    catch ME2
        fclose(stg);
        delete(stg);
    end
    rethrow(ME);
end
end