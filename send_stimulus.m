function space = send_stimulus(device, Channels, stimulus)

    for channel = 0:Channels - 1

        space = device.GetDataQueueSpace(channel);
        
        while space > 1000
            % Calc Sin-Wave (16 bits) lower bits will be removed according resolution
            sinVal = 30000 * sin(2.0 * (1:5000) * pi / 5000 * (channel + 1));
            unit = [linspace(300000, 300000, 5000) 0];
            zeroVal = 0*(1:1000);
            data = NET.convertArray(sinVal, 'System.Int16');
            
%             if channel ~= 0
%                 data = NET.convertArray(zeroVal, 'System.Int16');
%             end
            
            device.EnqueueData(channel, data);
            space = device.GetDataQueueSpace(channel);
        end
    end
end


