graph_mode = 'binary';
exp_mode = 'impact_of_radius';
%exp_mode = 'impact_of_lambda';
%exp_mode = 'impact_of_alpha_limit';

LOG_BASE = './Log/binary_GAA_CA/';

num_exp = 30;

radius_range = 0.4:0.2:1.2;
cs_thr_range = -80:2:-70;
alpha_limit_range = 0:1:5;
lambda_range = 0:2:8;

radius = 0.8;
cs_thr = -75;
alpha_limit = 4;
lambda = 0;

%%
if strcmp(exp_mode, 'impact_of_radius') 
    target_range = radius_range;
    algo_num = 5;
             
elseif strcmp(exp_mode, 'impact_of_lambda') 
    target_range = lambda_range;
    algo_num = 4;
             
elseif strcmp(exp_mode, 'impact_of_alpha_limit')
    target_range = alpha_limit_range;
    algo_num = 2;
    
else
    error('Unknown mode');
end

%%
p1 = cell(1, algo_num); % Percentage of nodes serviced. 
p2 = cell(1, algo_num); % Percentage of demand serviced.
r =  cell(1, algo_num); % Total reward

for i = 1:algo_num
    p1{i} = zeros(length(target_range), num_exp);
    p2{i} = zeros(length(target_range), num_exp);
    r{i}  = zeros(length(target_range), num_exp);
end

for target_id = 1:length(target_range)
    target = target_range(target_id);

    mat_file = sprintf('%s_%s_target_%.1f.mat', graph_mode, exp_mode, target);
    fprintf('Importing %s ...', mat_file);
    load([LOG_BASE mat_file], 'result');
    fprintf(' Done\n');

    for exp_id = 1:num_exp
        for algo_id = 1:algo_num
            result_tmp = result{exp_id,algo_id};
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

            if strcmp(exp_mode, 'impact_of_radius')
                radius = target_range(target_id);
            end
            
            n = result{exp_id, algo_id}.settings.num_of_GAA_nodes;

            p1{algo_id}(target_id, exp_id) = node_count/n;
            p2{algo_id}(target_id, exp_id) = demand_count/(n*result{exp_id,algo_id}.settings.max_demand);

            r{algo_id}(target_id, exp_id) = total_reward;
        end
    end
end

%% Compute statistics
p1_mean = zeros(algo_num, length(target_range));
p2_mean = zeros(algo_num, length(target_range));
r_mean  = zeros(algo_num, length(target_range));

for algo_id = 1:algo_num
    for target_id = 1:length(target_range)
        p1_mean(algo_id, target_id) = mean(p1{algo_id}(target_id, :));
        p2_mean(algo_id, target_id) = mean(p2{algo_id}(target_id, :));
        r_mean(algo_id, target_id)  = mean(r{algo_id}(target_id, :));
    end
end

p1_mean = p1_mean*100;
p2_mean = p2_mean*100;

