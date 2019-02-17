function [I, u, r, p, t] = max_utility_CA_greedy(adj_matrix, rewards, clusters, ncp_to_nodes, lambda)
start_time = tic();

N = length(clusters); 
I = -ones(1, N);    % -1 means that none is selected in that cluster.
u = 0;              % Utility

fprintf('    Greedy: ');
udp = textprogressbar(N);

for k = 1:N         % k-th step
    udp(k);
    
    S_set = get_add_candidates(clusters, I);
    
    if isempty(S_set)
        break;
    end
    
    max_mu = -inf;
    best_s = 0;
    for s = S_set
       mu = compute_marginal_utility_add(adj_matrix, rewards, lambda, I, s);
       if mu > max_mu
          max_mu = mu;
          best_s = s;
       end
    end
    
    if (u+max_mu) < u
        udp(N);
        break;
    else
        % fprintf('Adding %d, u %2.f -> %.2f\n', best_s, u, u+max_mu);
        I(ncp_to_nodes(best_s)) = best_s;   % Find the index of the node that best_s belongs to.
        u = u + max_mu;
    end
end

[u2, r, p] = compute_utility(adj_matrix, rewards, lambda, I);

if abs(u-u2) > 1e-10
    error('[max_utility_CA_greedy] Inconsistent utility');
end

t = toc(start_time);