file_path = 'D:\MEA Data\20170623_400_1\';
io_intensity = [0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4];
io_file_num = [21, 22, 23, 24, 25, 27, 28,29];
y_scale = 25e-04;
decimator = 100;
f_sampling = 25000/decimator;

electrodes_to_look = [76]%, 15, 16, 17, 24,25,26];

data = zeros(length(io_intensity), 1.5*f_sampling);
peaks = zeros(length(io_intensity), 2);

for i = 1:length(io_file_num)
    
    file_name = ['data' num2str(io_file_num(i),'%04i') '.mcd'];
    
    d0 = import_mcd(file_path, file_name, decimator, electrodes_to_look);
    
    data(i,:) = d0(1,1:1.5*f_sampling);
    
    [pks, locs] = findpeaks(data(i,:), 'MinPeakProminence', y_scale / 10);
    if length(pks) < 1
        [pks, locs] = findpeaks(-data(i,:), 'MinPeakProminence', y_scale / 10)
        pks = - pks;
    end
    peaks(i, :) = [locs(1), pks(1)];
    
    
end

plot_recording(data, f_sampling, y_scale, io_intensity, 'IO Response', 'Voltage: ', 'IO', peaks);

    