% This function computes the penalty on n2 due to n1. 
function penalty = compute_penalty(nc_pair1, cbsd1, nc_pair2, cbsd2, settings)

if isempty(intersect(nc_pair1.chns, nc_pair2.chns))
    % If assigned channels do not overlap, then there is no penalty.
    % Only consider co-channel interference here. 
    penalty = 0;
else
    if strcmp(settings.penalty_func, 'interference')
        % Check if two nodes interfere
        dist = pdist2(cbsd1.loc, cbsd2.loc);

        if dist < (settings.comm_radius + settings.int_radius)
            % The (i,j)-th entry of I_matrix is the interference of i at j.
            path_loss = calculate_path_loss(settings.prop_model, settings.freq, ...
                dist, settings.tx_ant_height, settings.rx_ant_height);
            penalty = 10.0^((cbsd1.tx_power - path_loss)/10); % Interference (linear)
        else
            penalty = 0;
        end
    elseif strcmp(settings.penalty_func, 'capacity_reduction')
        c_without_inteference = compute_capacity(nc_pair2, cbsd2, [], [], settings);
        c_with_inteference = compute_capacity(nc_pair2, cbsd2, nc_pair1, cbsd1, settings);
        penalty = c_without_inteference - c_with_inteference; 
    else
        error('Unknown penalty mode');
    end
end