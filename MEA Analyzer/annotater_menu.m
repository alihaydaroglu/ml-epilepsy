function annotater_menu( directory )

    % Get .mcd files in directory
    files = dir([directory '*.mcd']);

    
    % Starting Plot parameters: the parameters on each plot are
    % f:                .mcd file to read
    % e:                electrode to read
    % s_p:              save file for annotation
    % p_s:              previous annotation of set for detailed annotation
    all_e = [12:17 21:28 31:38 41:48 51:58 61:68 71:78 82:87];
    
    % GUI spacing and sizing
    fig_xpos = 500;
    fig_ypos = 200;
    fig_xdim = 400;
    fig_ydim = 300;
    popup_size = [300 20];
    butt_size = [(popup_size(1) - 100)/2, 1.5*popup_size(2)];
    posx = (fig_xdim - popup_size(1))/2;
    title_pos = [posx fig_ydim - 50];
    f_pos = fig_ydim - 75;
    e_pos = f_pos - 50;
    sp_pos = e_pos - 50;
    ps_pos = sp_pos - 50;
    txt_offset = 20;
    b_pos = ps_pos - 50;
    posx_mid = (fig_xdim - posx) - butt_size(1);
    title_size = [popup_size(1), 50];
    
    f2 = figure('Position', [fig_xpos fig_ypos fig_xdim fig_ydim], 'Name','Set up Annotater','NumberTitle','off');
    
    
    % Make some GUIs    
    title_txt = uicontrol('Style', 'text', 'Position', [title_pos title_size], 'String', 'Choose Annotater Settings','FontWeight', 'bold', 'FontUnits', 'points', 'FontSize', 15);
    
    select_f = uicontrol('Style', 'popup','String', {files.name},'Position', [posx f_pos popup_size]);
    select_f.Callback = @change_f; %@(es,ed) plot_electrode([directory files(es.Value).name], [47], 100), 
    f_txt = uicontrol('Style', 'text', 'Position', [posx f_pos + txt_offset popup_size], 'String', 'Data File','FontWeight', 'bold');
    
    select_e = uicontrol('Style', 'popup','String', all_e,'Position', [posx e_pos popup_size]);
    select_e.Callback = @(es,ed) change_e(es,ed,1); %@(es,ed) plot_electrode([directory files(es.Value).name], [47], 100), 
    e_txt = uicontrol('Style', 'text', 'Position', [posx e_pos + txt_offset popup_size], 'String', ['Electrode on Plot ' num2str(1)],'FontWeight', 'bold');
    
    select_sp = uicontrol('Style', 'edit','String', directory, 'Position', [posx sp_pos popup_size]);
    select_sp.Callback = @change_end; %@(es,ed) plot_electrode([directory files(es.Value).name], [47], 100), 
    sp_txt = uicontrol('Style', 'text', 'Position', [posx sp_pos + txt_offset popup_size], 'String', 'Save As (no file extension)','FontWeight', 'bold');

    select_ps = uicontrol('Style', 'edit','String', directory, 'Position', [posx ps_pos popup_size]);
    select_sp.Callback = @change_end;
    sp_txt = uicontrol('Style', 'text', 'Position', [posx ps_pos + txt_offset popup_size], 'String', 'Previous Annotation (needed for 2-Class Annotation)','FontWeight', 'bold');
   
    start_2class = uicontrol('Style', 'pushbutton', 'String', '2-Class Annotation',  'Position', [posx b_pos butt_size]);
    select_sp.Callback = @change_end;

    start_1class = uicontrol('Style', 'pushbutton', 'String', 'Simple Annotation',  'Position', [posx_mid b_pos butt_size]);
    select_sp.Callback = @change_end;  
    
    h = findobj( f2, '-property', 'Units' );
    set( h, 'Units', 'Normalized' )

    function update(es, ed, var)
        f = [directory files(es.Value).name];
        str = 0;
        fin = length(load_mcd(f, e_s(1), d))*d/25000;
        refresh();
    end
end