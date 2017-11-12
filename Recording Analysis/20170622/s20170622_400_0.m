
seizure_freq_all = zeros(21, 1);
phase_times_all = zeros(21,1);

b =   'Baseline - No Stim';
v20 = '2.0V, 1Hz Stimulus';
v25 = '2.5V, 1Hz Stimulus';
v30 = '3.0V, 1Hz Stimulus';
v40 = '4.0V, 1Hz Stimulus';
r =   '          Recovery';
phase_descriptions_all = [b; b; v40; r; r;r];



%file_names = ['data0001.mcd'; 'data0002.mcd'; 'data0003.mcd'; 'data0004.mcd'; 'data0005.mcd'; 'data0006.mcd'; 'data0007.mcd'; 'data0008.mcd'; 'data0009.mcd'; 'data0010.mcd'; 'data0011.mcd'; 'data0012.mcd'; 'data0013.mcd'; 'data0014.mcd'; 'data0015.mcd'; 'data0016.mcd'; 'data0017.mcd'; 'data0018.mcd'; 'data0019.mcd'; 'data0020.mcd'; 'data0021.mcd'; 'data0022.mcd'; 'data0023.mcd'; 'data0024.mcd'; 'data0025.mcd'; 'data0026.mcd'; 'data0027.mcd'; 'data0028.mcd'; 'data0029.mcd'; 'data0030.mcd'; 'data0031.mcd'; 'data0032.mcd'; 'data0033.mcd'; 'data0034.mcd'; 'data0035.mcd'];

file_names = ['data0035.mcd'];



%% Setup
electrodes_to_look = [25,65];
%electrodes_to_look = [44, 23, 34, 24];


data_path = 'C:\Users\Ali\Documents\ISML\MEA Data\20170622_400_0\';
file_name = 'data0000.mcd';
decimator = 100;
sampling_f = 25000/100;


%% Loop All
for i = 1
    d0 = import_mcd(data_path, file_names(i,:), decimator, electrodes_to_look);
    [r,c] = size(d0);

    h = figure('units','normalized','outerposition',[0 0 1 1]);
    %set(h, 'Visible', 'off');
    peak_prom = 1.5;
    %if i == 1
    %[rew, flt, n_seizures] = analyze_and_plot(d0(:,118600:c), 10, 30, 2, 0.3,peak_prom, sampling_f);
    %else
    start = 1; %floor(2*c/3)
    [rew, flt, n_seizures] = analyze_and_plot(d0(:,start:c), 10, 30, 3, 0.3,peak_prom, sampling_f);
    %end


    phase_times_all(i) = c/sampling_f;
    seizure_freq_all(i) = (c/sampling_f)/mean(n_seizures);
    tit = [ phase_descriptions_all(i,:) '. ' int2str(mean(n_seizures)) ' seizures in ' int2str((c/sampling_f)) ' seconds (every ' num2str(seizure_freq_all(i)) ' seconds)'];
    %text(0.5, 1,tit,'HorizontalAlignment' ,'center','VerticalAlignment', 'top', 'FontWeight', 'bold')
    suptitle(tit);
    
    %saveas(h, ['C:\Users\Ali\Documents\ISML\MEA Data\20170622_400_1\plots\data' num2str(i) '.png']);
end