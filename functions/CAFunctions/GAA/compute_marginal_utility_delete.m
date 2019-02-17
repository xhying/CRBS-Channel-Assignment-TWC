% mu = u(I-{d}) - u(I) = -[u(I) - u(I-{d})]
function mu = compute_marginal_utility_delete(adj_matrix, rewards, lambda, I, d)
    I(I==d) = -1;   % Remove d from I.
    mu = -compute_marginal_utility_add(adj_matrix, rewards, lambda, I, d);
end