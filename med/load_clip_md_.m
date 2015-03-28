
function [clips, durations] = load_clip_md_(path)
	fprintf('--- Loading clip metadata from file %s ...\n', path);
	
	fh = fopen(path);
	
	csv_infos = textscan(fh, '%s %s %s %s %s', 'delimiter', ',');
	fclose(fh);
	
	infos_ = parse_raw_csv_infos_(csv_infos);
	
	clip_prefix = 'HVC';
	
	clips = {};
	durations = [];
	
	for ii = 1:length(infos_.ClipID),
		clip_id = infos_.ClipID{ii};
		clip_name = sprintf('%s%s', clip_prefix, clip_id);
		clips{end+1} = clip_name;
		durations(end+1) = str2num(infos_.DURATION{ii});
	end
	
end

