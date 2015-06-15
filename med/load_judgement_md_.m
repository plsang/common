
%% events.E0XX.positive: list positive videos
%% events.E0XX.miss: list miss videos

function events = load_judgement_md_(path)
	
	fprintf('--- Loading judgement metadata from file %s ...\n', path);
	
	fh = fopen(path);
	csv_infos = textscan(fh, '%s %s %s', 'delimiter', ',');
	fclose(fh);
	
	infos_ = parse_raw_csv_infos_(csv_infos);
	
	events = struct;
	
	%% positive instance
	hit_idx = find(ismember(infos_.INSTANCE_TYPE, 'positive'));
	hit_clipids = infos_.ClipID(hit_idx);
	hit_eventids = infos_.EventID(hit_idx);
	
	for ii = 1:length(hit_clipids),
		clip_id = hit_clipids{ii};
		clip_name = sprintf('HVC%s', clip_id);
		event = hit_eventids{ii};
		if ~isfield(events, event),
			events.(event).positive{1} = clip_name;
		else
			events.(event).positive{end+1} = clip_name;
		end	
	end
	
	%% miss instance
	
	%% May 22, add near_miss, related (MED2011)
	hit_idx = find(ismember(infos_.INSTANCE_TYPE, 'miss') ...
				| ismember(infos_.INSTANCE_TYPE, 'near_miss') ...
				| ismember(infos_.INSTANCE_TYPE, 'related'));
	hit_clipids = infos_.ClipID(hit_idx);
	hit_eventids = infos_.EventID(hit_idx);
	
	for ii = 1:length(hit_clipids),
		clip_id = hit_clipids{ii};
		clip_name = sprintf('HVC%s', clip_id);
		event = hit_eventids{ii};
		if ~isfield(events, event) || ~isfield(events.(event), 'miss'),
			events.(event).miss{1} = clip_name;
		else
			events.(event).miss{end+1} = clip_name;
		end	
	end
	
end
