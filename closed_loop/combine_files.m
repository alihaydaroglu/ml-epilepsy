% function [data] = combine_files( file_names )
% 
% end

out_file = 'C:\Users\Ali\Documents\ISML\MEA Data\20170718_400_0_CL\alltag28.mat';
in_path = 'C:\Users\Ali\Documents\ISML\MEA Data\20170718_400_0_CL\'

file = 1:16;
tag = 28;
d_all = [];

for i = file
    file_in = [in_path 'file' num2str(i) 'tag' num2str(tag) '.mat']
    d_in = load(file_in);
    d_all = [d_all d_in.data];
end

save(out_file, 'd_all', '-v7.3');