function [ ] = visualizer( directory )

    % Get .mcd files in directory
    files = dir([directory '*.mcd']);
    

    
    % Starting Plot parameters: the parameters on each plot are
    % f:                .mcd file to read
    % e or e_s(i):      electrode to plot
    % d:                decimation (downsampling) coefficient
    % str:              start time of plot
    % fin:              end time of plot
    % y:                y axis bounds 
    
    all_e = [12:17 21:28 31:38 41:48 51:58 61:68 71:78 82:87];
    n_e = 3;
    f = [directory files(1).name];
    e_s(1) = all_e(1);
    e_s(2) = all_e(2);
    e_s(3) = all_e(3);
    e_s(4) = all_e(4);
    e_s(5) = all_e(5);
    d = 100;
    str = 0;
    fin = length(load_mcd(f, e_s(1), d))*d/25000;
    y = 0.005;
    
    % GUI spacing and sizing
    fig_xpos = 200;
    fig_ypos = 50;
    fig_xdim = 1200;
    fig_ydim = 750;
    
    txt_offset = 20;
    box_offset = 50;
    posx1 = 10;
    posx2 = posx1;
    popup_size = [100 20];
    textbox_size = popup_size
    title_size = [fig_xdim/3 30];
    title_pos = [fig_xdim/2 - title_size(1)/2 fig_ydim-title_size(2)]
    
    % GUI placement
    f_pos = fig_ydim - 2*box_offset;
    d_pos = f_pos - box_offset;
    y_pos = d_pos - box_offset;
    str_pos = y_pos - box_offset;
    end_pos = str_pos - box_offset;
    e1_position = end_pos - box_offset;

    % Create Figure
    f1 = figure('Position', [fig_xpos fig_ypos fig_xdim fig_ydim], 'Name','MEA Analyzer','NumberTitle','off')
    title_txt = uicontrol('Style', 'text', 'Position', [title_pos title_size], 'String', 'Multi Electrode Array Data Visualizer','FontWeight', 'bold', 'FontUnits', 'points', 'FontSize', 17);
    
    
    % Make some GUIs
    select_f = uicontrol('Style', 'popup','String', {files.name},'Position', [posx1 f_pos popup_size]);
    select_f.Callback = @change_f; %@(es,ed) plot_electrode([directory files(es.Value).name], [47], 100), 
    f_txt = uicontrol('Style', 'text', 'Position', [posx1 f_pos + txt_offset popup_size], 'String', 'Data File','FontWeight', 'bold');
    
    select_d = uicontrol('Style', 'slider','Min',1,'Max',250,'Value',100,'Position', [posx1 d_pos textbox_size]);
    select_d.Callback = @change_d; %@(es,ed) plot_electrode([directory files(es.Value).name], [47], 100), 
    d_txt = uicontrol('Style', 'text', 'Position', [posx1 d_pos + txt_offset popup_size], 'String', 'Downsampling','FontWeight', 'bold');
    
    select_y = uicontrol('Style', 'edit','String', num2str(y), 'Position', [posx1 y_pos textbox_size]);
    select_y.Callback = @change_y; %@(es,ed) plot_electrode([directory files(es.Value).name], [47], 100), 
    y_txt = uicontrol('Style', 'text', 'Position', [posx1 y_pos + txt_offset popup_size], 'String', 'Y-Axis Bound','FontWeight', 'bold');
 
    select_str = uicontrol('Style', 'edit','String', '0', 'Position', [posx1 str_pos textbox_size]);
    select_str.Callback = @change_str; %@(es,ed) plot_electrode([directory files(es.Value).name], [47], 100), 
    str_txt = uicontrol('Style', 'text', 'Position', [posx1 str_pos + txt_offset popup_size], 'String', 'Start Time','FontWeight', 'bold');
    
    select_end = uicontrol('Style', 'edit','String', num2str(fin), 'Position', [posx1 end_pos textbox_size]);
    select_end.Callback = @change_end; %@(es,ed) plot_electrode([directory files(es.Value).name], [47], 100), 
    end_txt = uicontrol('Style', 'text', 'Position', [posx1 end_pos + txt_offset popup_size], 'String', 'End Time','FontWeight', 'bold');

    select_n_e = uicontrol('Style', 'popup','String', 1:5,'Position', [posx1 e1_position popup_size]);
    select_n_e.Callback = @change_n_e; %@(es,ed) plot_electrode([directory files(es.Value).name], [47], 100), 
    n_e_txt = uicontrol('Style', 'text', 'Position', [posx1 e1_position + txt_offset popup_size], 'String', '# of Plots','FontWeight', 'bold');

    select_e(1) = uicontrol('Style', 'popup','String', all_e,'Position', [posx2 (e1_position - box_offset*(1)) popup_size]);
    select_e(1).Callback = @(es,ed) change_e(es,ed,1); %@(es,ed) plot_electrode([directory files(es.Value).name], [47], 100), 
    e_txt(1) = uicontrol('Style', 'text', 'Position', [posx2 (e1_position - box_offset*(1)) + txt_offset popup_size], 'String', ['Electrode on Plot ' num2str(1)],'FontWeight', 'bold');

    

    
    refresh();
    
    % Functions to change plot parameters - there could be a way to do this
    % all in one function but I'm lazy
    function change_f(es, ed)
        f = [directory files(es.Value).name];
        str = 0;
        fin = length(load_mcd(f, e_s(1), d))*d/25000;
        refresh();
    end
    function change_e(es, ed, ch_e)
        e_s(ch_e) = all_e(es.Value);
        refresh();
    end
    function change_d(es,ed)
        d = floor(es.Value);
        refresh();
    end
    function change_str(es,ed)
        str = str2double(es.String);
        refresh();
    end
    function change_end(es,ed)
        fin = str2double(es.String);
        refresh();
    end
    function change_y(es,ed)
        y = str2double(es.String);
        refresh();
    end
    function change_n_e(es,ed)
        n_e = es.Value;
        refresh();
    end

    % Refresh Plot on each input
    function refresh()
        
        try

            for n = 1:length(select_e)
                delete(select_e(n));
                delete(e_txt(n));

            end    

            for i = 1:n_e
                subplot(n_e, 1, i)
                plot_trace(f, e_s(i), d, str, fin,y)

                select_e(i) = uicontrol('Style', 'popup','String', all_e,'Position', [posx2 (e1_position - box_offset*(i)) popup_size]);
                select_e(i).Callback = @(es,ed) change_e(es,ed,i); %@(es,ed) plot_electrode([directory files(es.Value).name], [47], 100), 
                e_txt(i) = uicontrol('Style', 'text', 'Position', [posx2 (e1_position - box_offset*(i)) + txt_offset popup_size], 'String', ['Electrode on Plot ' num2str(i)],'FontWeight', 'bold');


            end
            h = findobj( f1, '-property', 'Units' );
            set( h, 'Units', 'Normalized' )
        catch
            disp("Error! Could not refresh!");
        end
    end


end

function plot_trace(fp, e, d, start_sec, end_sec, y_scale)

    f_sampling = 25000/d;
    start_sample = floor(start_sec*f_sampling) + 1;
    end_sample = floor(end_sec*f_sampling);

   % try
        data = load_mcd(fp, e, d);
        time = 0:1/f_sampling:size(data,2)/f_sampling;
        plot(time(start_sample:end_sample), data(start_sample:end_sample));
        xlabel("Time (s)", 'FontUnits', 'points', 'FontSize', 8);
        ylabel("Voltage (V)", 'FontUnits', 'points', 'FontSize', 8);
        ylim([-y_scale y_scale]);
        xlim([start_sec end_sec]);
        title(['Electrode ' num2str(e)], 'FontWeight', 'bold', 'FontUnits', 'points', 'FontSize', 10);
        
    %catch
        %fprintf("Invalid Selection! Try Again \n");
    %end

end