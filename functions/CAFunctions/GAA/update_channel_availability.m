% A GAA CBSD is interfering with a PA CBSD, if it causes interference at
% any location within the PAL protection area (defined by -96 dBm/10 MHz 
% signal strength) higher than -80 dBm/10 MHz.

function cbsds = update_channel_availability(settings, PA_cbsds, cbsds)
min_dist = settings.comm_radius + settings.int_radius;

for i = 1:length(PA_cbsds)
    for j = 1:length(cbsds)
        dist = pdist2(PA_cbsds{i}.center, cbsds{j}.loc);
        if (dist < min_dist) && isfield(PA_cbsds{i}, 'chns')
            cbsds{j}.available_chns(PA_cbsds{i}.chns) = 0;
        end
    end
end
    
    