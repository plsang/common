function gen_sge_code_log(script_name, pattern, total_segments, num_job, pe)
	
	configs = set_global_config();
	
	script_dir = configs.sge_script_dir;
	
	sge_sh_file = sprintf('%s/%s.sh', script_dir, script_name);
	
	
	[file_dir, file_name] = fileparts(sge_sh_file);
	output_dir = [script_dir, '/', script_name];

	if exist(output_dir, 'file') ~= 7,
		mkdir(output_dir);
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
		
        if ~exist('pe', 'var'),
			fprintf(fh, 'qsub -e /dev/null -o /dev/null %s %s\n', sge_sh_file, params);
		else
			fprintf(fh, 'qsub -pe localslots %d -e /dev/null -o /dev/null %s %s\n', pe, sge_sh_file, params);
		end

		start_idx = end_idx+1;
	end
	
	cmd = sprintf('chmod +x %s', output_file);
	system(cmd);
	
	fclose(fh);
end