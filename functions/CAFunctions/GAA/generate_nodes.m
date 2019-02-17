% Generate nodes from the censustract list
% n: # of node or service areas
% The topology has to be a 'grid'.

function node_list = generate_nodes(tract_list, n, iter_max, radius, seed, plot_flag)
%fprintf('\n------------------ Generating Nodes --------------------\n');
rng(seed);

PAL_count = 7*ones(1, length(tract_list));  % Max 7 PALs per tract
PAL_max = 4;            % Max # of PALs per service area is 4.
res = 0.02;             % Resolution of points for approximating a tract.

%-----------------------------------------
node_list = {};

width = sqrt(length(tract_list));
tract_topo = zeros(width, width);

for i=width:-1:1
    for j=1:width
        tract_topo(i,j) = (width-i)*width + j;
    end
end

% A square tract is represented by points along the borders.
tract_points = [];

x = res;
for y = res:res:(1-res)
    tract_points = [tract_points; x, y];
end

x = 1-res;
for y = res:res:(1-res)
    tract_points = [tract_points; x, y];
end

y = res;
for x = res*2:res:1-res*2
    tract_points = [tract_points; x, y];
end

y = 1-res;
for x = res*2:res:1-res*2
    tract_points = [tract_points; x, y];
end

% Represent each tract with points
tract_pos = cell(1, length(tract_list));

for ii=1:width
   for jj=1:width
       tract_id = tract_topo(width-jj+1, ii);

       tract_pos{tract_id} = tract_points;
       tract_pos{tract_id}(:,1) = tract_pos{tract_id}(:,1) + (ii-1);
       tract_pos{tract_id}(:,2) = tract_pos{tract_id}(:,2) + (jj-1);
   end
end

% The goal is to find up to n nodes/service areas within iter_max trials. 
for iter_id = 1:iter_max
    clearvars node;

    % # of PALs per node is uniformly selected from {1,2,3,4}
    k = randi([1, PAL_max], 1);
    
    % Service area center is a random point in the entire region.
    center_x = rand()*width;
    center_y = rand()*width;

    % Get all tracts that intersect with the circular service area.
    included_tracts = [];

    % Loop over all tracts
    for i = 1:length(tract_pos)
        flag = 0;
        
        % Determine if any border point is within the service area.
        for j = 1:length(tract_pos{i}(:,1))
            point_x = tract_pos{i}(j, 1);
            point_y = tract_pos{i}(j, 2);

            dist = sqrt((center_x-point_x)^2 + (center_y-point_y)^2);

            if dist <= radius
                flag = 1;
                break
            end
        end

        if flag == 1
            included_tracts = [included_tracts, i];
        end
    end

    % Check if all intersected tracts have k available PAL chns.
    if min(PAL_count(included_tracts)) >= k
        node.num = k;
        node.tracts = included_tracts;
        node.center = [center_x, center_y];
        node.radii = radius;
        
        node_list = [node_list, node];
        
        PAL_count(included_tracts) = PAL_count(included_tracts) - k;
    end
    
    if length(node_list) == n
        break;
    end
end

% Check a few things
PAL_count2 = zeros(1, length(tract_list));
PAL_per_node = zeros(1, length(node_list));
Size_per_node = zeros(1, length(node_list));

for i = 1:length(node_list)
    node = node_list{i};
    for j = 1:length(node.tracts)
        PAL_count2(node.tracts(j)) = PAL_count2(node.tracts(j)) + node.num;
    end
    PAL_per_node(i) = node.num;
    Size_per_node(i) = length(node.tracts);
end

if max(PAL_count2) > 7
    Error('\t PAL limit of 7 exceeded.\n');
end

fprintf('Generated %d/%d nodes --> PALs: total=%d, max=%d, avg=%.2f. Size: max=%d, min=%d, avg=%2f\n', ...
    length(node_list), n, sum(PAL_count2), max(PAL_per_node), mean(PAL_per_node), ...
    max(Size_per_node), min(Size_per_node), mean(Size_per_node));

%fprintf('----------------------------------------------------------\n');

if plot_flag
    plot_tracts(tract_pos, width, node_list);
end

