function plot_recording(data, sample_rate, y_scale, id, big_title, small_title, feature, data2)

    io_peaks = 0;
    if (nargin > 6) && min(feature == 'IO')
        io_peaks = 1;
    end
    


    [r,c] = size(data);
    n = ceil(sqrt(r));
    
    t = linspace(0, (1/sample_rate) * c, c);
    
    for i = 1:r
        subplot(n,n,i)
        hold on 
        plot(t, data(i,:))
%         findpeaks(data(i,:),t, 'MinPeakProminence', y_scale / 10)
        
        if io_peaks
            scatter((1/sample_rate)*data2(i,1), data2(i,2), 'filled');
            data2(i,:)
            tit = ['IO' num2str(id(i)) 'V']
            title(tit)
        end
        %xlabel('Time (s)')
        ylabel('Electrode (V)')
        
        
        hold off
        
        axis([0, (1/sample_rate) * c, -y_scale, y_scale])
        %title([small_title num2str(id(i))])
    end
    suptitle(big_title);
    
end