function S_set = get_add_candidates(clusters, I)
    A_set = find(I<=0);   % Indices of nodes without a NC pair selected.

    num = 0;
    for i=1:length(A_set)
        num = num + length(clusters{A_set(i)});
    end

    S_set = zeros(1, num);
    idx = 0;
    for i=1:length(A_set)
        S_set(idx+1:idx+length(clusters{A_set(i)})) = clusters{A_set(i)};
        idx = idx + length(clusters{A_set(i)});
    end
end