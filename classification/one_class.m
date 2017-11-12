
%% This is the part where you choose the files
file_path = 'C:\Users\Ali\Documents\ISML\MEA Data\20170622_400_0\';
stim_frq = [0,1, 0.5, 0.33, 1, 1, 1, 0.33, 0.33, 0.33, 0, 0];
file_num = [33,34,37,40, 60,62,65,72,74,76, 73,75, 35,74];

decimator = 100;
f_sampling = 25000/decimator;
electrodes = [46, 64];
frame_seconds = 0.3;
buffer = 20;
frame_samples = f_sampling*frame_seconds;


%% This is the part where you annotate
f = 1;
e = 1;


file_num = file_num(f);
file_name = ['data' num2str(file_num(f),'%04i') '.mcd'];
data = import_mcd(file_path, file_name, decimator, electrodes);

el_num = electrodes(e);
save_path = [file_path 'oneclass_annotated_f' num2str(file_num, '%04i') '_e' num2str(el_num, '%02i') '.mat'];
annotate(data(e,:), f_sampling, frame_seconds, buffer, save_path)

%% This is the part where you extract the states you want

n_features = length(extract_features(1:100, 1:1000, 100));
    
for f = 1:length(file_num)
    f_n = file_num(f);
    
    file_name = ['data' num2str(f_n,'%04i') '.mcd']
    fprintf('Reading File %s \n', file_name)
    
    data = import_mcd(file_path, file_name, decimator, electrodes);
    for e = 1:length(electrodes)
         
        n_frames = floor(length(data(e,:))/frame_samples);
        features = zeros(n_frames, n_features); 
        for j = 1:n_frames
            st_1 = (j-1)*frame_samples + 1;
            en_1 = j*frame_samples;
            
            features(j,:) = extract_features(data(e,st_1:en_1), 'not yet',f_sampling);
        end
        save_path = [file_path 'states_v1_f' num2str(f_n, '%04i') '_e' num2str(electrodes(e), '%02i') '.mat']
        save(save_path, 'features');
        
    end
end

%% This is the part where you train the SVM

feature_path = 'C:\Users\Ali\Documents\ISML\MEA Data\20170622_400_0\states_v1_f0033_e46.mat';
classif_path = 'C:\Users\Ali\Documents\ISML\MEA Data\20170622_400_0\oneclass_annotated_f0033_e46.mat';

f = load(feature_path);
c = load(classif_path);

training_vectors = f.features(20:110,:);
t_l = c.classes(20:110)';
training_labels = NaN(1,length(t_l));

for i = 1:length(t_l)
    if t_l(i) == 0
        training_labels(i) = -1;
    else
        training_labels(i) = 1;
    end
end

size(training_labels);
size(training_vectors);
%model = SVM(training_labels', training_vectors);

