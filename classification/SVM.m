function [model, mins, ranges] = SVM(label_set, feature_set, cs, gs)

    SWEEP = 1;
    
    if SWEEP
        g_cnt = 1;
        c_cnt = 1;

        accuracy_matrix = zeros(50,50);

        for c = cs
            for g = gs
                libsvm_options = ['-s 0 -c ' num2str(c) ' -t 2 -g ' num2str(g) '-v ' num2str(n_cv_folds) ];
                model = svmtrain(label_set(:), feature_set, libsvm_options);
                [predicted_label, accuracy, decision_values] = svmpredict(label_set(:), feature_set, model, []);
                accuracy_matrix(g_cnt, c_cnt) = accuracy(1);
                g_cnt = g_cnt + 1;
            end
            c_cnt = c_cnt + 1;
            g_cnt = 1;
        end
    end

% 
% 
% function [ model ] = SVM_old( Training_Vectors, Training_Labels ) 
% % Model of MASc ASIC1 
% % Gerard O'Leary c 2016
%     
% 
%     SWEEP = 1;          % Enable grid search for model parameters
%     
%     data_dir = '.\data\';
% 
%     % Choose Kernel
%     LINEAR = 1;
%     KERNEL = LINEAR;
%     
%     n_training_samples = size(Training_Vectors,1);
%     n_cv_folds = n_training_samples;
% 
%     if SWEEP
%         g_resolution = 50;
%         g_values = linspace(0.00000000000000000000001,0.006,g_resolution);
% 
%         c_resolution = 50;
%         c_values = linspace(1,10,c_resolution);
%         accuracy_mx = zeros(g_resolution, c_resolution);
%         c_cnt = 1; g_cnt = 1;
%     else
%         g_values = 0.007;
%         c_values = 10;
%     end
% 
%     
%     for c = c_values  
%         for g = g_values  
%             %auc = plotroc(Training_Labels, Training_Vectors, ['-s 0 -c ' num2str(c) ' -t 2 -g ' num2str(g) '-v ' num2str(n_cv_folds) ]);
%             if KERNEL == RBF
%                 libsvm_options = ['-s 0 -c ' num2str(c) ' -t 2 -g ' num2str(g) '-v ' num2str(n_cv_folds) ];
%             elseif KERNEL == LINEAR
%                 libsvm_options = ['-s 0 -t 0 -c ' num2str(c) '-v ' num2str(n_cv_folds) ];            
%             end
%             model = svmtrain(Training_Labels, Training_Vectors, libsvm_options);
%             [predicted_label, accuracy, decision_values] = svmpredict(Training_Labels, Training_Vectors, model, []);
% 
% 
%             %%%%%%%%%%%%%%%%%%%%%%
%             % Custom RBF implementation
%             %%%%%%%%%%%%%%%%%%%%%%
%             SVs = full(model.SVs); % Full needed due to LIBSVM using a sparse double matrix
%             coefs = model.sv_coef;
%             rho = model.rho;
%             TV = Training_Vectors(1,:);
% 
%             numsvs = model.totalSV;
%             gamma = g;
% 
%             accum = 0;
%             for i=1:numsvs
%                 SV = SVs(i,:);
%                 sub = SV - TV;
%                 sub2 = sub.^2;
%                 accum = accum + ( coefs(i) * exp(-gamma * sum(sub2(:))) );
%             end
%             accum = accum - rho;
%             result = sign(accum);
% 
%             if SWEEP
%                 accuracy_mx(g_cnt,c_cnt) = accuracy(1);
%                 g_cnt = g_cnt+1;
%             end
%         end
%         if SWEEP
%             c_cnt = c_cnt+1;
%         end
%     end
% 
%     if SWEEP
%         figure(1);
%         s = surf(accuracy_mx);
%         set(s,'edgecolor','none');
%         xlabel('Gamma');
%         ylabel('C');
%         zlabel('Accuracy');
%         errors = sum(predicted_label == decision_values);
%     end
% 
%     if WRITE_CSV 
%         SVs = full(model.SVs); % Full needed due to LIBSVM using a sparse double matrix
%         coefs = model.sv_coef;
%         rho = model.rho;
%         gamma = g;
% 
%         csvwrite([data_dir 'SVM_SVs.csv'],	SVs); 
%         csvwrite([data_dir 'SVM_Coefs.csv'],	coefs); 
%         csvwrite([data_dir 'SVM_Rho.csv'],	rho); 
%         csvwrite([data_dir 'SVM_Gamma.csv'], gamma); 
% 
%         % Write without scientific notation
%         % cellfun(@num2str, num2cell(a), 'UniformOutput', false)
%     end
%     
%     
%     REAL_LABEL = Training_Labels;
%     PRED_LABEL = predicted_label;
%     
%     false_positives = 0;
%     false_negatives = 0;
%     true_positives = 0;
%     true_negatives = 0;
%     real_positives = 0;
%     real_negatives = 0;
%     detected_positives = 0;
%     detected_negatives = 0;
%     
%     NUM_INPUT_VECTORS = size(REAL_LABEL,1);
% 	for i = 1:NUM_INPUT_VECTORS;
% 	
%         if (REAL_LABEL(i) == 1) 
%             real_positives = real_positives + 1;
%             if (PRED_LABEL(i) == -1) 
%                 false_negatives = false_negatives + 1;
%             else 
%                 true_positives = true_positives + 1;
%             end
%         end
% 
%         if (REAL_LABEL(i) == -1) 
%             real_negatives = real_negatives + 1;
%             if (PRED_LABEL(i) == 1) 
%                 false_positives = false_positives + 1;
%             else 
%                 true_negatives = true_negatives + 1;
%             end
%         end
% 
%         if (PRED_LABEL(i) == 1) 
%             detected_positives = detected_positives + 1;
%         end
%         
%         if (PRED_LABEL(i) == -1) 
%             detected_negatives = detected_negatives + 1;
%         end
% 
% 	end
%     
%     fprintf('\n-------------------------------\n');
%     fprintf('----Classification Results-----');
%     fprintf('\n-------------------------------\n');
%     fprintf('Num attempted:\t%d\n', NUM_INPUT_VECTORS);
%     fprintf('Classified + :\t%d\n', detected_positives);
%     fprintf('Classified - :\t%d\n', detected_negatives);
%     fprintf('Num correct  :\t%d\n', true_positives+true_negatives);
%     fprintf('Num incorrect:\t%d\n', false_negatives+false_positives);
%     fprintf('Pct correct  :\t%.2f%%\n', ((true_positives+true_negatives) / NUM_INPUT_VECTORS) * 100);
%     fprintf('Sensitivity  :\t%.2f%%\n', (true_positives/(true_positives+false_negatives))*100);
%     fprintf('Specificity  :\t%.2f%%\n', (true_negatives/(true_negatives+false_positives))*100);
%     fprintf('Precision    :\t%.2f%%\n', (true_positives/(true_positives+false_positives))*100);
%     fprintf('-------------------------------\n');
%     
% end