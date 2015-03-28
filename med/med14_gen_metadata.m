%% TODO
function med14_gen_metadata()
	root_meta_dir = '/net/per610a/export/das11f/plsang/dataset/MED2013/LDCDIST/LDC2014E27-V3/MEDDATA/databases';
	root_video_dir = '/net/per610a/export/das11f/plsang/dataset/MED/LDCDIST-RSZ';
    
	output_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/medmd_2014_devel_ps.mat';
    
	if exist(output_file, 'file'),
        fprintf('File (%s) existed\n', output_file);
        return;
    end
    
    fprintf('loading info from cvs...\n');
    MEDMD = calker_load_metadata(root_meta_dir);
    lookup_file = '/net/per610a/export/das11f/plsang/dataset/MED2013/LDCDIST/LDC2014E27-V3/MEDDATA/doc/clip_location_lookup_table.csv';
    lookup = load_lookup_table_(lookup_file);
    MEDMD.lookup = lookup;
    
    fprintf('creating info(location, duration & fps) for %d videos...\n', length(MEDMD.videos));
    info = struct;
    for ii=1:length(MEDMD.videos),
        if ~mod(ii, 1000), fprintf('%d ', ii); end;
        video_id = MEDMD.videos{ii};
        
        if ~isfield(MEDMD.lookup, video_id),
			msg = sprintf('Warning, file location not found <%s>\n', video_id);
			continue;
		end
        
        loc = lookup.(video_id);
        video_file = fullfile(root_video_dir, loc);
        [duration, fps] = get_video_info_(video_file);
        info.(video_id).loc = loc;
        info.(video_id).duration = duration;
        info.(video_id).fps = fps;
    end   
    MEDMD.info = info;
    
    save(output_file, 'MEDMD');
	
end

function MEDMD = calker_load_metadata(root_meta_dir)
	
	EventKit = struct;			 
	EventKit.('EK0Ex') = {'EVENTS-0Ex_20130913_ClipMD.csv', 'EVENTS-0Ex_20130913_EventDB.csv', 'EVENTS-0Ex_20130913_JudgementMD.csv'};
	EventKit.('EK10Ex') = {'EVENTS-10Ex_20130913_ClipMD.csv', 'EVENTS-10Ex_20130913_EventDB.csv', 'EVENTS-10Ex_20130913_JudgementMD.csv'};
	EventKit.('EK100Ex') = {'EVENTS-100Ex_20140513_ClipMD.csv', 'EVENTS-100Ex_20140513_EventDB.csv', 'EVENTS-100Ex_20140513_JudgementMD.csv'};
	EventKit.('EK130Ex') = {'EVENTS-130Ex_20130405_ClipMD.csv', 'EVENTS-130Ex_20130405_EventDB.csv', 'EVENTS-130Ex_20130405_JudgementMD.csv'};
	EventKit.('RESEARCH') = {'RESEARCH_20140513_ClipMD.csv', 'RESEARCH_20140513_EventDB.csv', 'RESEARCH_20140513_JudgementMD.csv'};
	
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
	
    videos = [];
    
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
                        
                        videos = [videos, clips];
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
	
    MEDMD.videos = unique(videos);  
end
