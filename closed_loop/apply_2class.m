function [time, data, avg_labels] = apply_2class( model_path, file_path, file_num, electrode, fp )
    model_file = load(model_path);
    model = model_file.best_model;
    mus = model_file.mu;
    sigmas = model_file.sigma;
    
    decimator = 5;
    f_sampling = 50000/decimator;
    d = load([file_path file_num]);
    data = d.data(electrode,:);

    
    if nargin > 4
        ftr_file = load(fp);
        ftr = ftr_file.debug_ftr';
        start = 1;
        fin = length(data);
        n_points = length(ftr(start:fin,1)); 
        to_predict = (ftr(start:fin,:) - repmat(mus, size(ftr(start:fin,:), 1), 1)) ./ repmat(sigmas, size(ftr(start:fin,:), 1), 1);
    else
        feature_path = [file_path 'edm-features-e' num2str(electrode, '%02i') '.mat'];
        features = load(feature_path);

        start = 1;
        fin = length(data);
        n_points = length(features.se_concat(start:fin,1)); 
        to_predict = (features.se_concat(start:fin,:) - repmat(mus, size(features.se_concat(start:fin,:), 1), 1)) ./ repmat(sigmas, size(features.se_concat(start:fin,:), 1), 1);
    end
    [predicted_labels, accuracy, decision_values] = svmpredict(zeros(n_points,1), double(to_predict), model, []);

    
    
    time = linspace(1/f_sampling, length(predicted_labels)/f_sampling, length(predicted_labels));
    
    z = zeros(size(time));
    avg_labels = movmean(predicted_labels, [500 0]);
    col = predicted_labels;
    col = double(avg_labels > 0.2);
    
    
    title(['Model used: ' model_path(length(model_path)-12:length(model_path)-4) ' File Classified: f' num2str(file_num, '%04i') '-e' num2str(electrode, '%02i')]);

    downsampler = 50;
    hold on;
    yyaxis left;
    colormap winter;
    
    t_plot = downsample(time, downsampler);
    d_plot = downsample(data(start:fin), downsampler);
    z_plot = downsample(z, downsampler);
    c_plot = downsample(col, downsampler);
    a_plot = downsample(predicted_labels, downsampler);
    
    
    colormap winter;
    
    surface([t_plot;t_plot],[d_plot;d_plot],[z_plot;z_plot],[c_plot';c_plot'],...
        'facecol','no',...
        'edgecol','interp',...
        'linew',0.5);
        

%     yyaxis right;
%     plot(t_plot, a_plot);
    hold off;
end

