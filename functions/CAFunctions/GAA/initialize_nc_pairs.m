function [A, B, C, clusters] = initialize_nc_pairs(settings, cbsds)
reward_func = settings.reward_func;

% A{i} is the i-th NC pair
count = 0;
for cbsd_idx = 1:length(cbsds)
    count = count + length(cbsds{cbsd_idx}.chn_assignments);
end
A = cell(1, count);

% B{i} contains a list of NC pair indices that belong to the i-th node.
% Node index to [NC pair index]
B = cell(1, length(cbsds));

% C(i) is the index of node that the i-th NC pair belongs to.
C = zeros(1, count);

clusters = cell(1, length(cbsds));

idx = 0;

fprintf('    Initializing   NC pairs: ');
progress = textprogressbar(length(cbsds));

for cbsd_idx = 1:length(cbsds)
    progress(cbsd_idx);
    
    cont_chns_cell = cbsds{cbsd_idx}.chn_assignments;
    
    B{cbsd_idx} = zeros(1, length(cont_chns_cell));
    clusters{cbsd_idx} = zeros(1, length(cont_chns_cell));
    
    for i = 1:length(cont_chns_cell)
        idx = idx + 1;
        
        nc_pair.idx = idx;
        nc_pair.node_idx = cbsd_idx;
        nc_pair.chns = cont_chns_cell{i};
        nc_pair.is_min_demand = (length(cont_chns_cell{i}) == min(cbsds{cbsd_idx}.demands));
        nc_pair.reward = compute_reward(nc_pair, cbsds{cbsd_idx}, settings);

        A{idx} = nc_pair;
        B{cbsd_idx}(i) = idx;
        C(idx) = cbsd_idx;
        clusters{cbsd_idx}(i) = idx;
    end
end
%fprintf('    ---> %d NC pairs\n', length(A));