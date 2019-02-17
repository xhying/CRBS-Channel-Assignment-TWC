%BASE = './Log/GAA_CA_non_binary/';
BASE = './Log/GAA_CA_non_binary_capacity/';

num_exp = 30;

n_range = 100:50:350;
lambda_range = 10.^(0:1:7);

n = 200;
lambda = 1;

mode = 'impact_of_n';
%mode = 'impact_of_lambda';

%%
if strcmp(mode, 'impact_of_n') 
    target_range = n_range;            
elseif strcmp(mode, 'impact_of_lambda') 
    target_range = lambda_range;
else
    error('Unknown mode');
end

algos = {'random', 'greedy', 'submodular'};

p1 = cell(1, length(algos)); % Percentage of nodes serviced. 
p2 = cell(1, length(algos)); % Percentage of demand serviced.
r  = cell(1, length(algos)); % Total reward
p  = cell(1, length(algos)); % Total penalty

for i = 1:length(algos)
    p1{i} = zeros(length(target_range), num_exp);
    p2{i} = zeros(length(target_range), num_exp);
    r{i}  = zeros(length(target_range), num_exp);
    p{i}  = zeros(length(target_range), num_exp);
end

for target_id = 1:length(target_range)
    target = target_range(target_id);

    mat_file = sprintf('%s_target_%d.mat', mode, target);
    fprintf('Importing %s ...', mat_file);
    load([BASE mat_file], 'result');
    fprintf(' Done\n');

    for exp_id = 1:num_exp
        for algo_id = 1:length(algos)
            I = result{exp_id}.I{algo_id};
            nc_pairs = [result{exp_id}.nc_pairs, result{exp_id}.super_nc_pairs];
            lambda = result{exp_id}.settings.lambda;

            node_count = 0;
            demand_count = 0;
            total_reward = 0;
            for i = 1:length(I)
                if I(i) > 0
                    node_count = node_count + length(nc_pairs{I(i)}.node_idx);
                    demand_count = demand_count + length(nc_pairs{I(i)}.node_idx)*length(nc_pairs{I(i)}.chns);
                    total_reward = total_reward + (nc_pairs{I(i)}.reward + lambda*length(nc_pairs{I(i)}.node_idx));
                end
            end

            if strcmp(mode, 'impact_of_n')
                p1{algo_id}(target_id, exp_id) = node_count/target;
                p2{algo_id}(target_id, exp_id) = demand_count/(target*4); % Max. demand for each node is 4.
            else
                p1{algo_id}(target_id, exp_id) = node_count/n;
                p2{algo_id}(target_id, exp_id) = demand_count/(n*4);
            end

            r{algo_id}(target_id, exp_id) = total_reward;
            p{algo_id}(target_id, exp_id) = result{exp_id}.p(algo_id)*result{exp_id}.max_interference;
        end
    end
end

%% Figure
p1_mean = zeros(length(algos), length(target_range));
p2_mean = zeros(length(algos), length(target_range));
r_mean  = zeros(length(algos), length(target_range));
p_mean  = zeros(length(algos), length(target_range));

for algo_id = 1:length(algos)
    for target_id = 1:length(target_range)
        p1_mean(algo_id, target_id) = mean(p1{algo_id}(target_id, :));
        p2_mean(algo_id, target_id) = mean(p2{algo_id}(target_id, :));
        r_mean(algo_id, target_id)  = mean(r{algo_id}(target_id, :));
        p_mean(algo_id, target_id)  = mean(p{algo_id}(target_id, :));
    end
end

p1_mean = p1_mean*100;
p2_mean = p2_mean*100;

%% p1
if strcmp(mode, 'impact_of_lambda')
    figure1 = figure('position', [200, 200, 400, 300]);
else
    figure1 = figure('position', [200, 200, 400, 300]);
end
axes1 = axes('Parent',figure1);
hold(axes1,'on');

idx = 1:length(target_range);

%plot(target_range(idx), p1_mean(1, idx), 'MarkerSize', 15,'LineWidth',3, 'Marker','diamond', ...
%    'LineStyle',':', 'Color',[0 0 1], 'DisplayName','Random');
plot(target_range(idx), p1_mean(2, idx), 'MarkerSize', 15,'LineWidth',3, 'Marker','o', ...
    'LineStyle',':', 'Color',[0 0 0], 'DisplayName','Greedy');
plot(target_range(idx), p1_mean(3, idx), 'MarkerSize', 15,'LineWidth',3, 'Marker','^', ...
                     'Color',[1 0 0], 'DisplayName','Proposed');
                 
hold(axes1,'off');
set(axes1,'FontSize',20,'XGrid','on','YGrid','on');

