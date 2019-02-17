graph_mode = 'binary';
BASE = './Log/case_study/';

num_exp = 30;
target_range = [0.6,0.8,1,1.2,1.4];

algos = {'baseline','linear_no_super_nodes', 'log_no_super_nodes', ...
         'linear_with_super_nodes', 'log_with_super_nodes'};
     
load(log_file, 'result');
fprintf(' Done\n');
     
%%
p1 = cell(1, length(algos)); % Percentage of nodes serviced. 
p2 = cell(1, length(algos)); % Percentage of demand serviced.
r  = cell(1, length(algos)); % Total reward

for i = 1:length(algos)
    p1{i} = zeros(length(target_range), num_exp);
    p2{i} = zeros(length(target_range), num_exp);
    r{i}  = zeros(length(target_range), num_exp);
end

for target_id = 1:length(target_range)
    
    mat_file = sprintf('%s_target_%d.mat', graph_mode, target_range(target_id));
    fprintf('Importing %s ...', mat_file);
    load([BASE mat_file], 'result');
    fprintf(' Done\n');
    
    n = length(result{1}.baseline.settings.GAA_cbsds);

    for exp_id = 1:num_exp
        for algo_id = 1:length(algos)
            algo = algos{algo_id};

            result_tmp = eval(sprintf('result{%d}.%s', exp_id, algo));
            I = result_tmp.I;
            nc_pairs = [result_tmp.nc_pairs, result_tmp.super_nc_pairs];
            lambda = result_tmp.settings.lambda;

            node_count = 0;
            demand_count = 0;
            total_reward = 0;
            for i = 1:length(I)
                node_count = node_count + length(nc_pairs{I(i)}.node_idx);
                demand_count = demand_count + length(nc_pairs{I(i)}.node_idx)*length(nc_pairs{I(i)}.chns);
                total_reward = total_reward + (nc_pairs{I(i)}.reward + lambda*length(nc_pairs{I(i)}.node_idx));
            end

            p1{algo_id}(1, exp_id) = node_count/n;
            p2{algo_id}(1, exp_id) = demand_count/(n*4);


            r{algo_id}(1, exp_id) = total_reward;
        end
    end
end

%%
p1_mean = zeros(length(algos), 1);
p2_mean = zeros(length(algos), 1);
r_mean  = zeros(length(algos), 1);

for algo_id = 1:length(algos)
    p1_mean(algo_id) = mean(p1{algo_id}(:));
    p2_mean(algo_id) = mean(p2{algo_id}(:));
    r_mean(algo_id)  = mean(r{algo_id}(:));
end

p1_mean = p1_mean*100;
p2_mean = p2_mean*100;

%% p1
figure1 = figure('position', [200, 200, 400, 300]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');

idx = 1:length(target_range);

% w/ coex
plot(target_range(idx), p1_mean(4, idx), 'MarkerSize', 15,'LineWidth',3, 'Marker','diamond', ...
     'Color', 'red', 'DisplayName','Linear w/ coex');
plot(target_range(idx), p1_mean(5, idx), 'MarkerSize', 15,'LineWidth',3, 'Marker','o', ...
     'Color', 'red', 'DisplayName','Log w/ coex');

% w/o coex
plot(target_range(idx), p1_mean(2, idx), 'MarkerSize', 15,'LineWidth',3, 'Marker','diamond', ...
    'LineStyle',':', 'Color', 'blue', 'DisplayName','Linear, w/o coex');
plot(target_range(idx), p1_mean(3, idx), 'MarkerSize', 15,'LineWidth',3, 'Marker','o', ...
    'LineStyle',':', 'Color', 'blue', 'DisplayName','Log, w/o coex');

% Baseline
plot(target_range(idx), p1_mean(1, idx), 'MarkerSize', 15,'LineWidth',3, 'Marker','x', ...
    'LineStyle',':', 'Color', 'black', 'DisplayName','Baseline (MRA)');

hold(axes1,'off');
set(axes1,'FontSize',20,'XGrid','on','YGrid','on');

xlim([min(target_range(idx)), max(target_range(idx))]);
ylabel('p_1 (%)');

legend1 = legend(axes1,'show');

ylim([30, 100]);
xlabel('Num of GAA Nodes n');
set(axes1, 'XTick', target_range);
set(legend1,'Position', [0.196875 0.19 0.43625 0.378333333333333],...
    'FontSize',18);