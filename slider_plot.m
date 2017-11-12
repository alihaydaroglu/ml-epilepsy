function slider_plot( directory )

    % Get .xxx files in directory
    files = dir([directory '*.mcd']);
    
    % to actually get the filename use this:
    file_name = [directory files(1).name];
    
    % random data
    data = [1 2 3 4 5 6 7 8; 8 7 6 5 4 3 2 1];
    
    
    % figure spacing and sizing stuff
    fig_xpos = 200;
    fig_ypos = 50;
    fig_xdim = 300;
    fig_ydim = 300;
    
    f1 = figure('Position', [fig_xpos fig_ypos fig_xdim fig_ydim], 'Name','Analyzer','NumberTitle','off')
    
    
    %slider - set the min max and starting position
    select_d = uicontrol('Style', 'slider','Min',1,'Max',2,'Value',1,'Position', [50 50 100 50]);
    select_d.Callback = @new_plot;
    d_txt = uicontrol('Style', 'text', 'Position', [50 100 100 50], 'String', 'Slider','FontWeight', 'bold');

    function new_plot(es, ed)
        %floor es.Value cause it might be decimal
        %file_to_plot = [directory files(floor(es.Value)).name];
        
        % instead of file, plot random data for show
        
        plot(data(floor(es.Value), :));
    end
    


end