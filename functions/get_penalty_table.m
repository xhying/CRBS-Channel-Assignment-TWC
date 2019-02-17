% This function pre-computes capacity reduction as penalty. 
function [D_range, penalties] = get_penalty_table(settings)

settings.reward_func = 'capacity';
settings.penalty_func = 'capacity_reduction';

% Row - # of assigned channels 
% Col - # of overlapping channels
penalties = cell(settings.max_demand, settings.max_demand);

for i = 1:settings.max_demand % # of assigned channels
    for j = 1:settings.max_demand % # of overlapping channels
        nc_pair1.chns = 1:i;
        cbsd1.tx_power = settings.tx_power; % in dBm
        cbsd1.tx_ant_height = settings.tx_ant_height; % in m
        cbsd1.rx_ant_height = settings.rx_ant_height; % in m
        cbsd1.loc = [0,0]; % in km
        
        nc_pair2.chns = 1:j; % -> Interfering CBSD
        cbsd2.tx_power = settings.tx_power; % in dBm
        cbsd2.tx_ant_height = settings.tx_ant_height; % in m
        cbsd2.rx_ant_height = settings.rx_ant_height; % in m
        
        D_range = 0:0.01:0.5; % in km
        penalties{i,j} = zeros(1, length(D_range));
        
        for k = 1:length(D_range)
            cbsd2.loc = [0, D_range(k)];
            penalties{i,j}(k) = compute_penalty(nc_pair2, cbsd2, nc_pair1, cbsd1, settings);
        end
    end
end