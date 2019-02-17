% Start with the given I, and perform local search. 
function [I, u, r, p] = max_utility_CA_LS(adj_matrix, rewards, clusters, ncp_to_nodes, ...
    lambda, epsilon, max_iter, I_init)

debug = false;

N = length(clusters);

if isempty(I_init)
    % Choose the best one from the 10 random intializatins
    max_iter_init = 10;
    I_init =  cell(1, max_iter_init);
    u_init = zeros(1, max_iter_init);
    p_init = zeros(1, max_iter_init);
    for k=1:max_iter_init
        [I_init{k}, u_init(k), ~, p_init(k)] = max_utility_CA_random(adj_matrix, rewards, clusters, lambda);
    end

    [u, idx] = max(u_init);
    I = I_init{idx};
    p = p_init(idx);
else
    I = I_init;
    [u, ~, p] = compute_utility(adj_matrix, rewards, lambda, I);
end

%fprintf('    LS with initial u = %d, p = %d\n', u, p);

dispstat('','init'); %one time only init 
for k=1:max_iter
    %str = sprintf('%d ', I); 
    %str(end) = [];
    %fprintf('iter=%d, u=%.2f, I=[%s]\n', k, u, str); 
    
    flag = false;
    
    % Delete operations
    D_set = I(I>0);
    if ~isempty(D_set)
        for d = D_set
            mu = compute_marginal_utility_delete(adj_matrix, rewards, lambda, I, d);
            if (u+mu) > (1+epsilon/N^2)*u
                dispstat(sprintf('LS: Iter %d, u: %d -> %d', k, u, u+mu),'timestamp');
                
                if debug
                    fprintf('iter=%4d, deleting %d, u: %d -> %d\n', k, d, u, u+mu);
                end
                
                I(ncp_to_nodes(d)) = -1;
                u = u + mu;
                flag = true;
                break;
            end
        end
    end

    if flag == true
        continue;
    end
    
    % Add operations
    A_set = get_add_candidates(clusters, I);
    if ~isempty(A_set)
        for a = A_set
            mu = compute_marginal_utility_add(adj_matrix, rewards, lambda, I, a);
            if (u+mu) > (1+epsilon/N^2)*u
                dispstat(sprintf('LS: Iter %d, u: %d -> %d', k, u, u+mu),'timestamp');
                
                if debug
                    fprintf('iter=%4d, adding %d, u: %d -> %d\n', k, a, u, u+mu);
                end
                
                I(ncp_to_nodes(a)) = a;
                u = u + mu;
                flag = true;
                break;
            end
        end
    end
    
    if flag == true
        continue;
    end
    
    % Swap operations
    T_set = find(I>0);
    for i = 1:length(T_set) % i-th cluster
        % Swap d for a_best in cluster i
        a_best = [];
        mu_max = -inf;
        
        d = I(T_set(i));    % NC pair to delete
        S_set = get_swap_candidates(clusters, I, T_set(i));
        for a = S_set       % NC pair to add
            mu = compute_marginal_utility_swap(adj_matrix, rewards, lambda, I, a, d);
            
            if mu > mu_max
                a_best = a;
                mu_max = mu;
            end
        end
        
        if (u+mu_max) > (1+epsilon/N^2)*u
            dispstat(sprintf('LS: Iter %d, u: %d -> %d', k, u, u+mu_max),'timestamp');
            
            if debug
                fprintf('iter=%4d, swapping %d for %d in cluster %d, u: %d -> %d\n', ...
                    k, d, a, T_set(i), u, u+mu_max);
            end
            
            I(ncp_to_nodes(d)) = -1;
            I(ncp_to_nodes(a_best)) = a_best;
            u = u + mu_max;
            flag = true;
            break;
        end
    end
    
    if flag == true
        continue;
    else
        break;
    end
end

[u2, r, p] = compute_utility(adj_matrix, rewards, lambda, I);

if abs(u-u2) > 1e-10
    error('[max_utility_CA_LS] Inconsistent utility');
end
