edms_on = zeros(5,1);
edms_of = zeros(5,1);
alpha = 1/2^8;

edm_on = 0;
edm_of = 0;
for i = 1:length(filt_offline(1,1:end-511))
    edm_on = edm_on - alpha*(edm_on - abs(filt_online(1,511+i)));
    edm_of = edm_of - alpha*(edm_of - abs(filt_offline(1,i)));
    
    edms_on(i) = edm_on;
    edms_of(i) = edm_of;
end

edm_on_2 = EDMSE( abs(filt_online(1,512:end)), 8, [0 0], 10000, 0);
edm_of_2 = EDMSE( abs(filt_offline(1,1:end-511)), 8, [0 0], 10000, 0);