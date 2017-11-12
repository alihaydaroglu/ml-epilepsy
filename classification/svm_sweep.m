function [model_best, c_or_nu_best, g_best, acc_best, training_ftr] = svm_sweep( lbl, ftr, cs_or_nus, gs)


ONECLASS = 1;

n_training_samples = size(ftr,1);


% cs = -10:40;
% gs = -40:10;

g_cnt = 1;
c_cnt = 1;

accuracy_matrix = zeros(3,3);

if ONECLASS ~= 1
    cs = cs_or_nus;
    for log2c = cs
        for log2g = gs

            libsvm_options = ['-v 5 -c ' num2str(2^log2c) ' -g ' num2str(2^log2g)  ];
            model = svmtrain(lbl, ftr, libsvm_options);
            %[predicted_label, accuracy, decision_values] = svmpredict(label_set(:), feature_set, model, []);
            accuracy_matrix(g_cnt, c_cnt) = model;
            g_cnt = g_cnt + 1;
        end
        c_cnt = c_cnt + 1;
        g_cnt = 1;
    end
    
    
else
    nus = cs_or_nus;
    
    training_ftr = [];
    training_lbl = [];
    test_ftr = ftr;
    test_lbl = lbl;
    n = 1;
    for i = 1:size(ftr,1)
        if lbl(i) == 1 
            training_ftr(n,:) = ftr(i,:);
            training_lbl(n,:) = lbl(i);
            n = n + 1;
        end
    end
    
    for nu = nus
        nu;
        for log2g = gs
            libsvm_options = ['-s 2 -n ' num2str(nu) ' -g ' num2str(2^log2g) ' -q' ];
            model = svmtrain(training_lbl, training_ftr, libsvm_options);
            
            %Sketchy way of stopping everything from printing in svmpredict
            [trash, predicted_label, accuracy, decision_values] = evalc('svmpredict(test_lbl, test_ftr, model, [])');
            correct = 0;
            for i = 1:length(predicted_label)
                if predicted_label(i) == test_lbl(i)
                    correct = correct + 1;
                end
            end
            
            accuracy_matrix(g_cnt, c_cnt) = correct/length(predicted_label);
            g_cnt = g_cnt + 1;
        end
        c_cnt = c_cnt + 1;
        g_cnt = 1;
    end
    
end    
    
    
[val, ind] = max(accuracy_matrix(:));
[r, c] = ind2sub(size(accuracy_matrix),ind);

g_best = 2^(gs(r));
if ONECLASS ~= 1
    c_or_nu_best = 2^(cs(c));
    libsvm_options = ['-c ' num2str(2^c_or_nu_best) ' -g ' num2str(g_best) ' -q'  ];
    model_best = svmtrain(lbl, ftr, libsvm_options);
else
    c_or_nu_best = nus(c);
    libsvm_options = ['-s 2 -n ' num2str(c_or_nu_best) ' -g ' num2str(g_best) ' -q' ];
    model_best = svmtrain(training_lbl, training_ftr, libsvm_options);
end

acc_best = accuracy_matrix(r, c);

fig_sweep = figure(9);
s = surf(accuracy_matrix);
set(s,'edgecolor','none');
xlabel('C/Nu');
ylabel('G');
zlabel('Accuracy');

end