xlim([min(target_range(idx)), max(target_range(idx))]);
ylabel('p_1 (%)');

legend1 = legend(axes1,'show');

if strcmp(mode, 'impact_of_n')
    ylim([0.5, 1]);
    xlabel('Num of GAA Nodes');
    set(axes1, 'XTick', target_range, 'YTick', 0.5:0.1:1);
    set(legend1,'Position', [0.4925 0.42 0.41 0.311666666666667]);
    
elseif strcmp(mode, 'impact_of_lambda')
    ylim([80, 100]);
    xlabel('Tradeoff Paramter \lambda');
    set(axes1, 'XTick', target_range);
    set(legend1,'Location', 'SouthWest');
    
    set(gca, 'XScale', 'log');
end

%% p2
if strcmp(mode, 'impact_of_lambda')
    figure2 = figure('position', [200, 200, 350, 400]);
else
    figure2 = figure('position', [200, 200, 400, 300]);
end
axes2 = axes('Parent',figure2);
hold(axes2,'on');

idx = 1:length(target_range);

%plot(target_range(idx), p2_mean(1, idx), 'MarkerSize', 15,'LineWidth',3, 'Marker','diamond', ...
%    'LineStyle',':', 'Color',[0 0 1], 'DisplayName','Random');
plot(target_range(idx), p2_mean(2, idx), 'MarkerSize', 15,'LineWidth',3, 'Marker','o', ...
    'LineStyle',':', 'Color',[0 0 0], 'DisplayName','Greedy');
plot(target_range(idx), p2_mean(3, idx), 'MarkerSize', 15,'LineWidth',3, 'Marker','^', ...
                     'Color',[1 0 0], 'DisplayName','Proposed');
                 
hold(axes2,'off');
set(axes2,'FontSize',20,'XGrid','on','YGrid','on');

xlim([min(target_range(idx)), max(target_range(idx))]);
ylabel('p_2 (%)');

legend2 = legend(axes2,'show');

if strcmp(mode, 'impact_of_n')
    ylim([0.5, 1]);
    xlabel('Num of GAA Nodes');
    set(axes2, 'XTick', target_range, 'YTick', 0.5:0.1:1);
    set(legend2,'Position', [0.4925 0.42 0.41 0.311666666666667]);
    
elseif strcmp(mode, 'impact_of_lambda')
    ylim([80, 100]);
    xlabel('Tradeoff Paramter \lambda');
    set(axes2, 'XTick', target_range, 'YTick', 80:5:100);
    set(legend2, 'Location', 'SouthWest');
    
    set(gca, 'XScale', 'log');
end

%% p
if strcmp(mode, 'impact_of_lambda')
    figure3 = figure('position', [200, 200, 400, 300]);
else
    figure3 = figure('position', [200, 200, 400, 300]);
end
axes3 = axes('Parent',figure3);
hold(axes3,'on');

idx = 1:length(target_range);

%plot(target_range(idx), p_mean(1, idx), 'MarkerSize', 15,'LineWidth',3, 'Marker','diamond', ...
%    'LineStyle',':', 'Color',[0 0 1], 'DisplayName','Random');
plot(target_range(idx), p_mean(2, idx), 'MarkerSize', 15,'LineWidth',3, 'Marker','o', ...
    'LineStyle',':', 'Color',[0 0 0], 'DisplayName','Baseline');
plot(target_range(idx), p_mean(3, idx), 'MarkerSize', 15,'LineWidth',3, 'Marker','^', ...
                     'Color',[1 0 0], 'DisplayName','Proposed');

hold(axes3,'off');
set(axes3,'FontSize',20,'XGrid','on','YGrid','on');

xlim([min(target_range(idx)), max(target_range(idx))]);
ylabel('Total Interference');

legend3 = legend(axes3,'show');

if strcmp(mode, 'impact_of_n')
    ylim([1e-8, 1e-05]);
    xlabel('Num of GAA Nodes n');
    set(axes3, 'XTick', target_range);
    %set(legend2,'Position', [0.4925 0.42 0.41 0.311666666666667]);
    set(axes3, 'YMinorTick','on','YScale','log','YTick', [1e-08 1e-07 1e-06 1e-05]);
    set(legend3, 'Location', 'NorthWest');
    
elseif strcmp(mode, 'impact_of_lambda')
    ylim([1e-12, 1e-6]);
    xlabel('Tradeoff Paramter \lambda');
    set(axes3, 'XTick', target_range);
    set(axes3, 'YMinorTick','on','YScale','log','YTick', 10.^(-12:1:-6));
    set(legend3, 'Location', 'SouthWest');
    
    set(gca, 'XScale', 'log');
end

set(gca, 'YScale', 'log');