function [I_matrix, C_matrix] = initialize_cs_int_adj_matrix(settings, cbsds)

n = length(cbsds);

% Interference adjancy matrix (diagonal entries are 0)
I_matrix = zeros(n, n); % No interference by default
C_matrix = zeros(n, n); % No interference by default

% min_path_loss = calculate_path_loss(settings.freq, 0.1, settings.tx_ant_height, settings.rx_ant_height);
% max_interference = 10.0^((settings.tx_power - min_path_loss)/10.0); 

% Homogeneous nodes
for i = 1:n
    for j = (i+1):n
        % Check if two nodes interfere
        dist = pdist2(cbsds{i}.loc, cbsds{j}.loc);
        
        if strcmp(settings.mode, 'binary')
            if dist < (settings.comm_radius + settings.int_radius)
                % The (i,j)-th entry of I_matrix is the interference of i at j.
                path_loss = calculate_path_loss(settings.prop_model, settings.freq, ...
                    dist, settings.tx_ant_height, settings.rx_ant_height);

                I_matrix(i,j) = 10.0^((settings.tx_power - path_loss)/10);    % Interference (linear)
                I_matrix(j,i) = I_matrix(i,j);
            end
        elseif strcmp(settings.mode, 'non-binary') % Note: there is always interference. 
            path_loss = calculate_path_loss(settings.prop_model, settings.freq, ...
                dist, settings.tx_ant_height, settings.rx_ant_height);

            I_matrix(i,j) = 10.0^((settings.tx_power - path_loss)/10);    % Interference (linear)
            I_matrix(j,i) = I_matrix(i,j);
        end
        
        % Check if two nodes are within each other carrier sense range
        if dist < settings.cs_radius
            C_matrix(i,j) = 1; 
            C_matrix(j,i) = 1;
        end
    end
end