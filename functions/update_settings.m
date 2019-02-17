function settings = update_settings(settings, cs_thr)
settings.cs_rss = cs_thr;
settings.cs_radius = calculate_min_separation(settings.prop_model, settings.freq, ...
    settings.tx_power - settings.cs_rss, settings.tx_ant_height, settings.rx_ant_height);