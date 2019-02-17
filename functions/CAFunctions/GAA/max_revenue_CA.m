function I = max_revenue_CA(adj_matrix, rewards)    

[N,M] = size(adj_matrix);

if N ~= M
    error('Adjacency matrix must be square');
end

V = 1:N;
I = -ones(1,N);

iter_id = 1;

fprintf('    Max-Revenue CA: ');
progress = textprogressbar(N);

while ~isempty(V)
    progress(N-length(V));
    
    adj_matrix_temp = adj_matrix(V,V);
    scores = rewards(V); %% Key difference: Select the one with the maximum incremental revenue.
    
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