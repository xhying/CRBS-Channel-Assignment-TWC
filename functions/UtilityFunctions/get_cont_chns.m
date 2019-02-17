% Find all available contiguous channel assignments given demands and
% available channels
% Inputs:
%  - demands: a set of requested numbers of channels, e.g., [1,2,3,4]
%  - available_chns: a channel availability vector, [1 1 0 1 1 ... 1]
%  Sorted in ascending order presumably.

function cont_chns = get_cont_chns(demands, available_chns)
cont_chns = cell(1, 4*15);  % Assuming 15 channels and a max. of 4 channels

count = 0;

for i = 1:length(demands)
    demand = demands(i);
    
    for start_chn_id = 1:(length(available_chns)-demand+1)
        if available_chns(start_chn_id) == true    % j-th channel is avaiable
            requested_chn_ids = start_chn_id + (1:1:demand) - 1;
            
            if sum(available_chns(requested_chn_ids)) == demand
                count = count + 1;
                cont_chns{count} = requested_chn_ids;
            end
        end
    end
end

cont_chns = cont_chns(~cellfun('isempty',cont_chns));
