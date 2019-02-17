% This function imports NYC Wi-Fi location dataset and exports a subset
% that contains Wi-Fi locations within a circular region.

load('./Data/NYC_Free_Public_WiFi_03292017.mat');

plot_flag = false;
save_flag = true;

%%
% Center: OBJECTID = 3026
% [lat,lon] = [40.7425484,-73.9932092]

center = [40.7425484,-73.9932092]; % OBJECTID = 3026
radius_range = [0.4,0.6,0.8,1,1.2]; % in km

num_of_nodes = zeros(1,length(radius_range));
WiFi_coordinates = cell(1,length(radius_range));
WiFi_locations = cell(1,length(radius_range));

for radius_idx=1:length(radius_range)
    radius_km = radius_range(radius_idx);
    fprintf('Processing locations for radius = %.1f\n', radius_km);
    
    XX = []; % LAT
    YY = []; % LON
    dist_max = 0;
    XX_max = 0;
    YY_max = 0;
    
    indices = [];
    
    for i=1:length(LAT)
        [~, dist_km] = computeDist(LAT(i), LON(i), center(1), center(2));

        if dist_km < radius_km
            XX(end+1) = LAT(i);
            YY(end+1) = LON(i);
            indices(end+1) = i;

            if dist_km > dist_max
                dist_max = dist_km;
                XX_max = LAT(i);
                YY_max = LON(i);
            end
        end
    end
    
    fprintf('The farthest point is (%.2f, %.2f) with a dist of %.2f\n', XX_max, YY_max, dist_max);
    
    num_of_nodes(radius_idx) = length(indices);
    WiFi_coordinates{radius_idx} = zeros(length(indices), 2);
    WiFi_locations{radius_idx} = zeros(length(indices), 2);
    
    for i=1:length(indices)
        idx = indices(i);
        WiFi_coordinates{radius_idx}(i,:) = [LAT(idx),LON(idx)];
        [x,y] = computeXY(center, [LAT(idx),LON(idx)]);
        WiFi_locations{radius_idx}(i,:) = [x,y];
    end
    
    if plot_flag
        figure;
        hold on;
        scatter(LON,LAT,10);
        scatter(YY,XX,20,'k','filled');
        scatter(center(2), center(1), 30, 'r', 'filled');
        hold off;
        
        xlim([-74.0335253456221 -73.9519585253456]);
        ylim([40.7118613138686 40.7709854014599]);
    end
    
    if save_flag
        fid = fopen(sprintf('./Data/NYC_WiFi_locations_radius_%.1f.csv', radius_km), 'w');
        fprintf(fid, 'OBJECTID,LAT,LON\n');
        for i=1:length(indices)
            idx = indices(i);
            fprintf(fid, '%d,%.8f,%.8f\n', OBJECTID(idx),LAT(idx),LON(idx));
        end
        fclose(fid);
    end
end

save('./Data/NYC_WiFi_locations.mat', 'WiFi_coordinates', 'WiFi_locations', ...
    'center', 'radius_range', 'num_of_nodes');




