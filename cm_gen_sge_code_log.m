function cm_gen_sge_code_log(script_name, pattern, total_segments, num_job, varargin)
	
    debug = 0;
    pe = 0;
    rename = 0;
    
    if nargin < 4,
        fprintf('Usage: cm_gen_sge_code_log(script_name, pattern, total_segments, num_job, varargin) \n');
        fprintf(' varargin: debug 0 (no error, no output), 1 (error only), 2 (debug only), 3 (both) ) \n');
        fprintf(' varargin: pe 0 (number of local slots per job) ) \n');
        fprintf(' varargin: rename 0 (whether to rename a job or not) ) \n');
        return;
    end
    
    for k=1:2:length(varargin),
        opt = lower(varargin{k});
        arg = varargin{k+1} ;
      
        switch opt
            case 'debug'
                debug = arg;
            case 'pe'
                pe = arg ;
            case 'rename'
                rename = arg;
            otherwise
                error(sprintf('Option ''%s'' unknown.', opt)) ;
        end  
    end

	configs = set_global_config();
	
	script_dir = configs.sge_script_dir;
	
	sge_sh_file = sprintf('%s/%s.sh', script_dir, script_name);
	
	[file_dir, file_name] = fileparts(sge_sh_file);
	output_dir = [script_dir, '/', script_name];

	if exist(output_dir, 'file') ~= 7,
		mkdir(output_dir);
	end

    if debug > 0,
        debug_dir = sprintf('%s/debug', output_dir);
        if exist(debug_dir, 'file') ~= 7,
            mkdir(debug_dir);
            change_perm(debug_dir);
        end
    end

	output_file = sprintf('%s/%s.qsub.sh', output_dir, file_name);
	fh = fopen(output_file, 'w');
	
	% gen <num_job> logaric space between two points: 1 and total_segments
	job_idxs = round(logspace(log10(1), log10(total_segments), num_job));
	
	start_idx = 1;
	for end_idx = job_idxs(2:end),
		
		if end_idx < start_idx,
			continue;
		end
		
		params = sprintf(pattern, start_idx, end_idx);
		
        cmd = 'qsub';
        if rename == 1,
            cmd = sprintf('%s -N s%06d', cmd, start_idx);
        end
        
        if pe > 1,
            cmd = sprintf('%s -pe localslots %d', cmd, pe);
        end
        
        switch debug,
            case 1
                e_file = sprintf('%s/%s.error.s%06d_e%06d.log', debug_dir, script_name, start_idx, end_idx);
                o_file = '/dev/null';
            case 2
                e_file = '/dev/null'; 
                o_file = sprintf('%s/%s.output.s%06d_e%06d.log', debug_dir, script_name, start_idx, end_idx);
            case 3
                e_file = sprintf('%s/%s.error.s%06d_e%06d.log', debug_dir, script_name, start_idx, end_idx);
                o_file = sprintf('%s/%s.output.s%06d_e%06d.log', debug_dir, script_name, start_idx, end_idx);
            otherwise
                e_file = '/dev/null'; 
                o_file = '/dev/null';
        end
		
        cmd = sprintf('%s -e %s -o %s %s %s', cmd, e_file, o_file, sge_sh_file, params);
        
        fprintf(fh, '%s\n', cmd);
        
		start_idx = end_idx+1;
	end
	
	cmd = sprintf('chmod +x %s', output_file);
	system(cmd);
	
	fclose(fh);
end