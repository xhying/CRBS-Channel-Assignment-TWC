function [super_nc_pairs, B] = generate_super_nc_pairs(settings, cbsds, nc_pairs, cs_adj_matrix)
max_demand = settings.max_demand;
total_num_of_chns = settings.total_num_of_chns;
reward_func = settings.reward_func;

% Find all channel assignments. For each channel assignment, find the set
% of nodes with that channel assignment available.
all_cont_chns_cell = get_cont_chns(max_demand, ones(1, total_num_of_chns));
nodes_cell = cell(1, length(all_cont_chns_cell));

for i = 1:length(all_cont_chns_cell)
    cont_chns_tmp = all_cont_chns_cell{i};
    
    for cbsd_idx = 1:length(cbsds)
        available_chns_tmp = cbsds{cbsd_idx}.available_chns;
        
        if sum( cbsds{cbsd_idx}.demands==length(cont_chns_tmp) ) == 1 ...   % Correct demand
            && sum( available_chns_tmp(cont_chns_tmp) ) == length(cont_chns_tmp) % Requested channels are all available
            nodes_cell{i} = [nodes_cell{i}, cbsd_idx];
        end 
    end
end

% Super NC pairs as a cell
super_nc_pairs = cell(1, length(nc_pairs));  % Cannot be greater than the number of nc pairs
super_idx = length(nc_pairs);
super_count = 0;

B = cell(1, length(cbsds));

% For each channel assignment, identify super-nodes and form super-NC pairs.
fprintf('    Initializing  SNC pairs: ');
progress = textprogressbar(length(all_cont_chns_cell));

for i = 1:length(all_cont_chns_cell)
    progress(i);
    
    cont_chns = all_cont_chns_cell{i};
    nodes = nodes_cell{i};
    
    % Get corresponding CS subgraph
    sub_cs_adj_matrix = cs_adj_matrix(nodes, nodes); 
    
    % Bron-Kerbosch algorithm to find maximal cliques.
    % Each column corresponds to a maximal clique.
    maximal_cliques = find_maximal_cliques(sub_cs_adj_matrix);
    
    if isempty(maximal_cliques)
        continue;
    end 
    
    % A node belonging to multiple cliques has to choose one to join.
    V_temp = nodes;
    VV_temp = V_temp;
    cliques = cell(1, length(maximal_cliques(1,:)));
    
    for j = 1:length(maximal_cliques(1,:))
        S_temp = V_temp(maximal_cliques(:, j) == 1);    % Nodes that belong to a clique
        cliques{j} = intersect(VV_temp, S_temp);        % Only consider those that have not joined a super node group. 
        VV_temp = setdiff(VV_temp, S_temp);
        
        if isempty(VV_temp)
            break;
        end
    end
    
    cliques = cliques(~cellfun('isempty',cliques));
    
    % For each clique, run First Fit Decreasing bin-packing algorithm.
    for clique_idx = 1:length(cliques)
        super_node_group = cliques{clique_idx};
        
        activity_indices = zeros(1, length(super_node_group));
        for ii = 1:length(super_node_group)
            activity_indices(ii) = min(1, cbsds{super_node_group(ii)}.alpha/length(cont_chns));
        end
        
        % Assignment_matrix(i,j) = 1 if i-th node is assigned to j-th bin
        assignment_matrix = first_fit_decreasing(activity_indices, settings.alpha_limit);
        
        for ii = 1:length(assignment_matrix(1,:))
            if sum(assignment_matrix(:,ii)) > 1
                super_idx = super_idx + 1;
                super_count = super_count + 1;
                
                super_nc_pair.idx = super_idx;
                super_nc_pair.node_idx = super_node_group(assignment_matrix(:,ii) == 1);
                super_nc_pair.chns = cont_chns;
                super_nc_pair.is_min_demand = 0;
                
                for node_idx_tmp = super_nc_pair.node_idx
                    if cbsds{node_idx_tmp}.min_demand == length(super_nc_pair.chns)
                        super_nc_pair.is_min_demand = 1;
                        break;
                    end
                end
                
                % Note: For nonbinary GAA CA, the reward of a super-NC pair is zero.
                super_nc_pair.reward = compute_reward(super_nc_pair, cbsds(super_nc_pair.node_idx), settings);
                
                for node_idx_tmp = super_nc_pair.node_idx
                    B{node_idx_tmp} = [B{node_idx_tmp}, super_idx];
                end
                
                super_nc_pairs{super_count} = super_nc_pair;
            end
        end
    end
end

super_nc_pairs = super_nc_pairs(~cellfun('isempty',super_nc_pairs));
%fprintf('    ---> %d super-NC pairs\n', length(super_nc_pairs));