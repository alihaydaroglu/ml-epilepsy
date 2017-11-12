
function [rewards, data_flt, n_seizures] = analyze_and_plot(data_all, lo_f, hi_f, order, alpha,peak_prom, sample_f)

    
    resolution = sample_f / 2; %500 ms per reward frame
    [r,c] = size(data_all);
    
    n_seizures = zeros(r,1);
    
    if mod(c,resolution) ~= 0
        data_all = data_all(:,1:(c-mod(c,resolution)));
    end
    
    [r,c] = size(data_all)
    data_flt = filter_all(data_all, lo_f, hi_f, order, sample_f);
    [rewards, lfps] = rewards_all(data_flt, alpha, resolution, 0);
    
    [r1, c1] = size(rewards);
    
    time = linspace(0, c / sample_f, c);
    c/sample_f;
    c;
    time1 = linspace(0, c1 / (sample_f / resolution), c1);
    
    
    
    n_e = r;
    n_p = ceil(sqrt(n_e));
    for i = 1:n_e
        subplot(n_p, n_p, i);
        
        hold on
        yyaxis left;
        plot(time, data_all(i,:), '-b' , 'LineWidth', 0.5)
        %plot(time, data_flt(i,:), '-g', 'LineWidth', 0.1)
        time;

        axis([0 time(c) -0.2e-03 0.2e-03])
        yyaxis right;
        plot(time1, rewards(i,:), '-r');
        [pks, locs] = findpeaks(-rewards(i,:), time1, 'MinPeakProminence', peak_prom);
        
        scatter(locs, linspace(0,0,length(locs)), 'filled')
        hold off
        
        n_seizures(i) = length(pks);
    end
    %title('aaaaa')

end

function filt = filter_all (data_all, lo_f, hi_f, order, sample_f)
    [r, c] = size(data_all);
    filt = zeros(r,c);
    Wn = [lo_f hi_f] / (sample_f / 2);
    [b, a] = butter(order, Wn, 'bandpass');
    for i = 1:r
        filt(i, :) = filter (b,a,data_all(i,:));
    end
end

function [rewd, lfps] = rewards_all (data_f, alpha, resolution, starts)

    [r,c] = size(data_f);
    [r1, c1] = size(starts);
    if r1 ~= r
        starts = zeros(r,1);
    end
    
    lfps = zeros(r, 1);
    rewd = zeros(r, c/resolution);
    
    for i = 1:r
        [rew, lfp] = get_reward(data_f(i,:), alpha, resolution, starts(i));
        
        rewd(i,:) = rew;
        lfps(i,:) = lfp;
    end
    

end

