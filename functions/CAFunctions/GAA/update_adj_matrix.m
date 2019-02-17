function adj_matrix = update_adj_matrix(adj_matrix, map, super_nc_pairs)

if ~isempty(super_nc_pairs)
    for k = 1:length(super_nc_pairs)
        node_idx = super_nc_pairs{k}.node_idx;
        chns = super_nc_pairs{k}.chns;

        indices = zeros(1, length(node_idx));

        for i = 1:length(node_idx)
            %fprintf('node_idx=%d, chns=[%s]\n', node_idx(i), sprintf('%d ', chns));
            indices(i) = map(data_hash([node_idx(i), chns]));
        end

        % Remove edges between member NC pairs
        for i = 1:length(indices)
            for j = (i+1):length(indices)
                adj_matrix(indices(i), indices(j)) = 0;
                adj_matrix(indices(j), indices(i)) = 0;
            end
        end
    end
end
