function annotate(data, f_sampling, frame_seconds, buffer, save_path, initial_classification)

%   Someone teach me how to do this without global variables pls
    global d_in frame_samples f_sec classes i s_p init_vars init_class times;
    global bsl ict int art;
    global WAIT_FOR_ANNOTATION;
    
    WAIT_FOR_ANNOTATION = 10;
    init_vars = who;
    
%   Don't change this. It's for the classifier.
    bsl = 0;  %'baseline';
    ict = 1;  %'ictal';
    int = 2;  %'inter-ictal';
    art = 3; %'artifact';
    
%   Put input vars into global vars
    f_sec = frame_seconds;
    i = buffer;
    d_in = data;
    s_p = save_path;
    frame_samples = f_sec * f_sampling;
    

%   Snip the last sample cause you don't wanna deal with a half frame
%   later.
    [r,c] = size(d_in);
    n_frames = floor(c/frame_samples);
    classes = NaN(1,n_frames);
    times = NaN(1,n_frames);
    
%   So, in case you want to only annotate certain parts (that have been
%   classified before), use the initial_classification array. 0 is
%   baseline, 1 is any outliers.
    if nargin > 5
        init_class = initial_classification;
    else
        init_class = ones(1, n_frames);
    end
    
%   Use this if you feel like keeping the features here too. Probably
%   smarter to do it in another file

%   n_features = length(extract_features(1:100, 1:1000, 100));
%   predictors = zeros(n_samples, n_features);   
%     for j = buf:n_samples-buf
%         st_1 = (j-1)*frame_samples + 1;
%         en_1 = j*frame_samples;
%         st_2 = (j-buf) * frame_samples + 1;
%         en_2 = (j+buf) * frame_samples;
% 
%         predictors(j,:) = extract_features(d_in(electrode,st_1:en_1), d_in(electrode,(st_2:en_2)),f_sampling);
%     end
   


    start();


end

%% Handlers and Updaters
function start()
    hold on
    %plot(d_in(1,(i-1)*frame_samples + 1 : i * frame_samples))
    %plot(1:10)
    
    
    refresh_plot()
    
%     plot (d_in(1,(i-3)*frame_samples + 1 : (i+4) * frame_samples), 'b')
%     plot ( [750 750], [-1 1], [1000 1250], [-1,1]);
%     axis([0 7*250 -30e-05 30e-05])
%     hold off

    
end

function cleanup(source, event)
    global classes s_p init_vars times;
    s_p
    save(s_p,'classes', 'times');
    cla
    %clearvars('-except',init_vars{:})

end

function skip(source, event)
    global i;
    i = i + 50;
    refresh_plot();

end

function back(source, event)
    global i;
    i = i - 1;
    refresh_plot()
end

function baseline_next(source, event)
    
    global i bsl classes times f_sec;
    classes(i) = bsl;
    times(i) = f_sec * (i-1);
    next()
    refresh_plot()
end

function ictal_next(source,event)
    
    global i ict classes times f_sec;
    classes(i) = ict;
    times(i) = f_sec * (i-1);
    next()
    refresh_plot()
end

function inter_next(source, event)
    
    global i int classes times f_sec;
    classes(i) = int;
    times(i) = f_sec * (i-1);
    next()
    refresh_plot() 
end

function artifact_next(source, event)
    global i art classes times f_sec;
    classes(i) = art;
    times(i) = f_sec * (i-1);
    next()
   
    refresh_plot() 
    
    
end

function next()
    global i init_class;
    i = i + 1;
    while init_class(i) == 0
        baseline_next();
    end
end

function quit()
    global WAIT_FOR_ANNOTATION;
    WAIT_FOR_ANNOTATION = 0;
end

function refresh_plot()    
    global i;
    global frame_samples d_in f_sec s_p;
    y_scale = 1e-4;
    w_s = 1;
    w_l = 20;
    cla;
    
    subplot(2,1,1)
    cla;
    t = linspace(0,(2*w_s+1)*f_sec, (2*w_s+1)*frame_samples);
    hold on
    plot ( [w_s* f_sec w_s*f_sec], [-y_scale y_scale], 'k');
    plot (t, d_in(1,(i-w_s)*frame_samples + 1 : (i+1+w_s) * frame_samples), 'b')
    
    axis([0 (2*w_s+1)*f_sec -y_scale y_scale])
    hold off;
    xlabel("Time (s)");
    ylabel("Voltage (V)");
    subplot(2,1,2)
    hold on
    cla;
    
    plot (linspace((w_s-w_l)*f_sec, (w_s+w_l)*f_sec, 2*w_l*frame_samples), d_in(1,(i-w_l)*frame_samples + 1 : (i+w_l) * frame_samples), 'b')
    plot ( [w_s* f_sec w_s*f_sec], [-y_scale y_scale], 'k');
    axis([(w_s-w_l)*f_sec (w_s+w_l)*f_sec -y_scale y_scale])
    hold off;
    b1 = uicontrol('Style', 'pushbutton', 'String', 'Baseline',  'Position', [100 5 50 20],'Callback', @baseline_next);
    b2 = uicontrol('Style', 'pushbutton', 'String', 'Ictal', 'Position', [200 5 50 20], 'Callback', @ictal_next);
 %   b3 = uicontrol('Style', 'pushbutton', 'String', 'Inter-ictal', 'Position', [300 5 50 20], 'Callback', @inter_next);
 %   b4 = uicontrol('Style', 'pushbutton', 'String', 'Artifact',  'Position', [400 5 50 20], 'Callback',@artifact_next);
    b5 = uicontrol('Style', 'pushbutton', 'String', 'Back',  'Position', [300 5 50 20], 'Callback',@back);
    b6 = uicontrol('Style', 'pushbutton', 'String', 'Save',  'Position', [400 5 50 20], 'Callback',@cleanup);
    b7 = uicontrol('Style', 'pushbutton', 'String', 'Jump',  'Position', [500 5 50 20], 'Callback',@skip);
 %   b8 = uicontrol('Style', 'pushbutton', 'String', 'Quit',  'Position', [800 5 50 20], 'Callback',@quit);
    suptitle('Annotating File for One-Class SVM'); 
    xlabel("Time (s)");
    ylabel("Voltage (V)");
%     drawnow
%     while(1)
%     end
end