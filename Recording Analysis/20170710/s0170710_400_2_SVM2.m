model_file = 'E:\MEA Data\20170710_400_2\mdl-f0015-e14.mat';
data_path = 'E:\MEA Data\20170710_400_2\'

file_num = 47:52;
file_labels = {'2.5 V', 'No Stim', '0.9 V', 'No Stim', '0.3 V', 'No Stim'};
electrodes = [14];

f = 1;
e = 1;

for f = 1:length(file_num)
    fig_a = figure;
    [t, d, pl] = apply_model(model_file, data_path, file_num(f), electrodes(e));
    f_sampling = 1/(t(2)-t(1));
    fc = [55 65]
    [b,a] = butter(10,fc/(f_sampling/2), 'stop');
    d_filt = filter(b,a,d);

    min_separation = 0.5 * f_sampling;
    non_baseline = pl < 0.3;
    non_baseline = ~bwareaopen(~non_baseline, min_separation);
    [labelled_regions, n_regions] = bwlabel(non_baseline);
    plot(t,labelled_regions)
    uiwait(fig_a);
    seizures = zeros(2);
    s = 1;
    for i = 1:n_regions
        n_ins = 2;
        ind = find(labelled_regions == i);
        start = ind(1) - f_sampling*0.5;
        fin = ind(1) + f_sampling*3;
        if start < 1, start = 1; end
        if fin > length(d), fin = length(d); end
        if fin < ind(length(ind)), fin = ind(length(ind)); n_ins = 6; end
        
        h = figure('pos',[50 200 1500 600]);
        yyaxis left
        plot(t(start:fin), d_filt(start:fin))

        xlim([t(start), t(fin)])
        
        ylim([-8e-05 8e-05]);
        yyaxis right
        plot(t(start:fin), labelled_regions(start:fin) ~= 0);
        ylim ([-0.5 1.5])
        [x,y] = ginput(n_ins);
        if length(x) == 2
            seizures(s,:) = x;
            s = s + 1;
        end
        if length(x) == 4
            seizures(s,:) = x(1:2);
            seizures(s,:) = x(3:4);
        end
        if length(x) == 6
            seizures(s,:) = x(1:2);
            seizures(s,:) = x(3:4);
            seizures(s,:) = x(5:6);
        end %worst code i've ever written
            
        x = [];
        close(h);

    end
    total_time = t(fin)-t(start);
    save([data_path 'szr-f' num2str(file_num(f), '%04d') '-e' num2str(electrodes(e),'%02d')], 'seizures', 'total_time');
end



%% Graph it out

file_num = [15, 47:52];
file_labels = {'No Stim', '2.5 V', 'No Stim', '0.9 V', 'No Stim', '0.3 V', 'No Stim'};
e = 1;
electrodes = [14];
file_starts = zeros(length(file_num),1);
seizure_freq = zeros(length(file_num),1);
all_szrs = zeros(2);
s = 1;
p = 1;
start_time = 0;
pwrs = [];
pwr_times = [];
avg_dur = zeros(length(file_num),1);
szr_intensities = zeros(1,1);
avg_int = zeros(length(file_num),1);
for f = 1:length(file_num)
    decimator = 50;
    f_sampling = 25000/decimator;
    file_name = ['data' num2str(file_num(f), '%04i') '.mcd'];
    data = import_mcd(data_path, file_name, decimator, [electrodes(e)]);
    
    partition = 1:f_sampling*50:length(data);
    for i = 1:length(partition) - 1
        pwr_times(p) = start_time + partition(i)/f_sampling;
        pwrs(p) = sum( data(partition(i):partition(i+1)).^2);
        p = p + 1;
    end
    szrs = load([data_path 'szr-f' num2str(file_num(f), '%04d') '-e' num2str(electrodes(e),'%02d') '.mat']);
    szr_cnt = 0;
    total_dur = 0;
    total_int = 0;
    for i = 1:length(szrs.seizures)
        if szrs.seizures(i,1) < szrs.seizures(i,2)
            all_szrs(s,:) = start_time + szrs.seizures(i,:);
            szr_intensities(s) = sum( data(floor(szrs.seizures(i,1)*f_sampling) : floor(szrs.seizures(i,2)*f_sampling)).^2);
            s = s + 1;
            szr_cnt = szr_cnt + 1;
            total_dur = total_dur + szrs.seizures(i,2) - szrs.seizures(i,1);
            total_int = total_int + szr_intensities(s-1);
        end
    end
    file_starts(f) = start_time;
    start_time = start_time + length(data)/f_sampling;
    seizure_freq(f) = szr_cnt/(length(data)/f_sampling);
    avg_dur(f) = total_dur/szr_cnt;
    avg_int(f) = total_int/szr_cnt;

end
end_time = start_time;

