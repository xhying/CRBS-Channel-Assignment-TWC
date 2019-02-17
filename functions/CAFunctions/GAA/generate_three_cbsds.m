function cbsds = generate_three_cbsds(settings, is_debug)
    num = 3;
    cbsds = cell(1,num);

    cbsds{1}.loc = [40.6870, -74.4040];
    cbsds{2}.loc = [40.6870, -74.4030];
    cbsds{3}.loc = [40.6840, -74.4000];
    
    if is_debug
        fprintf('Dist(1, 2) = %.4f\n', get_distance(cbsds{1}.loc, cbsds{2}.loc));
        fprintf('Dist(1, 3) = %.4f\n', get_distance(cbsds{1}.loc, cbsds{3}.loc));
        fprintf('Dist(2, 3) = %.4f\n', get_distance(cbsds{2}.loc, cbsds{3}.loc));
    end

    for i = 1:length(cbsds)
       cbsds{i}.available_chns = 1:1:settings.total_num_of_chns;    % Must be in ascending order
       cbsds{i}.assigned_chns = [];
       cbsds{i}.demands = [1,2,3,4];
       cbsds{i}.activity_index = i*0.1;
       cbsds{i}.coex_enabled = true;
       cbsds{i}.reward_func = settings.reward_func;
       cbsds{i}.penalty_func = settings.penalty_func;
    end
end