function [tract_list, tract_adj_matrix] = generate_tracts(mode, width)
%fprintf('\n------------------ Generating tracts --------------------\n');

if strcmp(mode, 'manhattan')
    tract_list = [139, 133, 127, 121, 115, 111, ...
        137, 131, 125, 119, 113, 109, ...
        112.01, 104, 96, 84, ...
        112.02, 102, 94, 82, ...
        112.03, 100, 92, 80, ...
        108, 98, 90, 88, 78];
    
    tract_edge_list = [139, 137; 139, 133;
             133, 131; 133, 127;
             127, 125; 127, 121; 
             121, 119; 121, 115;
             115, 113; 115, 111;
             111, 109;
             137, 112.01; 137, 104; 137, 131;
             131, 104; 131, 125;
             125, 104; 125, 96; 125, 119;
             119, 96;
             113, 84; 113, 109;
             109, 84;
             112.01, 112.02; 112.01, 104;
             104, 102; 104, 96; 
             96, 94; 96, 84;
             84, 82;
             112.02, 112.03; 112.02, 102; 
             102, 100; 102, 94;
             94, 92; 94, 82;
             82, 92; 82, 80;
             112.03, 108; 112.03, 100;
             100, 108; 100, 98; 100, 92;
             92, 90; 92, 88; 92 80; 
             80, 88; 80, 78;
             108, 98; 
             98, 90; 
             90, 88;
             88, 78];
    
elseif strcmp(mode, 'grid')
    tract_list = 1:width^2;
    tract_topo = reshape(tract_list, width, width);
    
    tract_edge_list = [];
    
    for i=1:width
        for j=1:width
            if (i-1)>=1
                tract_edge_list = [tract_edge_list; ...
                    tract_topo(i,j), tract_topo(i-1,j)];
            end
                
            if (i+1)<=width
                tract_edge_list = [tract_edge_list; ...
                    tract_topo(i,j), tract_topo(i+1,j)];
            end
                
            if (j-1)>=1
                tract_edge_list = [tract_edge_list; ...
                    tract_topo(i,j), tract_topo(i,j-1)];
            end
                
            if (j+1)<=width
                tract_edge_list = [tract_edge_list; ...
                    tract_topo(i,j), tract_topo(i,j+1)];
            end
            
        end
    end
end

tract_adj_matrix = zeros(length(tract_list), length(tract_list));

for idx = 1:length(tract_edge_list)
    n1 = find(tract_list == tract_edge_list(idx, 1));
    n2 = find(tract_list == tract_edge_list(idx, 2));

    tract_adj_matrix(n1, n2) = 1;
    tract_adj_matrix(n2, n1) = 1;
end

for i = 1:length(tract_list)
    tract_adj_matrix(i, i) = 1;
end

fprintf('Generated %d tracts\n', length(tract_list));