file_path = 'C:\Users\Ali\Documents\ISML\MEA Data\20170622_400_0\';
stim_frq = [0,1, 0.5, 0.33, 1, 1, 1, 0.33, 0.33, 0.33, 0, 0];
file_num = [33,34,37,40, 60,62,65,72,74,76, 73,75, 35,74];
electrodes = [46, 64];

decimator = 100;
f_sampling = 25000/decimator;

%% Annotate and Extract States
for f = 1
    file_name = ['data' num2str(file_num(f), '%04i') '.mcd'];
    save_features ( file_path , file_name , electrodes , decimator ) ;
    for e = 1
        class_path = [file_path 'cls-f' num2str(file_num(f), '%04i') '-e' num2str(electrodes(e), '%02i') '.mat'];
        data = import_mcd(file_path, file_name, decimator, electrodes);
        annotate ( data(e,:), f_sampling, 0.3, 20, class_path );
    end
end

%% Create feature_set and label_set

f = 1;
e = 1; 

feature_path = [file_path 'edm-f' num2str(file_num(f), '%04i') '-e' num2str(electrodes(e), '%02i') '.mat'];
label_path = [file_path 'cls-f' num2str(file_num(f), '%04i') '-e' num2str(electrodes(e), '%02i') '.mat'];

features = load(feature_path);
labels = load(label_path);


feature_set = [];
label_set = [];
n = 1;
for i = 1:length(labels.times)
    if ~isnan(labels.classes(i)) 
        if labels.classes(i) == 1
            label_set(n,:) = 1;
        else
            label_set(n,:) = 0;
        end
        feature_set(n, :) = features.se_concat(int32(labels.times(i) * f_sampling), :);
        n = n + 1;
    end
end

%% Scale the Features



minimums = min(feature_set, [], 1);
ranges = max(feature_set, [], 1) - minimums;

feature_set = (feature_set - repmat(minimums, size(feature_set, 1), 1)) ./ repmat(ranges, size(feature_set, 1), 1);


svm_sweep(label_set, feature_set, 0:30, -20:3);

% 
% n_training_samples = size(feature_set,1);
% n_cv_folds = 5;
% 
% cs = 0:30;
% gs = -20:3;
% 
% % cs = -10:40;
% % gs = -40:10;
% 
% g_cnt = 1;
% c_cnt = 1;
% 
% accuracy_matrix = zeros(3,3);
% 
% for log2c = cs
%     for log2g = gs
%         
%         libsvm_options = ['-v 5 -c ' num2str(2^log2c) ' -g ' num2str(2^log2g)  ];
%         model = svmtrain(label_set, feature_set, libsvm_options);
%         %[predicted_label, accuracy, decision_values] = svmpredict(label_set(:), feature_set, model, []);
%         accuracy_matrix(g_cnt, c_cnt) = model;
%         g_cnt = g_cnt + 1;
%     end
%     c_cnt = c_cnt + 1;
%     g_cnt = 1;
% end
% 
% 
% s = surf(accuracy_matrix);
% set(s,'edgecolor','none');
% xlabel('C');
% ylabel('G');
% zlabel('Accuracy');
