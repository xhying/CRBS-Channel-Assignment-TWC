graph_mode = 'non-binary';
%exp_mode = 'impact_of_radius';
exp_mode = 'impact_of_lambda';

LOG_BASE = './Log/nonbinary_GAA_CA_capacity/';

num_exp = 30;

radius_range = 0.4:0.2:1.2;
cs_thr_range = -80:2:-70;
alpha_limit_range = 0:1:5;
lambda_range = 0.8:0.1:1.2; %10.^(0:0.5:3);

radius = 0.8;
cs_thr = -75;
alpha_limit = 4;
lambda = 1;

%%
if strcmp(exp_mode, 'impact_of_radius') 
    target_range = radius_range;
    num_of_cases = 1; % Linear, w/o coex
    case_id_linear_no_coex = 1;
elseif strcmp(exp_mode, 'impact_of_lambda') 
    target_range = lambda_range;
    num_of_cases = 1;
    case_id_linear_no_coex = 1;
else
    error('Unknown mode');
end

% 'random', 'greedy', 'submodular'
num_of_algos = 4;
random_id = 1;
greedy_id = 2;
submodular_id = 3;
tabu_id = 4;

baseline_id = 1;

p1 = cell(num_of_algos, num_of_cases); % Percentage of nodes serviced. 
p2 = cell(num_of_algos, num_of_cases); % Percentage of demand serviced.
r  = cell(num_of_algos, num_of_cases); % Total reward
p  = cell(num_of_algos, num_of_cases); % Total penalty
u  = cell(num_of_algos, num_of_cases); % Total utility
int = cell(num_of_algos, num_of_cases); % Total interference
int_reduction = cell(num_of_algos, num_of_cases); % Interferece reduction w.r.t. to the random algorithm.

for i = 1:num_of_algos
    for j=1:num_of_cases
        p1{i,j} = zeros(length(target_range), num_exp);
        p2{i,j} = zeros(length(target_range), num_exp);
        r{i,j} = zeros(length(target_range), num_exp);
        p{i,j} = zeros(length(target_range), num_exp);
        u{i,j} = zeros(length(target_range), num_exp);
        int{i,j} = zeros(length(target_range), num_exp);
        int_reduction{i,j} = zeros(length(target_range), num_exp);
    end
end 

for target_id = 1:length(target_range)
    target = target_range(target_id);

    mat_file = sprintf('%s_%s_target_%.1f.mat', graph_mode, exp_mode, target);
    fprintf('Importing %s ...', mat_file);
    load([LOG_BASE mat_file], 'result');
    fprintf(' Done\n');

    for exp_id = 1:num_exp
        for case_id = 1:num_of_cases
            for algo_id = 1:num_of_algos
                result_tmp = result{exp_id,case_id};
                I = result_tmp.I{algo_id};
                nc_pairs = [result_tmp.nc_pairs, result_tmp.super_nc_pairs];
                lambda = result_tmp.settings.lambda;

                node_count = 0;
                demand_count = 0;
                total_reward = 0;
                for i = 1:length(I)
                    if I(i) > 0
                        node_count = node_count + length(nc_pairs{I(i)}.node_idx);
                        demand_count = demand_count + length(nc_pairs{I(i)}.node_idx)*length(nc_pairs{I(i)}.chns);
                    end
                end

                if strcmp(exp_mode, 'impact_of_radius')
                    radius = target_range(target_id);
                end

                n = result_tmp.settings.num_of_GAA_nodes;

                p1{algo_id, case_id}(target_id, exp_id) = node_count/n;
                p2{algo_id, case_id}(target_id, exp_id) = demand_count/(n*result_tmp.settings.max_demand);
                r{algo_id,  case_id}(target_id, exp_id) = result_tmp.r(algo_id);
                p{algo_id,  case_id}(target_id, exp_id) = result_tmp.p(algo_id);
                u{algo_id,  case_id}(target_id, exp_id) = result_tmp.u(algo_id);
                int{algo_id,  case_id}(target_id, exp_id) = result_tmp.p(algo_id)*result_tmp.max_interference;
            end
            
            for algo_id=1:num_of_algos
                int_reduction{algo_id, case_id}(target_id, exp_id) = ...
                    (int{algo_id, case_id}(target_id, exp_id) - int{baseline_id, case_id}(target_id, exp_id))/int{baseline_id, case_id}(target_id, exp_id);
            end
            
        end
    end
