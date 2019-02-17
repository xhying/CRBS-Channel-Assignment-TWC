% Get swap candidates for the i-th cluster (one must already be selected).
function S_set = get_swap_candidates(clusters, I, cluster_idx)
    if I(cluster_idx) < 0
        error('[get_swap_candidates] error in swap: one must be selected.');
    else
        S_set = clusters{cluster_idx}(clusters{cluster_idx} ~= I(cluster_idx));
        
        if length(S_set) == length(clusters{cluster_idx})
            error('[get_swap_candidates] error: I(i) must already be in the i-th cluster');
        end
    end
end