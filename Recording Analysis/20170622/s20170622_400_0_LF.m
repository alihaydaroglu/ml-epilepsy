file_path = 'C:\Users\Ali\Documents\ISML\MEA Data\20170622_400_0\';
lfs_stim_frq = [0,1, 0.5, 0.33, 1, 1, 1, 0.33, 0.33, 0.33, 0, 0];
lfs_file_num = [33,34,37,40, 60,62,65,72,74,76, 73,75, 35,74];

%global e64_n_seizures y_scale f_sampling file_path lfs_file_num i decimator electrodes;
e64_n_seizures = zeros(length(lfs_file_num), 1);
trial_length = zeros(length(lfs_file_num), 1);

i = 1;

electrodes = [46];
y_scale = 25e-05;
decimator = 100;
f_sampling = 25000/decimator;
% 
% start()
% 
% function start()
%     global e64_n_seizures y_scale f_sampling file_path lfs_file_num i decimator electrodes;
%     i = 1;
%     file_name = ['data' num2str(lfs_file_num(i),'%04i') '.mcd'];
%     d0 = import_mcd(file_path, file_name, decimator, electrodes);
%     plot_recording(d0(4,:), f_sampling, y_scale,1, '', '' );
% 
%        
%      popup = uicontrol('Style', 'popup',...
%            'String', {'1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31','32','33','34','35','36','37','38','39','40','41','42','43','44','45'},...
%            'Position', [20 340 100 50],...
%            'Callback', @update_n_seizures);
% end
% 
% function update_n_seizures(source, event)
% 
%     global e64_n_seizures y_scale f_sampling file_path lfs_file_num i decimator electrodes;
%     in = source.Value()
%     e64_n_seizures(i) = in;
%     i = i + 1;
%         
%     file_name = ['data' num2str(lfs_file_num(i),'%04i') '.mcd'];
%     d0 = import_mcd(file_path, file_name, decimator, electrodes);
%     plot_recording(d0(4,:), f_sampling, y_scale,1, '', '' );
%     
% end

%% Find n_seizures
s = 195*f_sampling;
e = 220*f_sampling;

for i = 3%:length(lfs_file_num)
    
    file_name = ['data' num2str(lfs_file_num(i),'%04i') '.mcd'];
    
    d0 = import_mcd(file_path, file_name, decimator, electrodes);
    fprintf('   Measure peaks');
    plot_recording(d0(1,:), f_sampling, y_scale*3,'','0.5 Hz Stimulus', '') 
    %[pks, locs] = findpeaks(-d0(1,:), 'MinPeakProminence', (max(d0) - min(d0))/2);
    %findpeaks(d0(1,:), 'MinPeakProminence', (max(d0) - min(d0))/2);
    %e64_n_seizures(i) = length(pks);
    trial_length(i) = length(d0) / f_sampling;
    fprintf('   Done\n')
    
    %plot_special(d0(1:3,:), d0(4:6,:), f_sampling, y_scale, 'Seizure Propagation in 2 Regions with High K/Low Mg Model')
    
end

%% Analyze

s0 = [];
s3 = [];
s5 = [];
s1 = [] ;
s2 = [];

for i = 1:length(lfs_stim_frq)
    if lfs_stim_frq(i) == 0
        s0 = [s0 100*e64_n_seizures(i)/trial_length(i)];
    end
    if lfs_stim_frq(i) == 0.33
        s3 = [s3 100*e64_n_seizures(i)/trial_length(i)];
    end
    if lfs_stim_frq(i) == 0.5
        s5 = [s5 100*e64_n_seizures(i)/trial_length(i)];
    end
    if lfs_stim_frq(i) == 1
        s1 = [s1 100*e64_n_seizures(i)/trial_length(i)];
    end
    if lfs_stim_frq(i) == 2
        s2 = [s2 100*e64_n_seizures(i)/trial_length(i)];
    end
end
bar(categorical([0, 0.33, 0.5, 1, 2]), [mean(s0), mean(s3), mean(s5), mean(s1), mean(s2)], 'b');
   

%scatter(lfs_stim_frq, e64_n_seizures./trial_length,'filled')
xlabel("Stimulation Frequency (Hz)")
ylabel("Seizures per 100 Seconds")
title("Stimulation Frequency and Seizure Frequency for one slice")
