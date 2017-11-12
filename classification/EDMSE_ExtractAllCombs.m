function [se_concat, means, sds] = EDMSE_ExtractAllCombs( signal, se_bands, se_alphas, f_sampling )
    global edm_prevs;

    %% Process EDM-SE
    n_channels = 1;
    n_se_bands = length(se_bands);
    n_alpha = length(se_alphas);
    n_samp = size(signal,1);
    
 
    fv_dim = (n_channels*n_se_bands*n_alpha);
    se_concat =  zeros(n_samp, fv_dim, 'single');
    
    means = zeros(fv_dim,1);
    sds = zeros(fv_dim,1);
    
    for c = 1
        for b = 1:n_se_bands
            for a = 1:n_alpha 
                
                row = ((c-1)*n_se_bands*n_alpha)+((b-1)*n_alpha)+a;
                c_edmse = EDMSE( signal(:,c), se_alphas(a), se_bands(b,:) ,f_sampling, edm_prevs(row) );
                
                
                edm_prevs(row) = c_edmse(end);
                means(row) = mean(c_edmse);
                sds(row) = std(c_edmse);
                
                se_concat(:,row) = c_edmse;                
            end
        end    
        
    end
    
    WRITE_PARAMS = 0;
    if (WRITE_PARAMS)
        csvwrite('Feature_means.csv', mu);
        csvwrite('Feature_invstd.csv', 1./sigma);
    end
    
    fprintf('Done');

        
end
