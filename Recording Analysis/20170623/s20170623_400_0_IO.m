file_path = 'D:\MEA Data\20170623_400_0\';
io_intensity = [1, 0.5, 0.5,0.5, .25, .25, .25, 1000, 1000, 1000, 1500, 2000, 2500, 3000, 3500, 4000];
io_file_num = [26,27,28,29,30,31,32,36,37,38,39,46,47,49,50,51];

decimator = 100;
f_sampling = 25000/100;

electrodes_to_look = [14]%, 15, 16, 17, 24,25,26];

data = zeros(length(io_intensity), 3*f_sampling);

for i = 1:length(io_file_num)
    
    file_name = ['data' num2str(io_file_num(i),'%04i') '.mcd'];
    
    d0 = import_mcd(file_path, file_name, decimator, electrodes_to_look);
    
    data(i,:) = d0(1,1:3*f_sampling);
    
end

plot_recording(data, f_sampling, 10e-04, io_file_num, 'IO Response');

    