function M = initialize_nc_pair_adj_matrix(settings, int_adj_matrix, cbsds, nc_pairs_all, nc_pair_catalog_all, mode)
total_num_of_chns = settings.total_num_of_chns;

M = zeros(length(nc_pairs_all), length(nc_pairs_all));

if strcmp(mode, 'binary')
    fprintf('    Initializing adj_matrix: ');
    udp = textprogressbar(length(cbsds));
    
    for node_i = 1:length(cbsds)
        udp(node_i);
        
        for node_j = node_i:length(cbsds)
            nc_pair_idx_vec_i = nc_pair_catalog_all{node_i};
            nc_pair_idx_vec_j = nc_pair_catalog_all{node_j};
            
            if node_i == node_j
                % One-channel-assignment-per-node constraint
                for i = 1:length(nc_pair_idx_vec_i)
                    for j = i:length(nc_pair_idx_vec_j)
                        nc_pair_i_idx = nc_pair_idx_vec_i(i);
                        nc_pair_j_idx = nc_pair_idx_vec_j(j);
                        M(nc_pair_i_idx, nc_pair_j_idx) = 1;
                        M(nc_pair_j_idx, nc_pair_i_idx) = 1;
                    end
                end
            else
                % Interference constraint: if two nodes interference, check their NC pairs
                if int_adj_matrix(node_i, node_j) > 0
                    for nc_pair_i_idx = nc_pair_catalog_all{node_i}
                        for nc_pair_j_idx = nc_pair_catalog_all{node_j}
                            nc_pair_i = nc_pairs_all{nc_pair_i_idx};
                            nc_pair_j = nc_pairs_all{nc_pair_j_idx};

                            x = zeros(1, total_num_of_chns);
                            y = zeros(1, total_num_of_chns);
                            x(nc_pair_i.chns) = 1;
                            y(nc_pair_j.chns) = 1;
                            
                            if max(x + y) > 1
                                M(nc_pair_i_idx, nc_pair_j_idx) = 1;
                                M(nc_pair_j_idx, nc_pair_i_idx) = 1;
                            end
                        end
                    end
                end
            end
        end 
    end
    
elseif strcmp(mode, 'non-binary')
    fprintf('    Initializing adj_matrix: ');
    udp = textprogressbar(length(cbsds));

    for node_i = 1:length(cbsds)
        udp(node_i);

        for node_j = (node_i+1):length(cbsds)

            % Assign penalites to edges.
            if int_adj_matrix(node_i, node_j) > 0
                for nc_pair_i_idx = nc_pair_catalog_all{node_i}
                    for nc_pair_j_idx = nc_pair_catalog_all{node_j}
                        nc_pair_i = nc_pairs_all{nc_pair_i_idx};
                        nc_pair_j = nc_pairs_all{nc_pair_j_idx};

                        x = zeros(1, total_num_of_chns);
                        y = zeros(1, total_num_of_chns);
                        x(nc_pair_i.chns) = 1;
                        y(nc_pair_j.chns) = 1;

                        if strcmp(settings.penalty_func, 'interference')
                            overlapping_chn_count = sum((x+y)>1);

                            if overlapping_chn_count > 0
                                M(nc_pair_i_idx, nc_pair_j_idx) = int_adj_matrix(node_i, node_j)*overlapping_chn_count;
                                M(nc_pair_j_idx, nc_pair_i_idx) = M(nc_pair_i_idx, nc_pair_j_idx);
                            end
                            
                        elseif strcmp(settings.penalty_func, 'capacity_reduction')
                            overlapping_chn_count = sum((x+y)>1);

                            if overlapping_chn_count > 0
                                % Penalty on node j due to node i.
                                chn_count = length(nc_pair_j.chns);
                                
                                if isfield(settings, 'penalty_table')
                                    D = pdist2(cbsds{node_i}.loc, cbsds{node_j}.loc);
                                    
                                    if D > max(settings.penalty_table.D_range)
                                        M(nc_pair_i_idx, nc_pair_j_idx) = 0;
                                    else
                                        [~, idx] = min(abs(D - settings.penalty_table.D_range));
                                        M(nc_pair_i_idx, nc_pair_j_idx) = settings.penalty_table.penalties{chn_count, overlapping_chn_count}(idx);
                                    end
                                else
                                    M(nc_pair_i_idx, nc_pair_j_idx) = compute_penalty(nc_pair_i, cbsds{node_i}, nc_pair_j, cbsds{node_j}, settings);
                                    % ---- test ----
                                    %tmp = compute_penalty(nc_pair_i, cbsds{node_i}, nc_pair_j, cbsds{node_j}, settings);
                                    %fprintf('diff 1 = %.2f\n', (M(nc_pair_i_idx, nc_pair_j_idx)-tmp));
                                end

                                % Penalty on node i due to node j.
                                chn_count = length(nc_pair_i.chns);
                                
                                if isfield(settings, 'penalty_table')
                                    D = pdist2(cbsds{node_i}.loc, cbsds{node_j}.loc);
                                    
                                    if D > max(settings.penalty_table.D_range)
                                        M(nc_pair_j_idx, nc_pair_i_idx) = 0;
                                    else
                                        [~, idx] = min(abs(D - settings.penalty_table.D_range));
                                        M(nc_pair_j_idx, nc_pair_i_idx) = settings.penalty_table.penalties{chn_count, overlapping_chn_count}(idx);
                                    end
                                else
                                    M(nc_pair_j_idx, nc_pair_i_idx) = compute_penalty(nc_pair_j, cbsds{node_j}, nc_pair_i, cbsds{node_i}, settings);
                                    % ---- test ----
                                    %tmp = compute_penalty(nc_pair_j, cbsds{node_j}, nc_pair_i, cbsds{node_i}, settings);
                                    %fprintf('diff 2 = %.2f\n', (M(nc_pair_j_idx, nc_pair_i_idx)-tmp));
                                end
                            end

                        else
                            error('Error: Unknown penalty function');
                        end
                    end
                end
            end
        end
    end 
else
    error('[initialize_nc_pair_adj_matrix] Unknown mode');
end
