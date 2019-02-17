function dist = get_distance(loc1, loc2)
src_lat = loc1(1);
src_lng = loc1(2);

dst_lat = loc2(1);
dst_lng = loc2(2);

theta = src_lng - dst_lng;
dist = sin(deg2rad(src_lat)) * sin(deg2rad(dst_lat)) + ...
    cos(deg2rad(src_lat)) * cos(deg2rad(dst_lat)) * cos(deg2rad(theta));

dist = rad2deg(acos(dist)) * 111.1896;