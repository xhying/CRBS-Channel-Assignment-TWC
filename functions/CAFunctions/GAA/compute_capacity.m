% Compute the capcity of cbsd1 given the interference from cbsd2.
function capacity = compute_capacity(nc_pair1, cbsd1, nc_pair2, cbsd2, settings)

if isempty(nc_pair1) || isempty(cbsd1)
    error('Error: incorrect input to compute_capacity()');
end

if isempty(nc_pair2) && isempty(cbsd2)
    % Compute the interference-free capacity of cbsd1
    P_tx = 10.0^(cbsd1.tx_power/10)/(10*1e6); % Transmit power, mW/Hz; tx_power is dBm/10 MHz
    num_of_chns = length(nc_pair1.chns); % # of 10 MHz channels
    W_0 = 10*1e6; % Bandwidth, Hz
    N_0 = 10.0^(-174/10); % Thermal noise, mW/Hz
    
    R = settings.comm_radius;
    
    % Discretize the circular region with points.
    r_range = R/3:R/3:R;
    theta_range = pi/4:pi/4:2*pi;
    C = zeros(length(r_range), length(theta_range)); % Capacity (bits/sec) at each point
    
    for i=1:length(r_range)
        r = r_range(i); % Dist between the CBSD and its client
        
        for j=1:length(theta_range)
            path_loss = calculate_path_loss(settings.prop_model, settings.freq, ...
                r, cbsd1.tx_ant_height, cbsd1.rx_ant_height); % Assume the client uses the same Rx ant height with the CBSD.
            P_rx = P_tx/(10^(path_loss/10))*W_0; % Total received power (linear) in the assigned channel(s) of bandwidth W. 
            C(i,j) = num_of_chns*W_0*log2(1 + P_rx/(N_0*W_0)); % Overall capacity is the sum of the capacity in all channels. 
        end
    end

    capacity = mean(mean(C))/1e6; % Mbits/sec
    
elseif ~isempty(nc_pair2) && ~isempty(cbsd2)
    % Compute the capacity of cbsd1 in the presence of interference.
    D = sqrt(sum((cbsd1.loc - cbsd2.loc).^2)); % in km
    W_0 = 10*1e6; % Bandwidth, Hz
    N_0 = 10.0^(-174/10); % Thermal noise, mW/Hz
    
    P_tx1 = 10.0^(cbsd1.tx_power/10)/(10*1e6); % Transmit power of cbsd1, mW/Hz
    num_of_chns = length(nc_pair1.chns); 
    
    P_tx2 = 10.0^(cbsd2.tx_power/10)/(10*1e6); % Transmit power of cbsd2, mW/Hz
    num_of_overlapping_chns = length(intersect(nc_pair1.chns, nc_pair2.chns));
    num_of_nonoverlapping_chns = num_of_chns - num_of_overlapping_chns;
    
    R = settings.comm_radius;
    
    % Discretize the circular region with points.
    r_range = R/3:R/3:R;
    theta_range = pi/4:pi/4:2*pi;
    C = zeros(length(r_range), length(theta_range)); % Capacity (bits/sec) at each point
    
    for i=1:length(r_range)
        r = r_range(i);
        
        for j=1:length(theta_range)
            theta = theta_range(j);
            
            % Assuming that cbsd1 is at (0,0), the location of cbsd2 is (D, 0).
            x = r*cos(theta);
            y = r*sin(theta);
            dist = sqrt((D-x)^2+y^2); % Distance between cbsd2 and cbsd1's client, in km
            
            % Compute received power in each 10 MHz channel
            path_loss1 = calculate_path_loss(settings.prop_model, settings.freq, ...
                r, cbsd1.tx_ant_height, cbsd2.rx_ant_height);
            P_rx = P_tx1/(10^(path_loss1/10))*W_0; % Total received power (linear) in the assigned channel(s)
            
            % Compute interference in each 10 MHz channel
            path_loss2 = calculate_path_loss(settings.prop_model, settings.freq, ...
                dist, cbsd2.tx_ant_height, cbsd1.rx_ant_height);
            I = P_tx2/(10^(path_loss2/10))*W_0; 
            
            C(i,j) = num_of_nonoverlapping_chns*W_0*log2(1 + P_rx/(N_0*W_0)) ...
                   + num_of_overlapping_chns*W_0*log2(1 + P_rx/(N_0*W_0+I));
        end
    end
    
    capacity = mean(mean(C))/1e6; % Mbits/sec
    
else
    error('Error: compute_capacity input undefined');
end

