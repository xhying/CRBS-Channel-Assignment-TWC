function pathloss = calculate_path_loss(mode, f, d, h_b, h_r)

switch mode
    case 'SUI'
        d0 = 0.1;   % km
        v = 3e8;    % speed of light in m/s

        % Terrain model parameters
        a = [4.6, 4.0, 3.6];
        b = [0.0075, 0.0065, 0.005];
        c = [12.6, 17.1, 20.0];
        alpha = [6.6, 5.2, 5.2];
        s = [10.6, 8.2, 8.2];

        % 1st config for the selected model
        m = 1;

        lambda = v/(f*10e6);
        A = 20*log10((4.0*pi*d0)/lambda);
        gamma = a(m) - b(m)*h_b + c(m)/h_b;
        X_f = 6.0*log10(f/2000.0);

        if m < 3    % m = 1 or 2
            X_h = -10.8*log10(h_r/2000.0);
        else
            X_h = -20.0*log10(h_r/2000.0);
        end

        d = max(d, d0);

        pl = A + (10.0*gamma*log10(d/d0)) + X_f + X_h + s(m);
        
    case 'COST231'
        city_size = 'large';
        terrain_type = 'urban';
        
        if strcmp(city_size, 'large')
            a_h_r = 3.20*(log10(11.75*h_r).^2.0) - 4.97;
        else
            a_h_r = (1.1*log10(f) - 0.7)*h_r - (1.56*log10(f) - 0.8);
        end
        
        c_m = 0.0;
        if strcmp(terrain_type, 'urban')
            c_m = 3.0;
        end
        
        d = max(d, 0.01); % d should be at least 0.01 km
        
        pl = 46.3 + (33.9*log10(f)) - (13.82*log10(h_b)) ...
                    - a_h_r + ((44.9 - 6.55*log10(h_b))*log10(d)) + c_m;
                
    otherwise
        error('Unknown propagation model');
end

pathloss = pl;
