function cm_gen_sge_code_log(script_name, pattern, total_segments, num_job, varargin)
	    
    if nargin < 4,
        fprintf('Usage: cm_gen_sge_code_log(script_name, pattern, total_segments, num_job, varargin) \n');
        fprintf(' varargin: debug=0 (use default option of sge), 1 (error only), 2 (debug only), 3 (both), 4 (no error, no output) ) \n');
        fprintf(' varargin: pe=0 (number of local slots per job) ) \n');
        fprintf(' varargin: rename=0 (whether to rename a job or not) ) \n');
        fprintf(' varargin: local=0 (whether to run on local sge or remote sge) ) \n');
        fprintf(' varargin: start=1 (start job index, matlab index) ) \n');
        fprintf(' varargin: end=total_segments (end job index, matlab index) ) \n');
        fprintf(' varargin: spacing=log (spacing between jobs, log (log 10), linear (1))  \n');
        fprintf(' varargin: linstep=1 (step when using linear spacing) \n');
        return;
    end
    
    debug = 0;
    pe = 0;
    rename = 0;
    local = 0;
    start_job = 1;
    end_job = total_segments;
    spacing = 'log';
    linstep = 1;
    
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
            case 'local'
                local = arg;
            case 'start'
                start_job = arg;
            case 'end'
                end_job = arg;
            case 'spacing'
                spacing = arg;
            case 'linstep'
                linstep = arg;
            otherwise
                error(sprintf('Option ''%s'' unknown.', opt)) ;
        end  
    end

	configs = set_global_config();
	
	script_dir = configs.sge_script_dir;
	
    if local == 1,
        script_name = sprintf('%s.local', script_name);
    end
    
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
	
    if strcmp(spacing, 'log'),  % log
        % gen <num_job> logaric space between two points: 1 and total_segments
        job_idxs = round(logspace(log10(start_job), log10(end_job), num_job));
        job_idxs = unique(job_idxs);
    else   
         % linear, space linstep
        job_idxs = [start_job:linstep:end_job];
    end
    
	for ii = 1:length(job_idxs),
		
		start_idx = job_idxs(ii);
		
        if ii < length(job_idxs),
            end_idx = job_idxs(ii+1)-1;
        else
            end_idx = job_idxs(ii);
        end
        
		params = sprintf(pattern, start_idx, end_idx);
		
        cmd = 'qsub';
        if rename == 1,
            cmd = sprintf('%s -N s%06d', cmd, start_idx);
        end
        
        if pe > 1,
            cmd = sprintf('%s -pe localslots %d', cmd, pe);
        end
        
        if local == 1,
            cmd = sprintf('%s -wd $HOME', cmd);
        end
        
        if debug > 0,
        
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
                case 4
                    e_file = '/dev/null'; 
                    o_file = '/dev/null';
                otherwise
                    error('unknown debug type <%d>\n', debug);
            end
		
            cmd = sprintf('%s -e %s -o %s', cmd, e_file, o_file);
        end
        
        cmd = sprintf('%s %s %s', cmd, sge_sh_file, params);
        
        fprintf(fh, '%s\n', cmd);
        
	end
	
	cmd = sprintf('chmod +x %s', output_file);
	system(cmd);
	
	fclose(fh);
end