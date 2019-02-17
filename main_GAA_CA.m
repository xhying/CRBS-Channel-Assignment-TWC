function main_GAA_CA(graph_mode, exp_mode)
% Experiment mode for binary GAA CA
%   'impact_of_radius': radius of the circular region
%   'impact_of_lambda': trade-off parameter in binary GAA CA 
%   'impact_of_alpha_limit': Sum activity index limit

% Experiment mode for non-binary GAA CA
%   'impact_of_radius': radius of the circular region
%   'impact_of_lambda': trade-off parameter in non-binary GAA CA 

%=========================================
%graph_mode = 'non-binary';
%exp_mode = 'impact_of_radius'; 
save_flag = true;
%=========================================

num_exp = 30;

radius = 0.8; % in km
cs_thr = -75; % in dBm/10 MHz
alpha_limit = 1;

if strcmp(graph_mode, 'binary')
    lambda = 0;
elseif strcmp(graph_mode, 'non-binary')
    lambda = 1;
end

if strcmp(graph_mode, 'binary')
    LOG_BASE = './Log/binary_GAA_CA';
    
    if strcmp(exp_mode, 'impact_of_radius')
        target_range = 0.4:0.2:1.2;
        
        algos = cell(1,5);
        algos{1}.mode = 'proposed';
        algos{1}.reward_func = 'linear';
        algos{1}.coex_flag = false;
        
        algos{2}.mode = 'proposed';
        algos{2}.reward_func = 'log';
        algos{2}.coex_flag = false;
        
        algos{3}.mode = 'proposed';
        algos{3}.reward_func = 'linear';
        algos{3}.coex_flag = true;
        
        algos{4}.mode = 'proposed';
        algos{4}.reward_func = 'log';
        algos{4}.coex_flag = true;
        
        algos{5}.mode = 'baseline';
        algos{5}.reward_func = 'linear';
        algos{5}.coex_flag = false;
        
    elseif strcmp(exp_mode, 'impact_of_lambda')
        target_range = 0:2:8;
        
        algos = cell(1,4);
        algos{1}.mode = 'proposed';
        algos{1}.reward_func = 'linear';
        algos{1}.coex_flag = false;
        
        algos{2}.mode = 'proposed';
        algos{2}.reward_func = 'log';
        algos{2}.coex_flag = false;
        
        algos{3}.mode = 'proposed';
        algos{3}.reward_func = 'linear';
        algos{3}.coex_flag = true;
        
        algos{4}.mode = 'proposed';
        algos{4}.reward_func = 'log';
        algos{4}.coex_flag = true;  
        
    elseif strcmp(exp_mode, 'impact_of_alpha_limit')
        target_range = 0:1:5;
        
        algos = cell(1,2);        
        algos{1}.mode = 'proposed';
        algos{1}.reward_func = 'linear';
        algos{1}.coex_flag = true;
        
        algos{2}.mode = 'proposed';
        algos{2}.reward_func = 'log';
        algos{2}.coex_flag = true;
        
    else
        error('Unknown experiment mode for binary GAA CA');
    end
    
elseif strcmp(graph_mode, 'non-binary')
    %LOG_BASE = './Log/nonbinary_GAA_CA';
    LOG_BASE = './Log/nonbinary_GAA_CA_capacity';
    
    if strcmp(exp_mode, 'impact_of_radius')
        target_range = 0.4:0.2:1.2;

        algos = cell(1,1);
        algos{1}.mode = 'proposed';
        algos{1}.reward_func = 'capacity'; %'linear';        % 'linear', 'log', 'capacity'
        algos{1}.penalty_func = 'capacity_reduction'; %'interference'; % 'interference' or 'capacity_reduction'
        algos{1}.coex_flag = false;

    elseif strcmp(exp_mode, 'impact_of_lambda')
        target_range = 0.8:0.1:1.2; %10.^(0:1:6);
        
        algos = cell(1,1);
        algos{1}.mode = 'proposed';
        algos{1}.reward_func = 'capacity'; %'linear';
        algos{1}.penalty_func = 'capacity_reduction';%'interference';
        algos{1}.coex_flag = false;

    else
        error('Unknown experiment mode for nonbinary GAA CA');
    end
else
    error('Unknown graph mode');
end

for target_id = 1:length(target_range)
    if strcmp(exp_mode, 'impact_of_radius')
        radius = target_range(target_id);
        
    elseif strcmp(exp_mode, 'impact_of_lambda')
        lambda = target_range(target_id);
       
    elseif strcmp(exp_mode, 'impact_of_alpha_limit')
        alpha_limit = target_range(target_id);
    end
    
    result = cell(num_exp,length(algos));
    
    parfor exp_id = 1:num_exp
    %for exp_id = 1:num_exp
        fprintf('=======================================================\n');
        
        seed = exp_id; 
        rng(seed);
        
        GAA_locations = get_NYC_WiFi_locations(seed, radius);
        
        result_tmp = cell(1,length(algos));
        
        % Generate randomly 20 located PA CBSDs
        PA_cbsds = cell(1,20);
        
        for i=1:length(PA_cbsds)
            r = rand()*radius;
            theta = rand()*2*pi;
            PA_cbsds{i}.center = [r*cos(theta), r*sin(theta)];
            
            if i <= length(PA_cbsds)/2
                PA_cbsds{i}.chns = [1,2,3,4];
            else
                PA_cbsds{i}.chns = [5,6,7];
            end
        end
        
        for algo_id=1:length(algos)
            algo = algos{algo_id};
            
            % Get basic settings
            settings = get_settings();
            settings.num_of_GAA_nodes = length(GAA_locations(:,1));
            settings.mode = graph_mode;
            settings.algo_mode = algo.mode;
            settings.reward_func = algo.reward_func;
            if strcmp(graph_mode, 'binary')
                settings.min_demand = 1;
                settings.max_demand = 4;
            elseif strcmp(graph_mode, 'non-binary')
                settings.min_demand = 1; 
                settings.max_demand = 4;
                settings.penalty_func = algo.penalty_func;
            end
            settings.super_node_enabled = algo.coex_flag;
            settings.alpha_limit = alpha_limit; % Will be ignored if coex_flag is false
            settings.lambda = lambda;
            settings = update_settings(settings, cs_thr);
            
            settings.PA_cbsds = PA_cbsds;
            settings.GAA_cbsds = generate_cbsds_from_locations(settings, GAA_locations, seed);
            result_tmp{algo_id} = GAA_CA(settings);
        end

        result(exp_id, :) = result_tmp;
        
    end
    
    if save_flag
        save(sprintf('%s/%s_%s_target_%.1f.mat', LOG_BASE, graph_mode, exp_mode, target_range(target_id)), 'result');
    end
end
