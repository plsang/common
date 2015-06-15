function med11_gen_metadata(new_loc)
    
	output_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med11/medmd_2011.mat';
	
	if exist(output_file, 'file'),
		fprintf('Existed');
		return;
	end
	
	root_meta_dir = '/net/per610a/export/das11f/plsang/trecvidmed11/metadata/databases';
    root_video_dir = '/net/per610a/export/das11f/plsang/dataset/MED/LDCDIST-RSZ';
	
    EventKit = struct;			 
	EventKit.('EK130Ex') = {'EVENTS_20110615_ClipMD.csv', 'EVENTS_20110615_EventDB.csv', 'EVENTS_20110615_JudgementMD.csv'};
	
	RefTest = struct;
	RefTest.('MED11TEST') = {'MED11TEST_20111028_ClipMD.csv', 'MED11TEST_20111028_EventDB.csv', 'MED11TEST_20111028_Ref.csv'};
	
	RefTest.('MED11DEVT') = {'DEVT_20110615_ClipMD.csv', 'DEVT_20110615_EventDB.csv', 'MED11TEST_20111028_Ref.csv'};
	
	MEDDB = struct;
	MEDDB.EventKit = EventKit;
	MEDDB.RefTest = RefTest;
	
	MEDMD = struct;
	
	fprintf('Building devel (including ref test) metadata... \n');
	
	types = fieldnames(MEDDB);
	
	if ~exist('new_loc', 'var'),
		new_loc = 1;
	end
	
	input_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/medmd_2014_devel_ps.mat';
    fprintf('Loading metadata...\n');
	MEDMD14 = load(input_file, 'MEDMD'); 
	MEDMD14 = MEDMD14.MEDMD;

	
	fprintf('loading location info from cvs...\n');
    lookup_file = '/net/per610a/export/das11f/plsang/dataset/MED/LDCDIST/LDC2014E27-V3/MEDDATA/doc/clip_location_lookup_table.csv';
    lookup = load_lookup_table_(lookup_file);
	
	videos = [];
	
	for ii=1:length(types),
		type = types{ii};
		subtypes = fieldnames(MEDDB.(type));
		
		if strcmp(type, 'EventKit'),
			old_loc = 'devel';
		elseif strcmp(type, 'RefTest'),
			old_loc = 'test';
		else 
			error('Unknown type (%s)', type);
		end
		
		for jj=1:length(subtypes),
			subtype = subtypes{jj};
			files = MEDDB.(type).(subtype);
			for kk = 1:length(files),
				file = files{kk};
				filepath = fullfile(root_meta_dir, file);
				
				[~, filename] = fileparts(file);
				splits = regexp(filename, '_', 'split');
				metatype = splits{length(splits)};
				
				switch metatype,
					case 'ClipMD'
						[clips, durations] = load_clip_md_(filepath);
						MEDMD.(type).(subtype).clips = clips;
						MEDMD.(type).(subtype).durations = durations;
						
						videos = [videos, clips];
						
						for kk=1:length(clips),
							if new_loc == 0,
								MEDMD.info.(clips{kk}).loc = sprintf('%s/%s/%s.mat', old_loc, clips{kk}, clips{kk});
							else
								if isfield(lookup, clips{kk}),
									MEDMD.info.(clips{kk}).loc = lookup.(clips{kk});
								else
									fprintf('Warning, file location not found <%s> in lookup table\n', clips{kk});
								end
								
								if isfield(MEDMD14.info, clips{kk}),
									MEDMD.info.(clips{kk}).loc = MEDMD14.info.(clips{kk}).loc;
								else
									fprintf('Warning, file location not found <%s> in MEDMD14 info\n', clips{kk});
								end
							end
						end						
						
					case 'EventDB'
						[eventids, eventnames] = load_event_db_(filepath);
						MEDMD.(type).(subtype).eventids = eventids;
						MEDMD.(type).(subtype).eventnames = eventnames;
					case 'Ref'
						events = load_ref_(filepath);
						MEDMD.(type).(subtype).ref = events;
					case 'JudgementMD'
						events = load_judgement_md_(filepath);
						MEDMD.(type).(subtype).judge = events;
					case 'TrialIndex'
						[trialids, clipids, eventids] = load_trial_index_(filepath);
						MEDMD.(type).(subtype).trialids = trialids;
					otherwise
						disp('Unknown metatype %s \n', metatype);
				end
				
			end
		end
	end
	
	%MEDMD.Train = MEDMD.EventKit.EK130Ex;
	%MEDMD.Test = MEDMD.RefTest.MED11TEST;
	
	% event_db_csv_file = '/net/per610a/export/das11f/plsang/trecvidmed11/metadata/databases/MED11TEST_20110615_EventDB.csv';
	% [event_ids, event_names] = load_event_db_(event_db_csv_file);
	% MEDMD.event_ids = event_ids;
	% MEDMD.event_names = event_names;
	
	% train_clips = [];
	% for ii=1:length(event_ids),
		% event_id = event_ids{ii};
		% train_clips = [train_clips, MEDMD.EventKit.EK130Ex.judge.(event_id).positive];
	% end
	
	% MEDMD.clips = [train_clips, MEDMD.RefTest.MED11TEST.clips];
	% MEDMD.TrnInd = ismember(MEDMD.clips, train_clips)';
	% MEDMD.TstInd = ismember(MEDMD.clips, MEDMD.RefTest.MED11TEST.clips)';
	% Label = zeros(length(MEDMD.clips), length(event_ids));
	% for ii=1:length(event_ids),
		% event_id = event_ids{ii};
		% Label(:, ii) = double(ismember(MEDMD.clips, MEDMD.EventKit.EK130Ex.judge.(event_id).positive)' | ismember(MEDMD.clips, MEDMD.RefTest.MED11TEST.ref.(event_id))');
	% end
	% MEDMD.Label = Label;
	    
    fprintf('Duration, Fps...\n');
    for ii=1:length(videos),
        video_id = videos{ii};
        
		if ~isfield(MEDMD.info, video_id),
			fprintf('Warning, file location not found <%s> in lookup table\n', video_id);
			continue;
		end
		
        if ~isfield(MEDMD14.info, video_id),
            video_file = fullfile(root_video_dir, MEDMD.info.(video_id).loc);
            [duration, fps] = get_video_info_(video_file);
        else
            duration = MEDMD14.info.(video_id).duration;
            fps = MEDMD14.info.(video_id).fps;
        end
        
        MEDMD.info.(video_id).duration = duration;
        MEDMD.info.(video_id).fps = fps;
            
	end
	
	save(output_file, 'MEDMD');
    
end

