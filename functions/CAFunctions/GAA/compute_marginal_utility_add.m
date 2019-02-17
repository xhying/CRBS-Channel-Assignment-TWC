% mu = u(I+{a}) - u(I) = r(a) - \sum_{s\in I} [p(a,s) + p(s,a)]
% a is NC pair index
function mu = compute_marginal_utility_add(adj_matrix, rewards, lambda, I, a)
    I_set = I(I>0);     % Index set of selected NC paris
    mr = rewards(a);    % marginal reward
    mp = sum(adj_matrix(a, I_set)) + sum(adj_matrix(I_set, a));    
    mu = mr - lambda*mp;
end