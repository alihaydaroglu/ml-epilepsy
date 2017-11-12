function plot_special(data1, data2, sample_rate, y_scale, big_title)

   
    [r,c] = size(data1);
    
    t = linspace(0, (1/sample_rate) * c, c);
    
    for i = 1:3
        hold on
        subplot(3,2,2*i)
        plot(t, data1(i,:))
        axis([0, (1/sample_rate) * c, -y_scale, y_scale])
        subplot(3,2,2*i-1)
        plot(t, data2(i,:))
        axis([0, (1/sample_rate) * c, -y_scale, y_scale]) 
    end
    suptitle(big_title);
    
end