
seizure_freq_all = zeros(21, 1);
phase_times_all = zeros(21,1);

b =   'Baseline - No Stim';
v20 = '2.0V, 1Hz Stimulus';
v25 = '2.5V, 1Hz Stimulus';
v30 = '3.0V, 1Hz Stimulus';
r =   '     Recovery     ';
phase_descriptions_all = [b; v20; r; v25; r; r; r; v30; r; r; r; r; v20; r; v25; r; r; v30; r; r; r];



file_names = ['data0000.mcd'; 'data0001.mcd'; 'data0002.mcd'; 'data0003.mcd'; 'data0004.mcd'; 'data0005.mcd'; 'data0006.mcd'; 'data0007.mcd'; 'data0008.mcd'; 'data0009.mcd'; 'data0010.mcd'; 'data0011.mcd'; 'data0012.mcd'; 'data0013.mcd'; 'data0014.mcd'; 'data0015.mcd'; 'data0016.mcd'; 'data0017.mcd'; 'data0018.mcd'; 'data0019.mcd'; 'data0020.mcd'];




%% Baseline
electrodes_to_look = [73,74,82,83];

data_path = 'C:\Users\Ali\Documents\ISML\MEA Data\20170620_400_1\';
file_name = 'data0000.mcd';
decimator = 100;
sampling_f = 25000/100;

for i = 11:21

    d0 = import_mcd(data_path, file_names(i,:), decimator, electrodes_to_look);
    [r,c] = size(d0);

    h = figure('units','normalized','outerposition',[0 0 1 1]);
    set(h, 'Visible', 'off');

    if i == 1
    [rew, flt, n_seizures] = analyze_and_plot(d0(:,118600:c), 10, 30, 2, 0.3, sampling_f);
    else
    [rew, flt, n_seizures] = analyze_and_plot(d0(:,:), 10, 30, 2, 0.3, sampling_f);
    end


    phase_times_all(i) = c/sampling_f;
    seizure_freq_all(i) = (c/sampling_f)/mean(n_seizures);
    tit = [ phase_descriptions_all(i,:) '. ' int2str(mean(n_seizures)) ' seizures in ' int2str((c/sampling_f)) ' seconds (every ' num2str(seizure_freq_all(i)) ' seconds)'];
    %text(0.5, 1,tit,'HorizontalAlignment' ,'center','VerticalAlignment', 'top', 'FontWeight', 'bold')
    suptitle(tit);
    
    saveas(h, ['C:\Users\Ali\Documents\ISML\MEA Data\20170620_400_1\plots\data' num2str(i) '.png']);
end