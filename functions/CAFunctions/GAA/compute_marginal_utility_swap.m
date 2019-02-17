% mu = u(I-{d}+{a}) - u(I) = [u(I-{d}+{a}) - u(I-{d})] - [u(I) - u(I-{d})];
function mu = compute_marginal_utility_swap(adj_matrix, rewards, lambda, I, a, d)
    I(I==d) = -1;   % Remove d from I.
    mu = compute_marginal_utility_add(adj_matrix, rewards, lambda, I, a) ...
       - compute_marginal_utility_add(adj_matrix, rewards, lambda, I, d);
end