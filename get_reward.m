%% Reward Function

function [rewards, prev_lfp] = get_reward(electrode_data, alpha, resolution, start_lfp) % start_lfp is optional, 0 by default
    [r, frame_size] = size(electrode_data);
    if r > 1
        error("Function get_reward only accepts single electrode data")
    end
    
    % start_reward ensures continuitiy of reward function between frames
    if nargin < 4
        start_lfp = 0;
    end
    
    rewards = zeros(1,frame_size/resolution);
   
    %lfps = zeros(frame_size - resolution + 1)
    %lfps(0) = start_lfp
    prev_lfp = start_lfp;
    
    for i = 1 : frame_size/resolution
        step = 1000*electrode_data((i-1) * resolution + 1 : i * resolution);
        step_dot = dot(step, step);
        moving_avg = (1 - alpha) * prev_lfp + step_dot * alpha;
        prev_lfp = moving_avg;
        reward = -log(moving_avg);
        rewards(i) = reward; %reward;
    end    
    return
end