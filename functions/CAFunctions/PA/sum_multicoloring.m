function [I_baseline, node_list] = sum_multicoloring(num_of_PAL_chns, node_list)
adj_matrix = zeros(length(node_list), length(node_list));
for i = 1:length(node_list)
    for j = (i+1):length(node_list)
        if ~isempty(intersect(node_list{i}.tracts, node_list{j}.tracts)) || ...
                node_list{i}.num ~= node_list{j}.num
            adj_matrix(i,j) = 1;
            adj_matrix(j,i) = 1;
        end
    end
end

% Weights are useless
weights = zeros(1, length(node_list));
for i = 1:length(weights)
    weights(i) = 1/node_list{i}.num;
end

all_chns = 1:num_of_PAL_chns;
I_baseline = zeros(1, length(node_list));
V = 1:length(node_list);
while ~isempty(V)
    I_idx = solve_MIS('greedy', adj_matrix(V,V));
    
    % Selected vertices have the same length (i.e., num of colors/chns).
    num = node_list{V(I_idx(1))}.num;
    
    for i = 1:length(I_idx)
        if node_list{V(I_idx(i))}.num ~= num
            error('Error in npSMC: requested nums of chans are different.');
        end
    end
    
    if num <= length(all_chns) 
        assigned_chns = all_chns(1:num);
        
        for i = 1:length(I_idx)
            node_list{V(I_idx(i))}.chns_baseline = assigned_chns;
        end
        
        all_chns(1:num) = [];
        
        I_baseline(V(I_idx)) = 1;
        V = setdiff(V, V(I_idx));
    else
        % fprintf('Not enough channels available.\n');
        break; 
    end
end

I_baseline = find(I_baseline);

% Check if the result is valid
for i = 1:length(I_baseline)
    for j = (i+1):length(I_baseline)
        if ~isempty(intersect(node_list{I_baseline(i)}.tracts, node_list{I_baseline(j)}.tracts)) && ...
                ~isempty(intersect(node_list{I_baseline(i)}.chns_baseline, node_list{I_baseline(j)}.chns_baseline))
            error('PA CA result is invalid');
        end
    end
end