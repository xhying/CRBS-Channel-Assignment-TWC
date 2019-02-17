function [I, u, r, p, t] = max_utility_CA_random(adj_matrix, rewards, clusters, lambda)
start_time = tic;

% Randomly select a NC pair from each cluster i (for the i-th node). 
% Perform random CA up to max_iter times and choose the one with largest utility.
max_iter = 10000;

N = length(clusters); 
I = -ones(1, N);
u_max = 0;

fprintf('    Random: ');
udp = textprogressbar(max_iter);

for iter_id=1:max_iter
    udp(iter_id);
    
    I_tmp = -ones(1, N);
    
    for k = 1:N
        I_tmp(k) = datasample(clusters{k}, 1);
    end
    
    [u_tmp, ~, ~] = compute_utility(adj_matrix, rewards, lambda, I_tmp);
    
    if u_tmp > u_max
        u_max = u_tmp;
        I = I_tmp;
    end
end

[u, r, p] = compute_utility(adj_matrix, rewards, lambda, I);

t = toc(start_time);