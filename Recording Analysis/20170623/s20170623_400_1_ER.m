file_path = 'D:\MEA Data\20170623_400_1\';
er_intensity = linspace(3,3,9);
er_file_num = [10:18];
y_scale = 7e-04;
decimator = 100;
f_sampling = 25000/decimator;

electrodes_to_look = [63]%, 15, 16, 17, 24,25,26];

data = zeros(length(er_intensity), 0.5*f_sampling);
peaks = zeros(length(er_intensity), 2);

for i = 1:length(er_file_num)
    
    file_name = ['data' num2str(er_file_num(i),'%04i') '.mcd'];
    
    d0 = import_mcd(file_path, file_name, decimator, electrodes_to_look);
    [r,c] = size(d0);
    
    
    data(i,:) = d0(1,c-3*f_sampling+1:c-2.5*f_sampling);
   
    
end

plot_recording(data, f_sampling, y_scale, 1:9, 'Evoked Response', 'Trial:');

    