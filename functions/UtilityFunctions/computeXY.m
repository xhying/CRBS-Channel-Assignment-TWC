function [x, y] = computeXY(origin, point)

% point: (lat, lon)
[~, x] = computeDist(origin(1), origin(2), origin(1), point(2));
if (origin(2) > point(2))
    x = -x;
end
[~, y] = computeDist(origin(1), origin(2), point(1), origin(2));
if (origin(1) > point(1))
    y = -y;
end