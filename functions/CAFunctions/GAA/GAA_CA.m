function result = GAA_CA(settings)
PA_cbsds = settings.PA_cbsds;
cbsds = settings.GAA_cbsds;
lambda = settings.lambda;

fprintf('    n=%d, cs_thr=%d, alpha_limit=%d, lambda=%d, reward=%s\n', ...
    length(cbsds), settings.cs_rss, settings.alpha_limit, settings.lambda, settings.reward_func);

% Update channel availability based on PA channel assignments
cbsds = update_channel_availability(settings, PA_cbsds, cbsds);

% Generate available and contiguous channel assignments
for i = 1:length(cbsds)
    cbsds{i}.chn_assignments = get_cont_chns(cbsds{i}.demands, cbsds{i}.available_chns);
    cbsds{i}.min_demand = min(cbsds{i}.demands);
end

%% Construct conflict graphs
% Initialize carrier-sensing and interference graphs (diagonal entries are set to 0).
[int_adj_matrix, cs_adj_matrix] = initialize_cs_int_adj_matrix(settings, cbsds);

% Initialize NC pair list as cell
[nc_pairs, nodes_to_ncp, ncp_to_nodes, clusters] = initialize_nc_pairs(settings, cbsds);

% Relate NC pair index to (node_idx, chns) through hashes and Map objects.
map = containers.Map();
for i = 1:length(nc_pairs)
    map(data_hash([nc_pairs{i}.node_idx, nc_pairs{i}.chns])) = nc_pairs{i}.idx;
end

if settings.super_node_enabled
    % Initialize super NC pairs as cell
    [super_nc_pairs, nodes_to_super_ncp] = generate_super_nc_pairs(settings, cbsds, nc_pairs, cs_adj_matrix);
    
    % For binary conflict graphs, super-NC pairs are added to the graph.
    if strcmp(settings.mode, 'binary')
        nc_pairs_all = [nc_pairs, super_nc_pairs];   % Merge NC pairs and super-NC pairs
        nodes_to_ncp_all = cell(1,length(cbsds));
        for i = 1:length(cbsds)
            nodes_to_ncp_all{i} = [nodes_to_ncp{i}, nodes_to_super_ncp{i}];
        end
        
        %------------ Test on Dec 9 ------------
        %nc_pairs_all = nc_pairs;
        %nodes_to_ncp_all = nodes_to_ncp;
        %---------------------------------------
    else
        nc_pairs_all = nc_pairs;
        nodes_to_ncp_all = nodes_to_ncp;
    end   
else
    super_nc_pairs = [];
    nc_pairs_all = nc_pairs;
    nodes_to_ncp_all = nodes_to_ncp;
end

fprintf('    ===> %d nc pairs, %d snc pairs\n', length(nc_pairs), length(super_nc_pairs));

%% Initialize adjacency matrix of NC-pair conflict graph
adj_matrix = initialize_nc_pair_adj_matrix(settings, int_adj_matrix, cbsds, nc_pairs_all, nodes_to_ncp_all, settings.mode);

if settings.super_node_enabled
   adj_matrix = update_adj_matrix(adj_matrix, map, super_nc_pairs); 
end

%% CA algorithms
rewards = zeros(1, length(nc_pairs_all));
cardinality = zeros(1, length(nc_pairs_all));
for nc_pair_idx = 1:length(rewards)
    rewards(nc_pair_idx) = nc_pairs_all{nc_pair_idx}.reward;
    cardinality(nc_pair_idx) = length(nc_pairs_all{nc_pair_idx}.node_idx);
end

if strcmp(settings.mode, 'binary')
    if strcmp(settings.algo_mode, 'proposed')
        I = max_reward_CA(adj_matrix, rewards, cardinality, lambda);
    elseif strcmp(settings.algo_mode, 'baseline')
        I = max_revenue_CA(adj_matrix, rewards);
    else
        error('Unknown algorithm mode');
    end
    
elseif strcmp(settings.mode, 'non-binary')
    if strcmp(settings.penalty_func, 'interference')
        max_interference = max(max(adj_matrix));
        adj_matrix = adj_matrix/max_interference;
    else
        max_interference = 0;  % Not used
    end
    
    I =  cell(1, 4);
    u = zeros(1, 4);    % utility
    r = zeros(1, 4);    % total reward
    p = zeros(1, 4);    % total penalty
    t = zeros(1, 4);    % Elapsed time
    
    fprintf('Algo 1: random\n');
    [I{1}, u(1), r(1), p(1), t(1)] = max_utility_CA_random(adj_matrix, rewards, clusters, lambda);
    
    fprintf('Algo 2: greedy\n');
    [I{2}, u(2), r(2), p(2), t(2)] = max_utility_CA_greedy(adj_matrix, rewards, clusters, ncp_to_nodes, lambda);

    epsilon = 0;
    max_iter = 1000;
    fprintf('Algo 3: submodular\n')
    [I{3}, u(3), r(3), p(3), t(3)] = max_utility_CA_submodular(adj_matrix, rewards, clusters, ncp_to_nodes, lambda, epsilon, max_iter);

    fprintf('Algo 4: tabu\n');
    [I{4}, u(4), r(4), p(4), t(4)] = max_utility_CA_tabu(adj_matrix, rewards, clusters, lambda, []);
end

%% 
result.settings = settings;
%result.cbsds = cbsds;
result.nc_pairs = nc_pairs;
result.super_nc_pairs = super_nc_pairs;
%result.adj_matrix = adj_matrix;
result.I = I;

if strcmp(settings.mode, 'non-binary')
    result.u = u;
    result.r = r;
    result.p = p;
    result.t = t;
    result.max_interference = max_interference;
end