function plot_tracts(tract_pos, width, node_list)
    figure1 = figure('position', [0, 0, 600, 600]);
    axes1 = axes('Parent',figure1);
    hold(axes1,'on');
    
    % Draw tracts
    for i = 1:length(tract_pos)
        scatter(tract_pos{i}(:,1), tract_pos{i}(:,2), 25, 'k', 'fill');
    end
    
    % Write tract ID
    for i = 1:length(tract_pos)
        text(tract_pos{i}(1,1) + 0.85, tract_pos{i}(1,2) + 0.5, ...
            sprintf('%d', i), 'HorizontalAlignment','right', 'FontSize', 14);
    end
    
    % Draw circular service areas
    for i = 1:length(node_list)
        node = node_list{i};
        viscircles(node.center, node.radii);
    end
    
    set(axes1,'DataAspectRatio',[1 1 1],'FontSize',25,'XTick', 0:1:width,...
    'YTick', 0:1:width);
    hold(axes1,'off');
    
    axis image;
    
    xlim(axes1,[0 width]);
    ylim(axes1,[0 width]);
end