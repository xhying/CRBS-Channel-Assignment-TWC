% For simplicity, we assume homogeneous CBSDs.

function settings = get_settings()

settings.total_num_of_chns = 15;
settings.min_demand = 1;
settings.max_demand = 4;

settings.tx_power = 30.0;       % dBm
settings.tx_ant_height = 3.0;   % meters
settings.rx_ant_height = 1.5;   % meters
settings.freq = (3550.0 + 3700.0)/2;  % MHz

settings.comm_rss = - 96.0;     % dBm
settings.cs_rss = -75.0;        % dBm, -72
settings.int_rss = -80.0;       % dBm

settings.prop_model = 'COST231';

settings.comm_radius = calculate_min_separation(settings.prop_model, settings.freq, ...
    settings.tx_power - settings.comm_rss, settings.tx_ant_height, settings.rx_ant_height);
settings.cs_radius = calculate_min_separation(settings.prop_model, settings.freq, ...
    settings.tx_power - settings.cs_rss, settings.tx_ant_height, settings.rx_ant_height);
settings.int_radius = calculate_min_separation(settings.prop_model, settings.freq, ...
    settings.tx_power - settings.int_rss, settings.tx_ant_height, settings.rx_ant_height);

% Activity index ~ U[alpha_min, alpha_min + alpha_range];
settings.alpha_min = 0;
settings.alpha_range = 4;

settings.super_node_enabled = false;

settings.reward_func = 'linear';    % 'linear' or 'log'
settings.penalty_func = 'interference';

settings.alpha_limit = 4.0;
settings.lambda = 0;

settings.algo_mode = 'proposed'; % 'proposed' or 'baseline'

% The penalty table will be used if reward function is 'capacity' 
% and the penalty function is 'capacity_reduction'.
[D_range, penalties] = get_penalty_table(settings);
settings.penalty_table.D_range = D_range;
settings.penalty_table.penalties = penalties;
