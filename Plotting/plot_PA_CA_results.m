%%
exp_mode = 'impact_of_area_width';
exp_mode = 'impact_of_radius';
%exp_mode = 'impact_of_PAL_chn_num';

load(sprintf('./Log/PA_CA/%s.mat', exp_mode));

%%
r = zeros(size(result));
r_baseline = zeros(size(result));

for i=1:length(result(:,1))
    for j=1:length(result(1,:))
        r(i,j) = result{i,j}.ratio;
        r_baseline(i,j) = result{i,j}.ratio_baseline;
    end 
end

%%
figure1 = figure('position', [200, 200, 400, 300]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');

plot(mean(r, 2)','MarkerSize',16,'Marker','diamond','LineWidth',3,'Color', 'red', ...
    'DisplayName','Max-Cardinality CA');
plot(mean(r_baseline, 2)','MarkerSize',16,'Marker','x','LineStyle','--', ...
    'LineWidth',3,'Color', 'black', 'DisplayName','Baseline (npSMC)');

if strcmp(exp_mode, 'impact_of_radius')
    %xlabel('Radius of Coverage Area');
    xlabel('Radius r_s');
elseif strcmp(exp_mode, 'impact_of_PAL_chn_num')
    xlabel('Num of PAL Chns');
elseif strcmp(exp_mode, 'impact_of_area_width')
    xlabel('Area Width m');
else
    error('Error: unknown mode');
end

ylabel('p');

if strcmp(exp_mode, 'impact_of_radius')
    xlim(axes1,[1 length(r(:,1))]);
    ylim(axes1,[0.499 1.001]);
    set(axes1,'FontSize',25,'XGrid','on', 'YGrid','on',...
        'XTick',1:length(r(:,1)), 'XTickLabel', 0.4:0.2:1.4,...
        'YTick',0.5:0.1:1, 'YTickLabel', 0.5:0.1:1);

elseif strcmp(exp_mode, 'impact_of_PAL_chn_num')
    xlim(axes1,[1 length(r(:,1))]);
    ylim(axes1,[0.5 1]);
    set(axes1,'FontSize',25,'XGrid','on', 'YGrid','on', ...
        'XTick',1:length(r(:,1)), 'XTickLabel', 7:12,...
        'YTick',0.5:0.1:1, 'YTickLabel', 0.5:0.1:1);

elseif strcmp(exp_mode, 'impact_of_area_width')
    xlim(axes1,[1 length(r(:,1))]);
    ylim(axes1,[0.5 1]);
    set(axes1,'FontSize',25,'XGrid','on', 'YGrid','on', ...
        'XTick',1:length(r(:,1)), 'XTickLabel', 5:5:30,...
        'YTick',0.5:0.1:1, 'YTickLabel', 0.5:0.1:1);
    
else
    error('Error: unknown mode');
end

hold(axes1,'off');

legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.340357142857143 0.233333333333334 0.565714285714286 0.161666666666667],...
    'FontSize',18);

%%