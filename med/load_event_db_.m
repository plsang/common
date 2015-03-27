
function [eventids, eventnames] = load_event_db_(path)
	fprintf('--- Loading event metadata from file %s ...\n', path);
	
	fh = fopen(path);
	csv_infos = textscan(fh, '%s %s', 'delimiter', ',');
	fclose(fh);
	
	infos_ = parse_raw_csv_infos_(csv_infos);
	
	
	eventids = {};
	eventnames = {};
	
	for ii = 1:length(infos_.EventID),	
		if regexp(infos_.EventID{ii}, 'E\d+'),
			eventids{end+1} = infos_.EventID{ii};
			eventnames{end+1} = infos_.EventName{ii};
		end
	end
	
end
