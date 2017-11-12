function [ specificity, sensitivity, szr_latency ] = eval_2class( model, feature_set, seizures, mus, sigmas )

    if nargin < 4
        mus = 1;
        sigmas = 1;
    end

    to_predict = (feature_set - repmat(mus, size(feature_set, 1), 1)) ./ repmat(sigmas, size(feature_set, 1), 1);
    
    [labels, ~, ~] = svmpredict(zeros(n_points,1), double(to_predict), model, ['-q']);
    
    %number of seizures (not seizure points!)
    n_szrs = size(seizures,1);
    %number of non-seizure points
    n_non_seizures = size(to_predict,1) - sum( seizures(:,2) - seizures(:,1)) - size(seizures,1);
    
    detected_szrs = 0;
    szr_latency = 0;
    all_positives = 0;
    
    for i = 1:n_seizures
        
        szr_str = seizures(i,1);
        szr_end = seizures(i,2);
        
        detections = ( labels(szr_str:szr_end) == 1 );
        detected_szrs = detected_szrs + (sum(detections) > 0);
        all_positives = all_positives + sum(detections);
        
        szr_latency = szr_latency + find(detections, 1);
        
    end
    
    szr_latency = szr_latency / n_szrs;
    specificity = 1 - ( (sum(labels) - all_positives) / n_non_seizures );
    sensitivity = detected_szrs/all_szrs;
end

