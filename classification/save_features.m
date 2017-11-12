function data = save_features ( file_path, file_name, electrodes, decimator, short, data)
    
    global edm_prevs;

    f_sampling = 25000/decimator;
    
    %     data = data(1,1:10000);
    if nargin < 6
        data = import_mcd(file_path, file_name, decimator, electrodes);
         %sketchy!!!
        file_name = file_name(5:8);
    

    else 
    
        
    end
    %file_name

    se_alphas = [0.1 0.5 1 2 4 6 8 ];%10 12 14 16];

    se_bands = [ 0.5 1;
                1 1.5;
                1.5 2;
                2 3;
                3 4;
                4 5;
                5 6;
                6 7;
                7 8;
                8 10;
                10 12;
                12 15;
                15 20;
                20 25;];
    
     
    if nargin > 4
        if short == logical(1)
            se_alphas = [0.1 0.5 1 3 6 8 ];
                se_bands = [
                1 3;
                3 5;
                5 7;
                7 10;
                10 15
                15 25;];
            
        end 
    end
    
    for e = 1:length(electrodes)
        
        edm_prevs = zeros(1,length(se_alphas) * length(se_bands));
        
        if nargin > 5
            index = electrodes(e)
        else
            index = e;
        end
        
        [se_concat, means, sds] = EDMSE_ExtractAllCombs (data(index,:)', se_bands, se_alphas, f_sampling);
        sp = [file_path 'edm-f' file_name '-e' num2str(electrodes(e), '%02i') '.mat']
        
        save(sp, ...
             'file_path', ...
             'file_name' ,...
             'electrodes' ,...
             'e', ...
             'se_alphas', ...
             'se_bands', ...
             'se_concat')
    end
%     size(se_concat)
%     hold on
%     plot(data(1,:))
%     for i = 1:length(se_concat)
%         plot(se_concat(:,i))
%     end
%     hold off
end