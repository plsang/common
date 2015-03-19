
function [trialids, clipids, eventids] = load_trial_index_(path)
	fprintf('--- Loading trial index metadata from file %s ...\n', path);
	
	fh = fopen(path);
	csv_infos = textscan(fh, '%s %s %s', 'delimiter', ',');
	fclose(fh);
	
	infos_ = parse_raw_csv_infos_(csv_infos);
	
	trialids = infos_.TrialID;
	clipids = infos_.ClipID;
	eventids = infos_.EventID;

end
