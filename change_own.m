function change_own(file, dir_recursive, user_name)
    if ~exist(file, 'file'),
        return;
    end
    
    if ~exist('dir_recursive', 'var'),
		dir_recursive = 0;
	end
    
	if ~exist('user_name', 'var'),
		user_name = 'plsang';
	end
    
	try
		if isdir(file),
            if dir_recursive == 1,
                cmd = sprintf('chown -R %s %s', user_name, file);
            else
                cmd = sprintf('chown %s %s', user_name, file);
            end
		else
			cmd = sprintf('chown %s %s', user_name, file);
		end
		
		system(cmd);
	catch
	end
end

