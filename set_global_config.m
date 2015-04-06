function configs = set_global_config()
    %% dir configs
	configs.logdir = fullfile(pwd, 'log');
	configs.sgelogdir = fullfile(pwd, 'sgelog');
    configs.sge_script_dir = fullfile(pwd, 'sge_scripts');
    
    all_dirs = fieldnames(configs);
    for ii=1:length(all_dirs),
        dir_name = all_dirs{ii};
        dir_path = configs.(dir_name);
        if ~exist(dir_path, 'file'),
            mkdir(dir_path);
            change_perm(dir_path);
        end
    end
    
    %% other configs
end
