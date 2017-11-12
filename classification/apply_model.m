function [time, data, avg_labels] = apply_model( model_path, file_path, file_num, electrode )

    model_file = load(model_path);
    model = model_file.model;
    mins = model_file.mins;
    rngs = model_file.rngs;
    
    decimator = 50;
    f_sampling = 25000/decimator;
    file_name = ['data' num2str(file_num, '%04i') '.mcd'];
    data = import_mcd(file_path, file_name, decimator, [electrode]);
    save_features ( file_path , file_name , [electrode] , decimator );
    feature_path = [file_path 'edm-f' num2str(file_num, '%04i') '-e' num2str(electrode, '%02i') '.mat'];
    features = load(feature_path);
    
    start = 1;
    fin = length(data);
    n_points = length(features.se_concat(start:fin,1)); 
    
    to_predict = (features.se_concat(start:fin,:) - repmat(mins, size(features.se_concat(start:fin,:), 1), 1)) ./ repmat(rngs, size(features.se_concat(start:fin,:), 1), 1);
    [predicted_labels, accuracy, decision_values] = svmpredict(zeros(n_points,1), double(to_predict), model, []);
    
    time = linspace(1/f_sampling, length(predicted_labels)/f_sampling, length(predicted_labels));
    col = predicted_labels;
    z = zeros(size(time));
    
    title(['Model used: ' model_path(length(model_path)-12:length(model_path)-4) ' File Classified: f' num2str(file_num, '%04i') '-e' num2str(electrode, '%02i')]);

%     
%     hold on;
%     yyaxis left;
%     colormap winter;
%     surface([time;time],[data(start:fin);data(start:fin)],[z;z],[col';col'],...
%         'facecol','no',...
%         'edgecol','interp',...
%         'linew',0.5);
%         
     avg_labels = movmean(predicted_labels, 100);
%     yyaxis right;
%     plot(time, movmean(predicted_labels, 100));
%     hold off;
    
end

