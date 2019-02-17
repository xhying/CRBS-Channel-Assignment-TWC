function [u, r, p] = compute_utility(adj_matrix, rewards, lambda, I)
I = I(I>0);

r = sum(rewards(I));               % total reward
p = sum(sum(adj_matrix(I, I)));    % total penalty

u = r - lambda*p;