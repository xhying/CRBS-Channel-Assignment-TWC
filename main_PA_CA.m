% Generate NC-pair conflict graph from census tracts

%% 
% Set grid width to 10? --> adjustify it.
% Set # of PALs per node to unif{1,2,3,4}
% Average over 50 iterations

% Impact of service area size --> fixed radius 0.5, 1, 1.5, 2, 2.5 (w/ 10 PALs chns)
% Impact of # of PAL chns: 7,8,9,10,11,12 (w/ radius of 1)
% Record key statistics for each experiment. 

%%
num_exp = 100;

radius_range = [0.4, 0.6, 0.8, 1, 1.2, 1.4];
PAL_chn_num_range = [7, 8, 9, 10, 11, 12];
area_width_range = [5, 10, 15, 20, 25, 30];

%exp_mode = 'impact_of_radius';
exp_mode = 'impact_of_PAL_chn_num';
%exp_mode = 'impact_of_area_width';

if strcmp(exp_mode, 'impact_of_radius')
    target_range = radius_range;
elseif strcmp(exp_mode, 'impact_of_PAL_chn_num')
    target_range = PAL_chn_num_range;
elseif strcmp(exp_mode, 'impact_of_area_width')
    target_range = area_width_range;
else
    error('Error: unknown mode');
end

% Store results here
result = cell(length(target_range), num_exp);

%% Default setting:
radius = 1;
num_of_PAL_chns = 10;
area_width = 10;

num_of_nodes = 400;
iter_max = 1000;

plot_flag = false;

for i = 1:length(target_range)
    if strcmp(exp_mode, 'impact_of_radius')
        radius = target_range(i);
    elseif strcmp(exp_mode, 'impact_of_PAL_chn_num')
        num_of_PAL_chns = target_range(i);
    elseif strcmp(exp_mode, 'impact_of_area_width')
        area_width = area_width_range(i);
    end
    
    parfor exp_id = 1:num_exp
        fprintf('=======================================================\n');
        fprintf('mode=%s, radius = %.2f, PAL num = %d, exp_id = %d\n', ...
            exp_mode, radius, num_of_PAL_chns, exp_id);
        
        seed = exp_id;
    
        % tract_adj_matrix = generate_tracts('manhattan', []);
        [tract_list, ~] = generate_tracts('grid', area_width);
        node_list = generate_nodes(tract_list, num_of_nodes, iter_max, radius, seed, true);

        [nc_pair_list, nc_pair_adj_matrix] = generate_nc_pair_list(node_list, num_of_PAL_chns);
        
        % Max-cardinality CA
        I = solve_MIS('greedy', nc_pair_adj_matrix);
        % Update channels in node_list
        for k = 1:length(I)
            nc_pair = nc_pair_list{I(k)};
            node_list{nc_pair.node_id}.chns = nc_pair.chns;
        end
        
        % Baseline: sum multicoloring
        [I_baseline, node_list] = sum_multicoloring(num_of_PAL_chns, node_list);
        
        % Store the result
        result{i, exp_id}.radius = radius;
        result{i, exp_id}.num_of_PAL_chns = num_of_PAL_chns;
        result{i, exp_id}.tract_list = tract_list;
        result{i, exp_id}.node_list = node_list;    % With assigned chns
        result{i, exp_id}.nc_pair_list = nc_pair_list;
        result{i, exp_id}.I = I;
        result{i, exp_id}.I_baseline = I_baseline;
        
        result{i, exp_id}.I_max_size = length(node_list);
        result{i, exp_id}.I_size = length(I);
        result{i, exp_id}.I_baseline_size = length(I_baseline);
        result{i, exp_id}.ratio = length(I)/length(node_list);
        result{i, exp_id}.ratio_baseline = length(I_baseline)/length(node_list);
    end
    
    save(sprintf('./Log/%s_iter_%d.mat', exp_mode, i), 'result');
end

save(sprintf('./Log/PA_CA/%s.mat', exp_mode), 'result');






