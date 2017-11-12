file_path = 'C:\Users\Ali\Documents\ISML\MEA Data\20170718_400_0_CL\';

file_names = ["file0tag32"; "file6tag28"];

d = load([file_path char(file_names(2)) '.mat']);

hold on
plot(linspace(1,length(d.data(58,:))/10000,length(d.data(58,:))),d.data(7,:));
plot(linspace(1,length(d.data(58,:))/10000,length(d.data(58,:))) ,d.data(58,:)/5);
hold off