szr_intervals = zeros(length(all_szrs) - 1, 1);
for i = 1:length(szr_intervals)
    szr_intervals(i) = all_szrs(i + 1,1) - all_szrs(i,1);
end

file_starts_dbl = zeros(length(file_starts)*2,1);
avg_int_dbl = zeros(length(avg_int)*2,1);
avg_dur_dbl = zeros(length(avg_dur)*2,1);
seizure_freq_dbl = zeros(length(seizure_freq)*2,1)
for i = 1:length(avg_int)
    avg_int_dbl(i*2) = avg_int(i);
    avg_int_dbl(i*2-1) = avg_int(i);
    avg_dur_dbl(i*2) = avg_dur(i);
    avg_dur_dbl(i*2-1) = avg_dur(i);
    seizure_freq_dbl(i*2) = seizure_freq(i);
    seizure_freq_dbl(i*2-1) = seizure_freq(i);
end
for i = 1:length(file_starts)-1
    file_starts_dbl(i*2) = file_starts(i+1);
    file_starts_dbl(i*2-1) = file_starts(i);
end
file_starts_dbl(length(file_starts)*2) = end_time;
file_starts_dbl(length(file_starts)*2-1) = file_starts(end);



fig_szr = figure(1);
hold on
yyaxis left;
s1 = scatter(all_szrs(:,1), all_szrs(:,2)-all_szrs(:,1), 'DisplayName','seizure duration');
l1 = plot(file_starts_dbl,avg_dur_dbl, 'b','DisplayName','avg seizure duration');
yyaxis right;
l2 = plot(file_starts_dbl,seizure_freq_dbl, 'DisplayName','avg seizure frequency');
ymax1 = max(seizure_freq) * 1.5;
ylim([0, ymax1]);
for i = 1:length(file_starts)
    plot([file_starts(i), file_starts(i)], [-100 100], '-.', 'DisplayName','')
    text(file_starts(i)+ 50, ymax1*4.5/5, file_labels(i));
end
legend ([s1, l1, l2]);
title("Frequency and Duration Analysis - EC");
hold off

fig_pwr = figure(2);
hold on
yyaxis left
s1 = scatter(all_szrs(:,1), szr_intensities, 'DisplayName','seizure intensity');

l4 = plot(file_starts_dbl,avg_int_dbl,'DisplayName','avg seizure intensity');

ylim([0, max(avg_int)*2.5]);

yyaxis right
l3 = plot(pwr_times, pwrs, 'DisplayName','power');
ymax2 = max(pwrs)/5;
ylim([0, ymax2]);
for i = 1:length(file_starts)
    plot([file_starts(i), file_starts(i)], [-100000 100000], '-.', 'DisplayName','')
    text(file_starts(i) + 50, ymax2*4.5/5, file_labels(i));
end
legend([l3, l4]);
title("Power and Intensity Analysis - EC");
hold off

szr_ec = all_szrs;
szr_dur_ec = all_szrs(:,2)-all_szrs(:,1);
%% EC vs HC


szr_hc = zeros(1,2);
szr_dur_hc = zeros(1,1);

electrodes = [57];
e = 1;
s = 1;
start_time = 0;
for f = 1:length(file_num)
    decimator = 50;
    f_sampling = 25000/decimator;
    file_name = ['data' num2str(file_num(f), '%04i') '.mcd'];
    data = import_mcd(data_path, file_name, decimator, [electrodes(e)]);
    
    szrs = load([data_path 'szr-f' num2str(file_num(f), '%04d') '-e' num2str(electrodes(e),'%02d') '.mat']);
    szr_cnt = 0;
    total_dur = 0;
    total_int = 0;
    for i = 1:length(szrs.seizures)
        if szrs.seizures(i,1) < szrs.seizures(i,2)
            szr_hc(s,:) = start_time + szrs.seizures(i,:);
            s = s + 1;
            szr_cnt = szr_cnt + 1;
        end
    end
    start_time = start_time + length(data)/f_sampling;
end
fig_comp = figure(3);
hold on
sc2 = scatter(szr_hc(:,1), szr_hc(:,2)-szr_hc(:,1), 'b','filled', 'DisplayName','HC seizures')
sc3 = scatter(szr_ec(:,1), szr_ec(:,2)-szr_ec(:,1), 'r', 'filled', 'DisplayName','EC seizures')
for i = 1:size(szr_ec,1)
    plot([szr_ec(:,1) szr_ec(:,1)], [-1000, 1000], '--r', 'LineWidth', 0.1);
end
for i = 1:length(file_starts)
    plot([file_starts(i), file_starts(i)], [-100000 100000], '-.k','LineWidth',1, 'DisplayName','')
    text(file_starts(i) + 50, 1.75, file_labels(i));
end
ylim([0 1.2*max([max(szr_ec(:,2)-szr_ec(:,1)), max(szr_hc(:,2)-szr_hc(:,1))])]);
legend([sc2, sc3]);
hold off