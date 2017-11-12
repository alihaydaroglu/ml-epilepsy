function [ data ] = load_mcd( fp , electrodes, decimator )

%LOAD_MCD: Load MEA data saved as a .mcd file
%   Input arguments:
%       fp: 
%           file path to the .mcd file to load
%           ex: fp = 'C:\Users\Ali\...\data0001.mcd'
%       electrodes: 
%           a vector containing the electrode numbers to be loaded, as
%           labelled on the MEA
%           ex: electrodes = [16, 27, 11, 24, 56];
%       decimator:
%           factor by which you want to decimate (downsample + filter) the
%           data from the electrodes. Necessary to avoid extremely large
%           files, try making this value larger if the program is using too
%           much memory. Must be an integer divisor of the sampling
%           frequency!
%           ex: decimator = 50;
%   Output arguments:
%       data:
%           Raw data from each of the electrodes requested. It is an MxN
%           matrix where M is the number of electrodes requested, and N is 
%           ( n_datapoints / decimator ). The first electrode in
%           the electrodes vector is in data(1,:), second in data(2,:) etc.

    % NS Library Path: Need to set this up while installing! 
    ns_libpath = 'C:\Users\Ali\Documents\ISML\ALI_USRA17\MatLab\mcs\Matlab-Import-Filter\Matlab_Interface\nsMCDLibrary64.dll';

    [nsresult] = ns_SetLibrary(ns_libpath);
    [nsresult,info] = ns_GetLibraryInfo();
    [nsresult, dataFile] = ns_OpenFile(fp);
    [nsresult,info]=ns_GetFileInfo(dataFile);
    [nsresult,entity] = ns_GetEntityInfo(dataFile,7); 
    %should check if this is actually an electrode (7)

    %fprintf("File loaded\n");

    % Collect Data From File
    
    n_samples = entity.ItemCount;
    n_decimated_samples = ceil(n_samples/decimator);
    
    data = zeros(length(electrodes), n_decimated_samples);

    % Loop through for each electrode
    for n = 1:61
        [nsresult,entity] = ns_GetEntityInfo(dataFile,n);

        % Some are trigger entities, some are electrodes
        if entity.EntityLabel(1:8) == 'elec0001'
            %check the electrode ID
            i = str2num(entity.EntityLabel(26:27));

            %If electrode ID is one that we want to look at
            if ~(isempty(find(electrodes == i)))
                %[n,i]
                [nsresult,analog] = ns_GetAnalogInfo(dataFile,n);
                [nsresult,count,d]=ns_GetAnalogData(dataFile,n,1,n_samples);
                d = double(d.');
                % Decimate because our data is oversampled
                decimated = decimate(d, decimator);
                j = find(electrodes == i);
                data(j,:) = decimated;
            end
        end
    end

end

