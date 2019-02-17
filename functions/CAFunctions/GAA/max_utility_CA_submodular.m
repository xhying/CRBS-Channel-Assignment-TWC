function [I, u, r, p, t] = max_utility_CA_submodular(adj_matrix, rewards, clusters, ncp_to_nodes, ...
    lambda, epsilon, max_iter)
start_time = tic();

% 1st round
[I_1, ~, ~, ~] = max_utility_CA_greedy(adj_matrix, rewards, clusters, ncp_to_nodes, lambda);
[I_1, u_1, ~, p_1] = max_utility_CA_LS(adj_matrix, rewards, clusters, ncp_to_nodes, ...
    lambda, epsilon, max_iter, I_1);

% 2nd round: exclude I_1 from clusters
clusters2 = clusters;
for i=1:length(I_1)
    clusters2{i}(clusters2{i}==I_1(i)) = [];
end

[I_2, ~, ~, ~] = max_utility_CA_greedy(adj_matrix, rewards, clusters2, ncp_to_nodes, lambda);
[I_2, u_2, ~, p_2] = max_utility_CA_LS(adj_matrix, rewards, clusters2, ncp_to_nodes, ...
    lambda, epsilon, max_iter, I_2);

%fprintf('1st round: u_1 = %d, p_1 = %d\n', u_1, p_1);
%fprintf('2nd round: u_2 = %d, p_2 = %d\n', u_2, p_2);

if u_1 > u_2
    I = I_1;
    [u, r, p] = compute_utility(adj_matrix, rewards, lambda, I);
else
    I = I_2;
    [u, r, p] = compute_utility(adj_matrix, rewards, lambda, I);
end

t = toc(start_time);