%% p1
figure1 = figure('position', [200, 200, 400, 300]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');

idx = 1:length(target_range);

if strcmp(exp_mode, 'impact_of_radius')
    % radius = 0.4  0.6  0.8  1.0  1.2
    % Linear w/o coex, Log w/o coex, Linear w/ coex, Linear w/ coex, baseline

    % p1_mean = 
    %   73.7265   74.7247   74.5589   72.7494   72.6421
    %   91.6568   92.0826   91.1513   90.5159   90.6248
    %   83.3622   82.3736   82.5659   81.4546   81.7236
    %   91.6911   92.1836   91.4248   90.8677   91.3477
    %   66.9753   67.5774   67.9831   65.9894   65.9150
    
    % w/ coex
    plot(target_range(idx), p1_mean(3, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','x', ...
        'LineStyle','-.', 'Color', 'red', 'DisplayName','Linear w/ coex');
    plot(target_range(idx), p1_mean(4, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
        'LineStyle','-', 'Color', 'red', 'DisplayName','Log w/ coex');
                     
    % w/o coex
    plot(target_range(idx), p1_mean(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','x', ...
        'LineStyle','-.', 'Color', 'blue', 'DisplayName','Linear, w/o coex');
    plot(target_range(idx), p1_mean(2, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
        'LineStyle','-', 'Color', 'blue', 'DisplayName','Log, w/o coex');
    
    plot(target_range(idx), p1_mean(5, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','^', ...
        'LineStyle',':', 'Color', 'black', 'DisplayName','Baseline (MRA)');
    
elseif strcmp(exp_mode, 'impact_of_lambda')
    % p1_mean = 
    %   74.5589   93.4161   99.7443   99.9087  100.0000
    %   91.1513   99.8799  100.0000  100.0000  100.0000
    %   82.5659   92.3561   98.4977   99.2513   99.6589
    %   91.4248   98.9573   99.8366   99.8545   99.8545
    
    % w/ coex
    plot(target_range(idx), p1_mean(3, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','x', ...
        'LineStyle','-.', 'Color', 'red', 'DisplayName','Linear w/ coex');
    plot(target_range(idx), p1_mean(4, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
        'LineStyle','-', 'Color', 'red', 'DisplayName','Log w/ coex');
                     
    % w/o coex
    plot(target_range(idx), p1_mean(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','x', ...
        'LineStyle','-.', 'Color', 'blue', 'DisplayName','Linear, w/o coex');
    plot(target_range(idx), p1_mean(2, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
        'LineStyle','-', 'Color', 'blue', 'DisplayName','Log, w/o coex');
    
elseif strcmp(exp_mode, 'impact_of_alpha_limit')
    % p1_mean =
    %   74.5589   82.5659   90.4492   90.8821   90.9866   90.9866
    %   91.1513   91.4248   94.0484   94.4181   94.5857   94.5857
   
    % w/ coex
    plot(target_range(idx), p1_mean(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','x', ...
                         'Color', 'red', 'DisplayName','Linear, w/ coex');
    plot(target_range(idx), p1_mean(2, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
                         'Color', 'red', 'DisplayName','Log, w/ coex');
                     
    % No coexistence with radius=0.8, lambda=0
    p1_baseline = ones(2, length(target_range));
    p1_baseline(1, :) = p1_baseline(1, :)*p1_mean(1,1); % linear 
    p1_baseline(2, :) = p1_baseline(2, :)*p1_mean(2,1); % log
    
    plot(target_range(idx), p1_baseline(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','x', ...
        'LineStyle',':', 'Color', 'blue', 'DisplayName','Linear, w/o coex');
    plot(target_range(idx), p1_baseline(2, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
        'LineStyle',':', 'Color', 'blue', 'DisplayName','Log, w/o coex');    
end
                 
hold(axes1,'off');
set(axes1,'FontSize',20,'XGrid','on','YGrid','on');

xlim([min(target_range(idx)), max(target_range(idx))]);
ylabel('Avg p_1 (%)');

legend1 = legend(axes1,'show');

if strcmp(exp_mode, 'impact_of_radius')
    ylim([20, 100]);
    xlabel('Radius r (km)');
    set(axes1, 'XTick', target_range);
    set(legend1,'Position', [0.195000042170286 0.19 0.4 0.353333333333333],...
        'FontSize',16);
    
elseif strcmp(exp_mode, 'impact_of_lambda')
    ylim([70, 100]);
    xlabel('Tradeoff Paramter \lambda');
    %set(axes1, 'XTick', target_range);
    set(legend1,'Position', [0.4675 0.193333333333334 0.4375 0.311666666666667],...
        'FontSize',18);
    
elseif strcmp(exp_mode, 'impact_of_alpha_limit')
    ylim([50, 100]);
    xlabel('Sum Activity Index Limit  ');
    set(axes1, 'XTick', target_range);
    set(legend1,'Position',[0.195 0.19 0.43625 0.305],'FontSize',18);
    
    annotation(figure1,'textbox', [0.84 0.043 0.114 0.0433333333333332],... %[0.681 0.34 0.114 0.0433333333333333],...
        'String',{'$\bar{\alpha}$'},...
        'LineStyle','none',...
        'FontSize',20,...
        'FitBoxToText','off', ...
        'Interpreter','latex');
end

%% p2
figure2 = figure('position', [200, 200, 400, 300]);
axes2 = axes('Parent',figure2);
hold(axes2,'on');

idx = 1:length(target_range);

if strcmp(exp_mode, 'impact_of_radius')
    % p2_mean = 
    %   71.2596   71.5602   71.5403   69.6146   69.4046
    %   65.8490   65.3417   64.8337   62.8302   62.5256
    %   80.9963   79.7571   79.9182   78.7764   78.9780
    %   77.5949   75.3313   75.6679   74.0271   74.5439
    %   64.4608   64.5852   65.0493   63.0410   62.9762
    
    % w/ coex
    plot(target_range(idx), p2_mean(3, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','x', ...
        'LineStyle','-.', 'Color', 'red', 'DisplayName','Linear w/ coex');
    plot(target_range(idx), p2_mean(4, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
        'LineStyle','-', 'Color', 'red', 'DisplayName','Log w/ coex');
                     
    % w/o coex
    plot(target_range(idx), p2_mean(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','x', ...
        'LineStyle','-.', 'Color', 'blue', 'DisplayName','Linear, w/o coex');
    plot(target_range(idx), p2_mean(2, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
        'LineStyle','-', 'Color', 'blue', 'DisplayName','Log, w/o coex');
    
    plot(target_range(idx), p2_mean(5, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','^', ...
        'LineStyle',':', 'Color', 'black', 'DisplayName','Baseline (MRA)');
    
elseif strcmp(exp_mode, 'impact_of_lambda')
    % p2_mean = 
    %   71.5403   63.6663   53.4711   46.3540   42.7740
    %   64.8337   47.9076   39.5632   37.2076   35.4153
    %   79.9182   75.4718   67.0860   60.0754   55.4688
    %   75.6679   61.1906   52.5334   49.0849   46.9555
    
    % w/ coex
    plot(target_range(idx), p2_mean(3, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','x', ...
        'LineStyle','-.', 'Color', 'red', 'DisplayName','Linear w/ coex');
    plot(target_range(idx), p2_mean(4, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
        'LineStyle','-', 'Color', 'red', 'DisplayName','Log w/ coex');
                     
    % w/o coex
    plot(target_range(idx), p2_mean(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','x', ...
        'LineStyle','-.', 'Color', 'blue', 'DisplayName','Linear, w/o coex');
    plot(target_range(idx), p2_mean(2, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
        'LineStyle','-', 'Color', 'blue', 'DisplayName','Log, w/o coex');

elseif strcmp(exp_mode, 'impact_of_alpha_limit')
    % p2_mean =
    %   71.5403   79.9182   88.4730   88.8796   88.9957   88.9957
    %   64.8337   75.6679   85.1431   85.7122   85.8514   85.8514
    
    % w/ coex
    plot(target_range(idx), p2_mean(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','x', ...
                         'Color', 'red', 'DisplayName','Linear, w/ coex');
    plot(target_range(idx), p2_mean(2, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
                         'Color', 'red', 'DisplayName','Log, w/ coex');
                     
    % No coexistence with n=200, lambda=0
    p2_baseline = ones(2, length(target_range));
    p2_baseline(1, :) = p2_baseline(1, :)*p2_mean(1,1); % linear
    p2_baseline(2, :) = p2_baseline(2, :)*p2_mean(2,1); % log
    
    plot(target_range(idx), p2_baseline(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','x', ...
        'LineStyle',':', 'Color', 'blue', 'DisplayName','Linear, w/o coex');
    plot(target_range(idx), p2_baseline(2, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
        'LineStyle',':', 'Color', 'blue', 'DisplayName','Log, w/o coex');
end
                 
hold(axes2,'off');
set(axes2,'FontSize',20,'XGrid','on','YGrid','on');

xlim([min(target_range(idx)), max(target_range(idx))]);
ylabel('Avg p_2 (%)');

legend2 = legend(axes2,'show');

if strcmp(exp_mode, 'impact_of_radius')
    ylim([20, 100]);
    xlabel('Radius r (km)');
    set(axes2, 'XTick', target_range);
    set(legend2, 'Position', [0.197500042170286 0.19 0.4 0.353333333333333],...
        'FontSize',16);
    
elseif strcmp(exp_mode, 'impact_of_lambda')
    ylim([30, 100]);
    xlabel('Tradeoff Paramter \lambda');
    %set(axes2, 'XTick', target_range);
    set(legend2, 'Position', [0.50625 0.65 0.39875 0.271666666666667],...
        'FontSize',16);

elseif strcmp(exp_mode, 'impact_of_alpha_limit')
    ylim([20, 100]);
    xlabel('Sum Activity Index Limit');
    set(axes2, 'XTick', target_range);
    set(legend2, 'Position', [0.195 0.19 0.43625 0.305],'FontSize',18);
    
    annotation(figure2,'textbox', [0.84 0.043 0.114 0.0433333333333332],... %[0.681 0.34 0.114 0.0433333333333333],...
        'String',{'$\bar{\alpha}$'},...
        'LineStyle','none',...
        'FontSize',20,...
        'FitBoxToText','off', ...
        'Interpreter','latex');
end

