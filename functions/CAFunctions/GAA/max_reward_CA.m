function I = max_reward_CA(adj_matrix, rewards, cardinality, lambda)

[N,M] = size(adj_matrix);

if N ~= M
    error('Adjacency matrix must be square');
end

V = 1:N;
I = -ones(1,N);

iter_id = 1;

fprintf('    Max-Reward CA: ');
progress = textprogressbar(N);

while ~isempty(V)
    progress(N-length(V));
    
    adj_matrix_temp = adj_matrix(V,V);
    rewards_temp = rewards(V);
    cardinality_temp = cardinality(V);
    
    deg = sum(adj_matrix_temp, 1);
    scores = (rewards_temp + lambda*cardinality_temp)./(deg + 1);
    
    ms = max(scores);       % Maximum score
    ms_indices = find(scores==ms);
    ms_idx = ms_indices(1); % Simply select the 1st vertex
    ms_idx_neighbors = adj_matrix_temp(ms_idx,:) == 1;
    
    idx = V(ms_idx);
    neighbors = V(ms_idx_neighbors);
    
    I(idx) = 1;
    %V = setdiff(V, [idx, neighbors]);
    
    x = zeros(1, N);
    x(V) = 1;
    x([idx, neighbors]) = 0;
    V = find(x);
    
    iter_id = iter_id + 1;
end

progress(N);

%fprintf('    ---> %d iterations\n', iter_id - 1);

I = find(I > 0);