end

%%
p1_mean = cell(1,num_of_algos);
p2_mean = cell(1,num_of_algos);
r_mean = cell(1,num_of_algos);
p_mean = cell(1,num_of_algos);
u_mean = cell(1,num_of_algos);
int_mean = cell(1,num_of_algos);
int_reduction_mean = cell(1,num_of_algos);

for i=1:num_of_algos
    p1_mean{i} = zeros(num_of_cases, length(target_range));
    p2_mean{i} = zeros(num_of_cases, length(target_range));
    r_mean{i} = zeros(num_of_cases, length(target_range));
    p_mean{i} = zeros(num_of_cases, length(target_range));
    u_mean{i} = zeros(num_of_cases, length(target_range));
    int_mean{i} = zeros(num_of_cases, length(target_range));
    int_reduction_mean{i} = zeros(num_of_cases, length(target_range));
end

for algo_id=1:num_of_algos
    for case_id=1:num_of_cases
        for target_id=1:length(target_range)
            p1_mean{algo_id}(case_id, target_id) = mean(p1{algo_id, case_id}(target_id, :))*100;
            p2_mean{algo_id}(case_id, target_id) = mean(p2{algo_id, case_id}(target_id, :))*100;
            r_mean{algo_id}(case_id, target_id) = mean(r{algo_id, case_id}(target_id, :));
            p_mean{algo_id}(case_id, target_id) = mean(p{algo_id, case_id}(target_id, :));
            u_mean{algo_id}(case_id, target_id) = mean(u{algo_id, case_id}(target_id, :));
            int_mean{algo_id}(case_id, target_id) = mean(int{algo_id, case_id}(target_id, :));
            int_reduction_mean{algo_id}(case_id, target_id) = mean(int_reduction{algo_id, case_id}(target_id, :));
        end
    end
end

