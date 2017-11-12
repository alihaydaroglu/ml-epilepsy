function  plot_file( file, electrodes, y_scale, f_sampling, t_st, t_end )


    d = load(file);
    data = d.data;

    n_electrodes = length(electrodes);
    
    rows = ceil(sqrt(n_electrodes));
    
    for i = 1:n_electrodes
        
        time = linspace(0, size(data,2)/f_sampling, size(data,2));
        subplot(rows, rows, i)
        plot(downsample(time, 100), decimate(data(electrodes(i), :), 100))
        ylim([-y_scale, y_scale]);
        xlim([t_st, t_end]);
        size(data(electrodes(i),:));
        size(time);
    end

end

