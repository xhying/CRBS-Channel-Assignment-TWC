function plot_cbsds(cbsds, area_width, radius1, radius2)
figure1 = figure('position', [0, 0, 600, 600]);
axes1 = axes('Parent',figure1);
hold(axes1,'on');

for i = 1:length(cbsds)
    scatter(cbsds{i}.loc(1), cbsds{i}.loc(2), 25, 'k', 'fill');
    viscircles(cbsds{i}.loc, radius1, 'Color', 'r');
    viscircles(cbsds{i}.loc, radius2, 'Color', 'b');
end

set(axes1,'DataAspectRatio',[1 1 1],'FontSize',25,'XTick', 0:1:area_width,...
'YTick', 0:1:area_width);
hold(axes1,'off');

axis image;

xlim(axes1,[0, area_width]);
ylim(axes1,[0, area_width]);