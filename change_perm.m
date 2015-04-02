function change_perm(file, mod, dir_recursive)
    if ~exist(file, 'file'),
        return;
    end
    
	if ~exist('mod', 'var'),
		mod = 777;
	end
	
    if ~exist('dir_recursive', 'var'),
		dir_recursive = 1;
	end
    
	try
		if isdir(file),
            if dir_recursive == 1,
                cmd = sprintf('chmod -R %d %s', mod, file);
            else
                cmd = sprintf('chmod %d %s', mod, file);
            end
		else
			cmd = sprintf('chmod %d %s', mod, file);
		end
		
		system(cmd);
	catch
	end
end
