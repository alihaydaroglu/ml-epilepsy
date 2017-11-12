%% Setup constants
data_path = 'E:\MEA Data\20170710_400_2-extra\';
file_num = [15, 47:52];
file_labels = {'No Stim', '2.5 V', 'No Stim', '0.9 V', 'No Stim', '0.3 V', 'No Stim'};
electrodes = [57]



%% Create Labels
labels = zeros(length(file_num), 100);
f = 1;
e = 1;
% for f = 1:length(file_num)   
decimator = 10;
f_sampling = 25000/decimator;
file_name = ['data' num2str(file_num(f), '%04i') '.mcd'];
data = save_features(data_path, file_name, electrodes, decimator);

%% Read and ML
szrs = load([data_path 'szr-f' num2str(file_num(f), '%04d') '-e' num2str(electrodes(e),'%02d') '.mat']);
szrs_file = zeros(1,2);
arts_file = zeros(1,2);
s = 1;
a = 1;
for i = 1:length(szrs.seizures)
    if szrs.seizures(i,1) < szrs.seizures(i,2)
        szrs_file(s,:) = szrs.seizures(i,:);
        s = s + 1;  
    else 
        arts_file(a,:) = [szrs.seizures(i,2), szrs.seizures(i,1)];
        a = a + 1;
    end
end
data_labels = zeros(size(data,2),1);
for i = 1:size(szrs_file,1)
    data_labels(floor(szrs_file(i,1)*f_sampling):floor(szrs_file(i,2)*f_sampling)) = 1;
end

feature_path = [data_path 'edm-f' num2str(file_num(f), '%04i') '-e' num2str(electrodes(e), '%02i') '.mat'];
features = load(feature_path);
[feature_set, mu, sigma] = zscore(features.se_concat);
n_szrs_file = size(szrs_file,1);

n_cross_validations = 3;
blob_size = floor(n_szrs_file/n_cross_validations);


cs = 2.^linspace(-5,10,4);
gs = 2.^linspace(-15,5,4);

acc_all = zeros(length(cs), length(gs));
sen_all = zeros(length(cs), length(gs));
spc_all = zeros(length(cs), length(gs));
prc_all = zeros(length(cs), length(gs));

max_samples = 10000;

%Random sampling stays same over different parameters
rand_train = zeros(n_cross_validations, length(data_labels));
rand_hold = zeros(n_cross_validations, length(data_labels));


for c = 1:length(cs)
    for g = 1:length(gs)
        
        fprintf(['\n \n ############### Testing c: ' num2str(c) ' g: ' num2str(g) '############## \n\n'])
        
        acc_trial = zeros(n_cross_validations,1);
        sen_trial = zeros(n_cross_validations,1);
        spc_trial = zeros(n_cross_validations,1);
        prc_trial = zeros(n_cross_validations,1);
        for i = 1:n_cross_validations
            holdout_start = floor(szrs_file((i-1)*blob_size+1,1) * f_sampling);
            holdout_end = floor(szrs_file(i*blob_size, 2) * f_sampling);
            fprintf('worked1\n');
            train1_start = 1;
            train1_end = holdout_start - 1;
            train2_start = holdout_end + 1;
            train2_end = size(feature_set,1);

            holdout_ftr = feature_set(holdout_start:holdout_end, :);
            holdout_lbl = data_labels(holdout_start:holdout_end);
            
            fprintf('worked2\n');
            if train1_end <= train1_end
                train_ftr = feature_set(train2_start:train2_end, :);
                train_lbl = data_labels(train2_start:train2_end);
            elseif (train2_start >= length(data_labels))
                train_ftr = feature_set(train1_start:train1_end);
                train_lbl = data_labels(train2_start:train2_end);
            else
                train_ftr = [feature_set(train1_start:train1_end); feature_set(train2_start:train2_end)];
            end

            if c == 1 && g == 1
                
                rand_train(i,1:size(train_lbl,1)) = randperm(size(train_lbl,1));
                rand_hold(i,1:size(holdout_lbl,1)) = randperm(size(holdout_lbl,1));
                
            end
            
            samp_to_use = max_samples;
            if size(train_lbl,1) < max_samples
                samp_to_use = size(train_lbl);
            end
            train_lbl = double(train_lbl(rand_train(i,1:samp_to_use), 1));
            train_ftr = double(train_ftr(rand_train(i,1:samp_to_use),:));
            samp_to_use = max_samples;
            if size(holdout_lbl,1) < max_samples
                samp_to_use = size(holdout_lbl);
            end
            holdout_lbl = double(holdout_lbl(rand_hold(i,1:samp_to_use),:));
            holdout_ftr = double(holdout_ftr(rand_hold(i,1:samp_to_use),:));
            fprintf("Training CV %d \n", i);
            libsvm_options = ['-s 0 -t 2 -h 0 -c ' num2str(cs(c)) ' -g ' num2str(gs(g)) ];
            
            model = svmtrain(train_lbl, train_ftr, libsvm_options);
            fprintf("Predicting CV %d \n", i);
            [predicted_label, accuracy, decision_values] = svmpredict(holdout_lbl, holdout_ftr, model, []);
            
            % Analyze result
            REAL_LABEL = holdout_lbl;
            PRED_LABEL = predicted_label;

            false_positives = 0;
            false_negatives = 0;
            true_positives = 0;
            true_negatives = 0;
            real_positives = 0;
            real_negatives = 0;
            detected_positives = 0;
            detected_negatives = 0;

            NUM_INPUT_VECTORS = size(REAL_LABEL,1);
            for j = 1:NUM_INPUT_VECTORS;

                if (REAL_LABEL(j) == 1) 
                    real_positives = real_positives + 1;
                    if (PRED_LABEL(j) == 0) 
                        false_negatives = false_negatives + 1;
                    else 
                        true_positives = true_positives + 1;
                    end
                end

                if (REAL_LABEL(j) == 0) 
                    real_negatives = real_negatives + 1;
                    if (PRED_LABEL(j) == 1) 
                        false_positives = false_positives + 1;
                    else 
                        true_negatives = true_negatives + 1;
                    end
                end

                if (PRED_LABEL(j) == 1) 
                    detected_positives = detected_positives + 1;
                end

                if (PRED_LABEL(j) == 0) 
                    detected_negatives = detected_negatives + 1;
                end

            end
            
            acc_trial(i) = (((true_positives+true_negatives) / NUM_INPUT_VECTORS) * 100);
            sen_trial(i) = ((true_positives/(true_positives+false_negatives))*100);
            spc_trial(i) = ((true_negatives/(true_negatives+false_positives))*100);
            prc_trial(i) = ((true_positives/(true_positives+false_positives))*100);
            

        end
        
        acc_all(c,g) = mean(acc_trial);
        sen_all(c,g) = mean(sen_trial);
        spc_all(c,g) = mean(spc_trial);
        prc_all(c,g) = mean(prc_trial);
        
        
    end
end

    
%%    
fig_sweep = figure(9);
s = surf(log(cs)/log(2), log(gs)/log(2), acc_all);
set(s,'edgecolor','none');
xlabel('C');
ylabel('G');
zlabel('Accuracy');

%% Make the good model


