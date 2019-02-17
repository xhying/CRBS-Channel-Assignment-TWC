function reward = compute_reward(nc_pair, cbsd, settings)
       
if strcmp(settings.reward_func, 'linear')
    reward = length(nc_pair.node_idx)*length(nc_pair.chns);
    
elseif strcmp(settings.reward_func, 'log')
    reward = length(nc_pair.node_idx)*(1+log(length(nc_pair.chns)));
    
elseif strcmp(settings.reward_func, 'capacity')
    % This is only used for nonbinary GAA CA.
    % No need to compute the reward for a super_nc_pair for nonbinary GAA CA.
    if length(nc_pair.node_idx) > 1
        error('compute_reward: it should not be reached.')
        reward = 0;
    else
        % Compute the interference-free capacity in area average. 
        reward = compute_capacity(nc_pair, cbsd, [], [], settings);
    end
end

