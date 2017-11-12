file_path = 'E:\MEA Data\20170710_400_2\';
io_intensity = [0.5, 0.5, 1, 1, 1, 1.5, 1.5, 1.5, 2, 2, 2, 2.5, 2.5, 2.5, 3, 3, 3, 3.5, 3.5, 3.5, 4, 4, 4, 4.5, 4.5 ,4.5, 5,5];
io_file_num = 16:16 + length(io_intensity) - 1;
y_scale = 10e-04;
decimator = 100;
f_sampling = 25000/decimator;
time = 1;
electrodes_to_look = [47]%, 15, 16, 17, 24,25,26];

data = zeros(length(io_intensity), time*f_sampling);
peaks = zeros(length(io_intensity), 2);

for i = 1:length(io_file_num)
    
    file_name = ['data' num2str(io_file_num(i),'%04i') '.mcd'];
    
    d0 = import_mcd(file_path, file_name, decimator, electrodes_to_look);
    
    data(i,:) = d0(1,1:time*f_sampling);
    
    [pks, locs] = findpeaks(data(i,:), 'MinPeakProminence', y_scale / 10);
    if length(pks) < 1
        [pks, locs] = findpeaks(-data(i,:), 'MinPeakProminence', y_scale / 10)
        pks = - pks;
    end
    if length(locs) > 0
        peaks(i, :) = [locs(1), pks(1)];
       
    else
        peaks(i, :) = [NaN, NaN];
    end
    
end

plot_recording(data, f_sampling, y_scale*3, io_intensity, 'IO Response of 20170710\_400\_2', 'Voltage: ', 'IO', peaks);

%% Plot IO curve
figure;
i = 0;
ios = linspace(0.5,5,10)
resp = zeros(length(ios));
errs = zeros(length(ios));
for i = 1:length(ios)
    k = find(io_intensity == ios(i));
    sum = 0;
    for j = 1:length(k)
        sum = sum + peaks

