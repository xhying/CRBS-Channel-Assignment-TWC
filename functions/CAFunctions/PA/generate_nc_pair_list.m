function [nc_pair_list, nc_pair_adj_matrix] = generate_nc_pair_list(node_list, num_of_PAL_chns)
%fprintf('\n------------------ Generating NC Pairs --------------------\n');

Omega = 1:1:num_of_PAL_chns; % Default: num_of_PAL_chns = 10

nc_pair_list = {};       % Vertex = NC pair

for i = 1:length(node_list)
    node = node_list{i};
    
    for j = 1:(length(Omega)-node.num+1)
        clearvars nc_pair;
        nc_pair.node_id = i;
        nc_pair.tracts = node.tracts;
        nc_pair.chns = j:1:(j+node.num-1);
        nc_pair_list = [nc_pair_list, nc_pair];
    end
end

fprintf('Generated %d NC pairs --> # of PAL chns = %d\n', ...
    length(nc_pair_list), num_of_PAL_chns);

% -------------------------------------------
% Check total # of NC pairs
nc_pair_count = 0;

for i = 1:length(node_list)
    node = node_list{i};
    nc_pair_count = nc_pair_count + (length(Omega)-node.num+1);
end

if nc_pair_count ~= length(nc_pair_list)
    error('\t Check # of NC pairs - NOT passed!\n');
end
% -------------------------------------------

nc_pair_adj_matrix = zeros(length(nc_pair_list), length(nc_pair_list));

for i = 1:length(nc_pair_list)
    for j = (i+1):length(nc_pair_list)
        nc_pair_i = nc_pair_list{i};
        nc_pair_j = nc_pair_list{j};
        
        is_conflict = 0;
        
        % One-channel-per-node (service area) constraint
        if nc_pair_i.node_id == nc_pair_j.node_id
            is_conflict = 1;
        else
        % Interference/conflict constraint
            node_i_tracts = nc_pair_i.tracts;
            node_j_tracts = nc_pair_j.tracts;
            
            node_i_chns = nc_pair_i.chns;
            node_j_chns = nc_pair_j.chns;
            
            if ~isempty(intersect(node_i_tracts, node_j_tracts)) && ...
                    ~isempty(intersect(node_i_chns, node_j_chns))
                is_conflict = 1;
            end
        end
        
        if is_conflict
            nc_pair_adj_matrix(i, j) = 1;
            nc_pair_adj_matrix(j, i) = 1;
        end
    end
end

for i = 1:length(nc_pair_list)
    nc_pair_adj_matrix(i, i) = 1;
end

% fprintf('----------------------------------------------------------\n');
