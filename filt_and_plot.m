
function filt_and_plot(lo_freq, hi_freq, order, data_all, rewd_all, downsampler)
    sampling_freq = 5e+04 / (2* downsampler);
    [r,c] = size(data_all);
    data_dwn = zeros(r,c);
    for i = 1:r
        data_dwn(i,:) = downsample(data_all(i,:), downsampler);
    end
    Wn = [lo_freq hi_freq] / ( sampling_freq);
    [b, a] = butter(order, Wn, 'bandpass');
    %fvtool(b,a)
    filt = filter_all(data_dwn, b, a);
    plot_mea(data_dwn, filt, rewd_all, sampling_freq)
end


function filt = filter_all (data_all, b, a)
    [r,c] = size(data_all);
    filt = zeros(r, c);
    for i = 1:r
        filt(i,:) = filtfilt(b,a,data_all(i,:));
    end
end
