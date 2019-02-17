% This function computes Haversine distance.

function [d_m, d_km] = computeDist(lat1, lon1, lat2, lon2)
R = 6371000;
phi_1 = degtorad(lat1);
phi_2 = degtorad(lat2);
phi_delta = degtorad(lat2 - lat1);
lambda_delta = degtorad(lon2 - lon1);
a = sin(phi_delta/2) * sin(phi_delta/2) + cos(phi_1) * cos(phi_2) * sin(lambda_delta/2) * sin(lambda_delta/2);
c = 2 * atan2(sqrt(a), sqrt(1-a)); 
d_m = R * c;
d_km = d_m/1000;