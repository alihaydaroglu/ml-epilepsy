% Function to set up the connection between the PC and the two devices,
% which are the USB-ME64 and STG4004 in this case. Returns two device
% objects with ready connections if it is succesful. Will throw an error if
% either of the devices has a non-zero status. Typically 'device is locked'
% error can be fixed by running the clean_stop function or restarting
% devices.

function [stg mea] = connect_old()

    % Import DLL - change path if necessary!
    assembly = NET.addAssembly([pwd '\mcs\McsUsbNet.dll']);
    import Mcs.Usb.*

    % Create Device Objects - these work for USB-ME64 and STG4004
    stg = CStg200xStreamingNet(45000);
    mea = Mcs.Usb.CMeaUSBDeviceNet();
    
    %Expected serial numbers - change for new devices!
    stg_serial = '40080';
    mea_serial = '00069';

    % Attempt to Find Devices 
    device_list = CMcsUsbListNet();
    device_list.Initialize(DeviceEnumNet.MCS_DEVICE_ANY);
    device_list.Initialize(DeviceEnumNet.MCS_DEVICE_ANY);
    n_devices = device_list.GetNumberOfDevices();

    if n_devices < 2
        error('Only Found %d Devices. %s \n', n_devices, char(device_list.GetUsbListEntry(0).SerialNumber))
        return
    end
    
    fprintf('Found %d devices \n', n_devices)
    
    % Determine which device ID corresponds to which device
    for i = 1:n_devices
       serial_num = char(device_list.GetUsbListEntry(i-1).SerialNumber);
       fprintf('Serial Number for device %d: %s\n', i, serial_num);
       
       if serial_num == stg_serial
           stg_id = i - 1;
       
       elseif (serial_num == mea_serial)
           mea_id = i - 1;
       end          
    end 
    
    % Get the status of the devices - both must be 0
    stg_status = stg.Connect(device_list.GetUsbListEntry(stg_id));
    mea_status = mea.Connect(device_list.GetUsbListEntry(mea_id));

    % For now, need to get both devices to connect to continue
    % If it fails, throw and error
    if (stg_status == 0) && (mea_status == 0)
        fprintf('Both Connections OK \n')
    else
        mea_error = CMcsUsbNet.GetErrorText(mea_status);
        stg_error = CMcsUsbNet.GetErrorText(stg_status);
        stg.Disconnect();
        mea.Disconnect();
        disp(mea_error)
        disp(stg_error)
        error('Could not connect. \n    MEA Status: %d \n    STG Status: %d', mea_status, stg_status)
    
    end
end