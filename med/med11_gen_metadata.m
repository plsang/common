function med11_gen_metadata
    csv_dir = '/net/per610a/export/das11f/plsang/trecvidmed11/metadata/databases';
    
    EventKit = struct;			 
	EventKit.('EK130Ex') = {'EVENTS_20110615_ClipMD.csv', 'EVENTS_20110615_EventDB.csv', 'EVENTS_20110615_JudgementMD.csv'};
	
	EventBG = struct;
	EventBG.('default') = {'EVENTS-BG_20130405_ClipMD.csv', 'EVENTS-BG_20130405_EventDB.csv', 'EVENTS-BG_20130405_JudgementMD.csv'}; 
	
	RefTest = struct;
	%RefTest.('KINDREDTEST') = {'KINDREDTEST_20130501_ClipMD.csv', 'KINDREDTEST_20130501_EventDB.csv', 'KINDREDTEST_20130501_Ref.csv', 'KINDREDTEST_20130501_TrialIndex.csv'};
	%RefTest.('MEDTEST') = {'MEDTEST_20130501_ClipMD.csv', 'MEDTEST_20130501_EventDB.csv', 'MEDTEST_20130501_Ref.csv', 'MEDTEST_20130501_TrialIndex.csv'};
	RefTest.('KINDREDTEST') = {'Kindred14-Test_20140513_ClipMD.csv', 'Kindred14-Test_20140513_EventDB.csv', 'Kindred14-Test_20140513_Ref.csv'};
	RefTest.('MEDTEST') = {'MED14-Test_20140513_ClipMD.csv', 'MED14-Test_20140513_EventDB.csv', 'MED14-Test_20140513_Ref.csv'};
	
	Research = struct;
	Research.('default') = {'RESEARCH_20140513_ClipMD.csv', 'RESEARCH_20140513_EventDB.csv'};
	
	MEDDB = struct;
	MEDDB.EventKit = EventKit;
	MEDDB.EventBG = EventBG;
	MEDDB.RefTest = RefTest;
	MEDDB.Research = Research;
	%MEDDB.UnrefTest = UnrefTest;
	
	MEDMD = struct;
	
	fprintf('Building devel (including ref test) metadata... \n');
	
	types = fieldnames(MEDDB);
	for ii=1:length(types),
		type = types{ii};
		subtypes = fieldnames(MEDDB.(type));
		
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
    
end

function check_metadata
    %% event collection
    
    %% DEVT
    
    %% DEVO
    
end