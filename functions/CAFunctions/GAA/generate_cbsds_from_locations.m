% Generate n CBSDs randomly distributed in a L-by-L area.
function cbsds = generate_cbsds_from_locations(settings, locations, seed)
    n = length(locations(:,1));

    rng(seed);
    cbsds = cell(1,n);
    
    for i = 1:n
        cbsds{i}.loc = locations(i,:);
        cbsds{i}.available_chns = ones(1, settings.total_num_of_chns);  % All are available
        cbsds{i}.assigned_chns = zeros(1, settings.total_num_of_chns);  % None is assigned
        cbsds{i}.demands = settings.min_demand:1:settings.max_demand;
        cbsds{i}.alpha = rand()*settings.alpha_range + settings.alpha_min;
        cbsds{i}.tx_power = settings.tx_power;
        cbsds{i}.tx_ant_height = settings.tx_ant_height;
        cbsds{i}.rx_ant_height = settings.rx_ant_height;
    end
end