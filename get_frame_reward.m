function [reward, p_lfp] = get_frame_reward(el_data, alpha, prev_lfp)
    dots = dot(el_data, el_data);
    moving_avg = (1 - alpha) * prev_lfp + dots * alpha;
    p_lfp = moving_avg;
    reward = -log(moving_avg);
end
