% Generate n CBSDs randomly distributed in a L-by-L area.
function cbsds = generate_cbsds(settings, n, L, seed)
    rng(seed);
    cbsds = cell(1,n);
    
    for i = 1:n
        cbsds{i}.loc = rand(1,2)*L;
        cbsds{i}.available_chns = ones(1, settings.total_num_of_chns);  % All are available
        cbsds{i}.assigned_chns = zeros(1, settings.total_num_of_chns);  % None is assigned
        cbsds{i}.demands = [1,2,3,4];
        cbsds{i}.alpha = rand()*settings.alpha_range + settings.alpha_min;
    end
end