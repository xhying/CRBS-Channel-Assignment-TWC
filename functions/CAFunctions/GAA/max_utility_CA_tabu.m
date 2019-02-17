function [I, u, r, p, t] = max_utility_CA_tabu(adj_matrix, rewards, clusters, lambda, I_init)
start_time = tic();

N = length(clusters);
count_max = 1000; 
neighbor_num = 100;  % e.g., 100
tabu_limit = 0.5*neighbor_num; % e.g., 10
iter_max = 1000;

debug = true;

if isempty(I_init)
    % Start with a random assignment
    I = -ones(1,N);
    for k=1:N
        I(k) = datasample(clusters{k}, 1);
    end
else
    I = I_init;
end

[u_best, ~, ~] = compute_utility(adj_matrix, rewards, lambda, I);
I_best = I;
tabu_list = [];
count = 0;

iter_id = 1;
u_hist = zeros(1, iter_max);

fprintf('    Tabu: ');
udp = textprogressbar(iter_max);
while (iter_id <= iter_max) && (count < count_max)
    udp(iter_id);
    
    I_neighbors = ones(neighbor_num, N);
    
    for neighbor_id=1:neighbor_num
        I_neighbors(neighbor_id, :) = I; 
        
        while true
            % Pick a random cluster
            selected_cluster_id = datasample(1:N, 1);
            current_nc_pair_id = I_neighbors(neighbor_id, selected_cluster_id);
            
            % Pick a random NC pair that is different from the current one and not on the Tabu list.
            alternative_nc_pair_id = datasample(clusters{selected_cluster_id}, 1);
            if alternative_nc_pair_id ~= current_nc_pair_id
                % Check if this is on the tabu list. 
                if ~isempty(tabu_list)
                    tabu_flag = false;
                    for i=1:length(tabu_list(:,1))
                        if tabu_list(i,1) == selected_cluster_id && tabu_list(i,2) == alternative_nc_pair_id
                            tabu_flag = true;
                            break;
                        end
                    end

                    if tabu_flag == true
                        continue;
                    end
                end
                
                I_neighbors(neighbor_id, selected_cluster_id) = alternative_nc_pair_id;
                
                % Delete the oldest entry if the Tabu list is full. 
                if ~isempty(tabu_list) && length(tabu_list(:,1)) == tabu_limit
                    tabu_list(1,:) = [];
                end
                
                tabu_list = [tabu_list; selected_cluster_id, alternative_nc_pair_id];
                break; 
            else
                continue;
            end
        end
    end
    
    % Utility of all generated neighbors. 
    u_neighbors = zeros(neighbor_num, 1);
    for neighbor_id=1:neighbor_num
        [u_neighbors(neighbor_id),~,~] = compute_utility(adj_matrix, rewards, lambda, I_neighbors(neighbor_id,:));
    end
    [u_max, u_idx] = max(u_neighbors);
    I_max = I_neighbors(u_idx, :);
    
    if u_max > u_best
        u_best = u_max;
        I_best = I_max;
        count = 0;
    else
        count = count + 1;
    end
    
    I = I_max;
    
    u_hist(iter_id) = u_best;
    
    iter_id = iter_id + 1;
end

udp(iter_max);

I = I_best;
[u, r, p] = compute_utility(adj_matrix, rewards, lambda, I);

t = toc(start_time);


