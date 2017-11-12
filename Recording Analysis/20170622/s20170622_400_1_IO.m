file_path = 'C:\Users\Ali\Documents\ISML\MEA Data\20170622_400_1\';
io_intensity = [2, 1.5, 1.5, 1.75, 1.25, 1.5, 2.25, 2.5, 1, 0.75, 0.5];
io_file_num = [15, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27];

decimator = 100;
f_sampling = 25000/100;

electrodes_to_look = [63, 64, 65, 66, 67, 73, 74, 75, 76, 77, 84,85,86];


for i = 1%:length(io_file_num)
    
    file_name = ['data' num2str(io_file_num(i),'%04i')];
    
    d0 = import_mcd(file_path, file_name, decimator, electrodes_to_look);
    
    plot_mea(d0, 0, 0, f_sampling, electrodes_to_look);
end
    
    