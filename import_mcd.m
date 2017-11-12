function data = import_mcd(datapath, filename, decimator, electrodes_to_look)


    %Set up data files



    [nsresult] = ns_SetLibrary('C:\Users\Ali\Documents\ISML\ALI_USRA17\MatLab\mcs\Matlab-Import-Filter\Matlab_Interface\nsMCDLibrary64.dll');
    [nsresult,info] = ns_GetLibraryInfo();
    [nsresult, dataFile] = ns_OpenFile([datapath filename]);
    [nsresult,info]=ns_GetFileInfo(dataFile);
    [nsresult,entity] = ns_GetEntityInfo(dataFile,7); 
    %should check if this is actually an electrode (7)

    %fprintf("File loaded\n");

    % Collect Data From File
    
    n_samples = entity.ItemCount;
    

    data = zeros(length(electrodes_to_look), n_samples/decimator);

    % Loop through for each electrode
    for n = 1:61
        [nsresult,entity] = ns_GetEntityInfo(dataFile,n);

        % Some are trigger entities, some are electrodes
        if entity.EntityLabel(1:8) == 'elec0001'
            %check the electrode ID
            i = str2num(entity.EntityLabel(26:27));

            %If electrode ID is one that we want to look at
            if ~(isempty(find(electrodes_to_look == i)))
                %[n,i]
                [nsresult,analog] = ns_GetAnalogInfo(dataFile,n);
                [nsresult,count,d]=ns_GetAnalogData(dataFile,n,1,n_samples);
                d = double(d.');
                % Decimate because our data is oversampled
                decimated = decimate(d, decimator);
                j = find(electrodes_to_look == i);
                data(j,:) = decimated;
            end
        end
    end


% 
% 
% %% Set up Filter
% lo_freq = 5;
% hi_freq = 30;
% sampling_freq = 25000 / decimator;
% 
% Wn = [lo_freq hi_freq] / ( sampling_freq / 2);
% [b, a] = butter(2, Wn, 'bandpass');
% 
% % y = filter (b, a, data(1,:));
% 
% %% Filter Spikes
% 
% frame_size = 50000;
% 
% D = filter(b,a, data(1,1:frame_size));
% ddata_dt = diff(D);
% 
% %subplot(4,1,1)
% %plot(D)
% 
% cutoff = 12;
% 
% stdev = std(ddata_dt);
% [r,c] = find(abs(ddata_dt) > cutoff*stdev);
% 
% neg_offset = 40;
% pos_offset = 500;
% for i = 1:length(c)
%     neg_ind = c(i) - neg_offset;
%     pos_ind = c(i) + pos_offset;
%     
%     if neg_ind < 2
%         neg_ind = 2;
%     end
%     if pos_ind > length(D)
%         pos_ind = length(D);
%     end
%     %fprintf("Deleting %d to %d \n", neg_ind, pos_ind)
%     D( neg_ind : pos_ind ) = 0; %D(neg_ind - 1);
% end
% 
% [rews, prev_lfp] = get_reward(D, 0.5, 500, 0);
% 
% subplot(1,1,1)
% yyaxis left
% plot(time(1:frame_size), D)
% %axis([0 time(frame_size) -1e-03 1e-03])
% yyaxis right
% plot(rews)
% 
% 
% %% Counting Seizures
% % [pks, locs] = findpeaks(rews, time, 'MinPeakProminence', 50)
% yyaxis left
% plot(time, data(1,:))
% yyaxis right
% scatter(locs, linspace(1,1,length(locs)), 'filled' )
% 
