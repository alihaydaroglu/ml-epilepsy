function [edmse] = EDMSE( signal, a, band, f_sampling, edm_prev)


    FIR = 1;
    IIR = 2; 
    FILT = 0;%FIR;
    
    Fs = f_sampling;
    n_taps = 255;
    order = 3;
    alpha = 1/2^a; % EDM coefficients
    
    if FILT == FIR
        % Construct Filter
        w = kaiser(n_taps+1,0.5);

        fclow = band(1);
        fchigh =  band(2);
        BPF=fir1(n_taps, [ fclow fchigh ]./(Fs/2), w');
        sig_filt = filter(BPF, 1, signal);
    end
    if FILT == IIR
        Wn = [band(1) band(2)] / ( Fs/2);
        [b, a] = butter(order, Wn, 'bandpass');
        sig_filt = filter(b,a, signal);
    end
        
    if FILT == 0
        sig_filt = signal;
    end
    sig_filt = abs(sig_filt);

    edmse = zeros(length(sig_filt),1);
    edm = 0;
    for i=1:length(edmse)
            edm = edm - alpha*(edm - sig_filt(i));
            
            edmse(i) = edm;
    end
    
    edmse = single(edmse);
end


        
        