function [ model, mins, rngs ] = create_model( file_path, file_num, electrode)

    %% Setup Constants    
    decimator = 50;
    f_sampling = 25000/decimator;
    class_path = [file_path 'cls-f' num2str(file_num, '%04i') '-e' num2str(electrode, '%02i') '.mat'];
    file_name = ['data' num2str(file_num, '%04i') '.mcd'];
    
    %% Extract Features and Annotate
    
    % If features don't exist 
    save_features ( file_path , file_name , [electrode] , decimator );
    %else
    %continue
    
    
    data = import_mcd(file_path, file_name, decimator, [electrode]);
    h = figure;
    annotate ( data(1,:), f_sampling, 0.3, 20, class_path );
    uiwait(h)


    
    
    
    %% Get the features and Labels, Normalize features
    
    ONECLASS = 0;
    
    
    feature_path = [file_path 'edm-f' num2str(file_num, '%04i') '-e' num2str(electrode, '%02i') '.mat'];
    label_path = [file_path 'cls-f' num2str(file_num, '%04i') '-e' num2str(electrode, '%02i') '.mat'];
    features = load(feature_path);
    labels = load(label_path);
    feature_set = [];
    label_set = [];
    n = 1;

    for i = 1:length(labels.times)
        if ~isnan(labels.classes(i)) 
            if labels.classes(i) == 1
                label_set(n,:) = -1; %seizure
            else
                label_set(n,:) = 1; %everything else
            end
            feature_set(n, :) = features.se_concat(int32(labels.times(i) * f_sampling), :);
            n = n + 1;
        end
    end
    
    mins = min(feature_set, [], 1);
    rngs = max(feature_set, [], 1) - mins;
    feature_set = (feature_set - repmat(mins, size(feature_set, 1), 1)) ./ repmat(rngs, size(feature_set, 1), 1);
   
    %% Labels
    
%     abc = figure;
%     plot(label_set)
%     uiwait(abc)
      
    %% Grid Search For Best Parameters and Train Model
    [model, nu_best, g_best, acc_best, training_ftr] = svm_sweep(label_set, feature_set, linspace(0.000001,.4,30), linspace(-8,2, 30));
    fprintf( "%d  accuracy with gamma = %d, nu = %d \n", acc_best, g_best, nu_best)

%     nu_best
%     g_best

    libsvm_options = ['-s 2 -n ' num2str(nu_best) ' -g ' num2str(g_best) ' -q'  ]
    model = svmtrain(label_set, feature_set, libsvm_options);
  
    
    %% Label the Whole Set
    fig_final = figure(2);
    
    start = 1;
    fin = length(data);
    

    n_points = length(features.se_concat(start:fin,1)); 
    to_predict = (features.se_concat(start:fin,:) - repmat(mins, size(features.se_concat(start:fin,:), 1), 1)) ./ repmat(rngs, size(features.se_concat(start:fin,:), 1), 1);
    [predicted_labels, accuracy, decision_values] = svmpredict(zeros(n_points,1), double(to_predict), model, []);

    
    %% Plot it
    time = linspace(1/f_sampling, length(predicted_labels)/f_sampling, length(predicted_labels));
    col = predicted_labels;
    z = zeros(size(time));
    
    hold on
    yyaxis left
    colormap winter;
    surface([time;time],[data(start:fin);data(start:fin)],[z;z],[col';col'],...
        'facecol','no',...
        'edgecol','interp',...
        'linew',0.5);

    
    
    model_path = [file_path 'mdl-f' num2str(file_num, '%04i') '-e' num2str(electrode, '%02i') '.mat']
    save(model_path, 'model', 'mins', 'rngs');
    training_params_path = [file_path 'trg-f' num2str(file_num, '%04i') '-e' num2str(electrode, '%02i') '.mat'];
    save(training_params_path, 'training_ftr', 'nu_best', 'g_best')
    
    
    

end

