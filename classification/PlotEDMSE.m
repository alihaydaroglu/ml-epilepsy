function PlotEDMSE ( se_concat, Fs, sample_sz_end, sample_sz_onset, fname )

    cmin = -6;
    cmax = 6;                

    fig = figure(1);

    imagesc(se_concat)
    caxis([cmin cmax])
    set(gca,'YDir','normal')
        
        
    hold on;
  
    y = 0:size(se_concat,2);
    x(1:length(y))=sample_sz_onset;
    plot(x,y,'g');
    x(1:length(y))=sample_sz_end;
    plot(x,y,'r');
    
    title('EDM SE')
    xlabel('Time (samples)')
    ylabel('channel,frequency,decay rate');
	saveas(fig,fname);
end