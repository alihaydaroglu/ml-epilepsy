file_path = 'E:\MEA Data\20170623_400_1\';
lfs_stim_frq = [ 1, 0, 1, 0, 1, 0,0.5, 0,0.5, 0,0.5, 0,0.33, 0,0.33, 0,0.33, 0, 2, 0, 2];
lfs_file_num = [31,32,33,34,35,36, 37,38, 39,40, 41,42,  43,44,  45,46,  47,48,49,50,51];

%global e64_n_seizures y_scale f_sampling file_path lfs_file_num i decimator electrodes;
e64_n_seizures = zeros(length(lfs_file_num), 1);
trial_length = zeros(length(lfs_file_num), 1);

i = 1;

electrodes = [64]
y_scale = 25e-05;
decimator = 100;
f_sampling = 25000/decimator;
%% Find n_seizures
s = 195*f_sampling;
e = 220*f_sampling;

for i = 1%:length(lfs_file_num)
    i
    file_name = ['data' num2str(lfs_file_num(i),'%04i') '.mcd'];
    
    d0 = import_mcd(file_path, file_name, decimator, electrodes);
    fprintf('   Measure peaks');
    plot_recording(d0(1,:), f_sampling, y_scale,1, '', '' ) 
    %[pks, locs] = findpeaks(-d0(1,:), 'MinPeakProminence', (max(d0) - min(d0))/2);
    %findpeaks(-d0(1,:), 'MinPeakProminence', (max(d0) - min(d0))/2);
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

for i = 1:len(lfs_stim_frq)
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
bar([0, 0.33, 0.5, 1, 1], [s0, s3, s5, s1, s2]);
   

%scatter(lfs_stim_frq, e64_n_seizures./trial_length,'filled')
xlabel("Stimulation Frequency (Hz)")
ylabel("Seizures per 100 Seconds")
title("Stimulation Frequency and Seizure Frequency for one slice")
