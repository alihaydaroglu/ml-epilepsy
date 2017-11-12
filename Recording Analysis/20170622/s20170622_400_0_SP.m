%% Set up input file and set file properties
file_path = 'C:\Users\Ali\Documents\ISML\MEA Data\20170622_400_0\';
lfs_stim_frq = [0,1, 0.5, 0.33, 1, 1, 1, 0.33, 0.33, 0.33, 0, 0];
lfs_file_num = [33,34,37,40, 60,62,65,72,74,76, 73,75, 35,74];

file = 3;

file_name = ['data' num2str(lfs_file_num(file),'%04i') '.mcd'];



global data f_sampling y_scale big_title str len title;

trial_length = zeros(length(lfs_file_num), 1);
electrodes = [46];
y_scale = 50e-05;
decimator = 100;
f_sampling = 25000/decimator;
data = import_mcd(file_path, file_name, decimator, electrodes);

title = ['Spectrogram of Slice with High Inter-Ictal Spiking Under ' num2str(lfs_stim_frq(file)) ' Hz Stimulus'];

str = 80;
len = 60;

plot_spec(data(1,str*f_sampling + 1:(str+len)*f_sampling), f_sampling, y_scale, title)


function plot_spec(d, sample_rate, y_sc, big_title)
%     hold on 
%     subplot(2,1,1);
    [r,c] = size(d)
    t = linspace(0, (1/sample_rate) * c, c);
%     plot(t,d)
%     xlabel('Time (s)')
%     ylabel('Electrode Measurement (V)')
%     axis([0 (1/sample_rate)*c -y_sc y_sc])
%     hold off
%     subplot(2,1,2);
%     
    cla
    yyaxis left
    
    spectrogram(d,128,120,256,sample_rate,'yaxis'); 
    caxis([-160 -80])
    ylim([0 80])
    hold on
    yyaxis right
    plot(t,d, '-k', 'LineWidth', 1)
    ylim([-y_sc, y_sc])
    
    hold off
    b1 = uicontrol('Style', 'pushbutton', 'String', 'Next',  'Position', [100 5 50 20],'Callback', @next_frame);
    b2 = uicontrol('Style', 'pushbutton', 'String', 'Previous',  'Position', [200 5 50 20],'Callback', @prev_frame);
    
    title(big_title);
    
end

function next_frame(source, event)
    global data f_sampling y_scale big_title str len title;
    str = str + 3
    plot_spec(data(1,str*f_sampling + 1:(str+len)*f_sampling), f_sampling, y_scale, title)
end


function prev_frame(source, event)
    global data f_sampling y_scale big_title str len title;
    str = str - 3
    plot_spec(data(1,str*f_sampling + 1:(str+len)*f_sampling), f_sampling, y_scale, title)
end
    
