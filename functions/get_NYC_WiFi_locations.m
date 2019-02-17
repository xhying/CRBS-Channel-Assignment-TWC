function selected_loc = get_NYC_WiFi_locations(seed, radius)
plot_flag = false;

rng(seed);
load('./Data/NYC_Free_Public_WiFi_03292017.mat', 'LAT', 'LON');

origin = [40.7425484,-73.9932092];

loc = zeros(length(LAT), 2);

for i=1:length(LAT)
    [loc(i,1), loc(i,2)] = computeXY(origin, [LAT(i),LON(i)]);
end

% S1: Randomly select a location 'center' within a circular area.
% S2: Select WiFi locations within the circular region at the 'center' with
% the specified 'radius'
tmp_center = [0,0];
tmp_radius = 1; % in km

% Randomly choose a center point from the specified region.
r = rand()*tmp_radius;
theta = rand()*2*pi;
center = [r*cos(theta), r*sin(theta)] + tmp_center;

% Select WiFi locations within a distance of 'radius' to the selected center.
X = [];
Y = [];

for i=1:length(loc(:,1))
    dist = sqrt(sum((loc(i,:)-center).^2));
    if dist <= radius
        X(end+1) = loc(i,1);
        Y(end+1) = loc(i,2);
    end
end

selected_loc = [X;Y]';

if plot_flag
    figure;
    hold on;
    scatter(loc(:,1), loc(:,2));
    
    th = 0:pi/50:2*pi;
    xunit = tmp_radius * cos(th);
    yunit = tmp_radius * sin(th);
    plot(xunit, yunit);
    
    scatter(selected_loc(:,1), selected_loc(:,2), 'r', 'fill');
    
    hold off;
    title('The region from which center will be chosen.');
    axis image;
    
    xlim([-1.5,1.5]);
    ylim([-1.5,1.5]);
end




