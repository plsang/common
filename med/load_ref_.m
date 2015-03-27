

%%% events is a struct contains all true positive clips
function events = load_ref_(path)
	fprintf('--- Loading reference metadata from file %s ...\n', path);
	
	fh = fopen(path);
	csv_infos = textscan(fh, '%s %s', 'delimiter', ',');
	fclose(fh);
	
	infos_ = parse_raw_csv_infos_(csv_infos);
	
	% building events structure
	hit_idx = find(ismember(infos_.Targ, 'y'));
	hit_trials = infos_.TrialID(hit_idx);
	
	events = struct;
	for ii = 1:length(hit_trials),
	
		splits = regexp(hit_trials{ii}, '\.', 'split');
		if length(splits) ~= 2,
			error('Unknown format id...\n');
		end
		
		clip_id = splits{1};
		clip_name = sprintf('HVC%s', clip_id);
		event = splits{2};
		if ~isfield(events, event),
			events.(event){1} = clip_name;
		else
			events.(event){end+1} = clip_name;
		end	
		
	end
	
end
