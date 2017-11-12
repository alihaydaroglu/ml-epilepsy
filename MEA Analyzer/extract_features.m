function [ edm_all ] = extract_features( data, f_sampling, alphas, bands, save_path)

    [edm_all, ~, ~] = EDMSE_ExtractAllCombs (data, bands, alphas, f_sampling);

    if nargin > 4
        save(save_path, 'edm_all', 'bands', 'alphas');
    end

end