%% Figure 1 - Utility
figure1 = figure('position', [200, 200, 400, 300]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');

idx = 1:length(target_range);

if strcmp(exp_mode, 'impact_of_radius')
    % Baseline: random, linear, w/o coex
    plot(target_range(idx), u_mean{1}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
        'LineStyle',':', 'Color', 'black', 'DisplayName','Random');
    % Greedy
%     plot(target_range(idx), u_mean{2}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','^', ...
%         'LineStyle','-', 'Color', 'green', 'DisplayName','Greedy');
    % Proposed: submodular, linear, w/o coex
    plot(target_range(idx), u_mean{3}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','^', ...
        'LineStyle','-', 'Color', 'red', 'DisplayName','Max-Utility');
    % Proposed: tabu, linear, w/o coex
%     plot(target_range(idx), u_mean{4}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','^', ...
%         'LineStyle','-', 'Color', 'blue', 'DisplayName','Tabu');
    
elseif strcmp(exp_mode, 'impact_of_lambda')
    % Baseline: random, linear, w/o coex
    plot(idx, u_mean{1}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
        'LineStyle',':', 'Color', 'black', 'DisplayName','Random');
    % Proposed: submodular, linear, w/o coex
    plot(idx, u_mean{3}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','^', ...
        'LineStyle','-', 'Color', 'red', 'DisplayName','Max-Utility');
end

hold(axes1,'off');
set(axes1,'FontSize',20,'XGrid','on','YGrid','on');

ylabel('Avg Utility');

legend1 = legend(axes1,'show');

if strcmp(exp_mode, 'impact_of_radius')
    xlim([min(target_range(idx)), max(target_range(idx))]);
    %ylim([0, 1000]);
    xlabel('Radius r (km)');
    set(axes1, 'XTick', target_range);
    %set(axes1, 'YTick', 0:200:1000);
    set(legend1, 'Position', [0.197500042021274 0.778333333333334 0.2775 0.148333333333333],...
        'FontSize', 16);
    
elseif strcmp(exp_mode, 'impact_of_lambda')
    %ylim([1e-7, 10^(-5.9)]);
    xlabel('Tradeoff Parameter \lambda');
    set(axes1, 'XTick', idx, 'XTickLabel', {'0.8','0.9','1.0','1.1','1.2'});
    ax=gca; ax.YAxis.Exponent = 4;
    %set(axes1, 'YTick');
    set(legend1, 'Position',[0.6275 0.783333333333333 0.2775 0.141666666666667],...
        'FontSize',16);
end

%% Figure 2 - Interference
figure1 = figure('position', [200, 200, 400, 300]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');

idx = 1:length(target_range);

if strcmp(exp_mode, 'impact_of_radius')
    % Baseline: random, linear, w/o coex
    plot(target_range(idx), int_mean{1}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
        'LineStyle',':', 'Color', 'black', 'DisplayName','Random');
    % Proposed: submodular, linear, w/o coex
    plot(target_range(idx), int_mean{3}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','^', ...
        'LineStyle','-', 'Color', 'red', 'DisplayName','Max-Utility');
    % Proposed: tabu, linear, w/o coex
%     plot(target_range(idx), int_mean{4}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','^', ...
%         'LineStyle','-', 'Color', 'blue', 'DisplayName','Proposed, w/o coex');
    
elseif strcmp(exp_mode, 'impact_of_lambda')
    % Baseline: random, linear, w/o coex
    plot(idx, int_mean{1}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
        'LineStyle',':', 'Color', 'black', 'DisplayName','Random');
    % Proposed: submodular, linear, w/o coex
    plot(idx, int_mean{3}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','^', ...
        'LineStyle','-', 'Color', 'red', 'DisplayName','Max-Utility');
end

hold(axes1,'off');
set(axes1,'FontSize',20,'XGrid','on','YGrid','on');

ylabel('Avg Total Interference');

legend1 = legend(axes1,'show');

if strcmp(exp_mode, 'impact_of_radius')
    xlim([min(target_range(idx)), max(target_range(idx))]);
    %ylim([0, 1000]);
    xlabel('Radius r (km)');
    set(axes1, 'XTick', target_range);
    %set(axes1, 'YTick', 0:200:1000);
    set(legend1, 'Position', [0.157500042021274 0.751666666666667 0.2775 0.148333333333333],...
        'FontSize', 16);

elseif strcmp(exp_mode, 'impact_of_lambda')
    xlim([1,7]);
    xlabel('Tradeoff Parameter \lambda');
    set(axes1, 'XTick',[1 2 3 4 5 6 7],'XTickLabel',...
    {'10^0','10^{0.5}','10^{1}','10^{1.5}','10^{2}','10^{2.5}','10^{3}'});
    set(axes1, 'YMinorTick','on','YScale','log');
    set(legend1, 'Position',[0.6275 0.78 0.2775 0.141666666666667],'FontSize',16);
end


%% Compute interference reduction between the proposed (submodular) and baseline (greedy) algorithms.
baseline_id = tabu_id;
proposed_id = submodular_id;

int_reduction = zeros(length(target_range), num_exp);

for target_id=1:length(target_range)
    for exp_id=1:num_exp
        interference_baseline = int{baseline_id, case_id_linear_no_coex}(target_id, exp_id);
        interference_proposed = int{proposed_id, case_id_linear_no_coex}(target_id, exp_id);
        int_reduction(target_id, exp_id) = (interference_proposed - interference_baseline)./interference_baseline*100;
    end
end

%% Plot interference reduction
plot_mode = 'boxplot'; 

figure1 = figure('position', [200, 200, 400, 300]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');

if strcmp(plot_mode, 'boxplot')
    hlc = boxplot(-int_reduction', 'Widths', 0.3);
    for ih=1:6
        set(hlc(ih,:),'LineWidth',2);
    end

    hold(axes1,'off');
    set(axes1,'FontSize',20, 'XGrid','on','YGrid','on');
    %ylim([0, 100]);
    %set(axes1, 'YScale','log');
    
    if strcmp(exp_mode, 'impact_of_radius')
        xlabel('Radius r (km)');
    elseif strcmp(exp_mode, 'impact_of_lambda')
        xlabel('Trade-off parameter \lambda');
    end
    ylabel('Interference Reduction (%)');
elseif strcmp(plot_mode, 'lineplot')
    if strcmp(exp_mode, 'impact_of_radius')
        plot(target_range, mean(-int_reduction, 2));
    elseif strcmp(exp_mode, 'impact_of_lambda')

    end
    hold(axes1,'off');
    set(axes1,'FontSize',20, 'XGrid','on','YGrid','on','YScale','log');
    %ylim([0,40]);
    xlabel('Radius r (km)');
    ylabel('Interference Reduction (%)');
end


%% p1
if strcmp(mode, 'impact_of_lambda')
    figure1 = figure('position', [200, 200, 400, 300]);
else
    figure1 = figure('position', [200, 200, 400, 300]);
end
axes1 = axes('Parent',figure1);
hold(axes1,'on');

idx = 1:length(target_range);

if strcmp(exp_mode, 'impact_of_radius')
    % Baseline: random, linear, w/o coex
    plot(target_range(idx), p1_mean{1}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
        'LineStyle',':', 'Color', 'black', 'DisplayName','Random');
    % Proposed: submodular, linear, w/o coex
    plot(target_range(idx), p1_mean{3}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','^', ...
        'LineStyle','-', 'Color', 'red', 'DisplayName','Max-Utility');
    % Proposed: tabu, linear, w/o coex
%     plot(target_range(idx), int_mean{4}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','^', ...
%         'LineStyle','-', 'Color', 'blue', 'DisplayName','Proposed, w/o coex');
    
elseif strcmp(exp_mode, 'impact_of_lambda')
    % Baseline: random, linear, w/o coex
    plot(idx, p1_mean{1}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
        'LineStyle',':', 'Color', 'black', 'DisplayName','Random');
    % Proposed: submodular, linear, w/o coex
    plot(idx, p1_mean{3}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','^', ...
        'LineStyle','-', 'Color', 'red', 'DisplayName','Max-Utility');
end
                 
hold(axes1,'off');
set(axes1,'FontSize',20,'XGrid','on','YGrid','on');

xlim([min(target_range(idx)), max(target_range(idx))]);
ylabel('p_1 (%)');

legend1 = legend(axes1,'show');

if strcmp(exp_mode, 'impact_of_radius')
    %xlim([min(target_range), max(target_range)]);
    ylim([99.8, 100]);
    xlabel('Radius r (km)');
    set(axes1, 'XTick', target_range);
    set(legend1, 'Position', [0.157500042021274 0.751666666666667 0.2775 0.148333333333333],...
        'FontSize', 16);

elseif strcmp(exp_mode, 'impact_of_lambda')
    xlim([1,7]);
    xlabel('Tradeoff Parameter \lambda');
    set(axes1, 'XTick',[1 2 3 4 5 6 7],'XTickLabel',...
    {'10^0','10^{0.5}','10^{1}','10^{1.5}','10^{2}','10^{2.5}','10^{3}'});
    set(legend1, 'Position',[0.6275 0.78 0.2775 0.141666666666667],'FontSize',16);
end

%% p2
if strcmp(mode, 'impact_of_lambda')
    figure2 = figure('position', [200, 200, 400, 300]);
else
    figure2 = figure('position', [200, 200, 400, 300]);
end
axes2 = axes('Parent',figure2);
hold(axes2,'on');

idx = 1:length(target_range);

if strcmp(exp_mode, 'impact_of_radius')
    % Baseline: random, linear, w/o coex
    plot(target_range(idx), p1_mean{1}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
        'LineStyle',':', 'Color', 'black', 'DisplayName','Random');
    % Proposed: submodular, linear, w/o coex
    plot(target_range(idx), p1_mean{3}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','^', ...
        'LineStyle','-', 'Color', 'red', 'DisplayName','Max-Utility');
    % Proposed: tabu, linear, w/o coex
%     plot(target_range(idx), int_mean{4}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','^', ...
%         'LineStyle','-', 'Color', 'blue', 'DisplayName','Proposed, w/o coex');
    
elseif strcmp(exp_mode, 'impact_of_lambda')
    % Baseline: random, linear, w/o coex
    plot(idx, p2_mean{1}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','o', ...
        'LineStyle',':', 'Color', 'black', 'DisplayName','Random');
    % Proposed: submodular, linear, w/o coex
    plot(idx, p2_mean{3}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','^', ...
        'LineStyle','-', 'Color', 'red', 'DisplayName','Max-Utility');
end
                 
hold(axes2,'off');
set(axes2,'FontSize',20,'XGrid','on','YGrid','on');

xlim([min(target_range(idx)), max(target_range(idx))]);
ylabel('p_2 (%)');

legend2 = legend(axes2,'show');

if strcmp(exp_mode, 'impact_of_radius')
    %xlim([min(target_range), max(target_range)]);
    %ylim([0, 1000]);
    xlabel('Radius r (km)');
    set(axes2, 'XTick', target_range);
    set(legend2, 'Position', [0.157500042021274 0.751666666666667 0.2775 0.148333333333333],...
        'FontSize', 16);

elseif strcmp(exp_mode, 'impact_of_lambda')
    xlim([1,7]);
    xlabel('Tradeoff Parameter \lambda');
    set(axes2, 'XTick',[1 2 3 4 5 6 7],'XTickLabel',...
    {'10^0','10^{0.5}','10^{1}','10^{1.5}','10^{2}','10^{2.5}','10^{3}'});
    set(legend2, 'Position',[0.6275 0.78 0.2775 0.141666666666667],'FontSize',16);
end

%% p1 and p2
if strcmp(mode, 'impact_of_lambda')
    figure2 = figure('position', [200, 200, 400, 300]);
else
    figure2 = figure('position', [200, 200, 400, 300]);
end
axes2 = axes('Parent',figure2);
hold(axes2,'on');

idx = 1:length(target_range);

if strcmp(exp_mode, 'impact_of_radius')
    % p1: submodular, linear, w/o coex
    plot(target_range(idx), p1_mean{3}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','v', ...
        'LineStyle',':', 'Color', 'blue', 'DisplayName','p_1');
    % p2: submodular, linear, w/o coex
    plot(target_range(idx), p2_mean{3}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','^', ...
        'LineStyle','-', 'Color', 'red', 'DisplayName','p_2');
    
elseif strcmp(exp_mode, 'impact_of_lambda')
    % p1: submodular, linear, w/o coex
    plot(idx, p1_mean{3}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','v', ...
        'LineStyle',':', 'Color', 'blue', 'DisplayName','p_1');
    % p2: submodular, linear, w/o coex
    plot(idx, p2_mean{3}(1, idx), 'MarkerSize', 10,'LineWidth',3, 'Marker','^', ...
        'LineStyle','-', 'Color', 'red', 'DisplayName','p_2');
end
                 
hold(axes2,'off');
set(axes2,'FontSize',20,'XGrid','on','YGrid','on');

xlim([min(target_range(idx)), max(target_range(idx))]);
ylabel('Percentage');

legend2 = legend(axes2,'show');

if strcmp(exp_mode, 'impact_of_radius')
    %xlim([min(target_range), max(target_range)]);
    %ylim([0, 1000]);
    xlabel('Radius r (km)');
    set(axes2, 'XTick', target_range);

elseif strcmp(exp_mode, 'impact_of_lambda')
    xlim([1,7]);
    xlabel('Tradeoff Parameter \lambda');
    set(axes2, 'XTick',[1 2 3 4 5 6 7],'XTickLabel',...
    {'10^0','10^{0.5}','10^{1}','10^{1.5}','10^{2}','10^{2.5}','10^{3}'});
end


