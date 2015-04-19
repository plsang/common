%% TODO
function med12_gen_metadata_patch()
	root_meta_dir = '/net/per610a/export/das11f/plsang/dataset/MED2013/LDCDIST/LDC2014E27-V3/MEDDATA/databases';
	root_video_dir = '/net/per610a/export/das11f/plsang/dataset/MED/LDCDIST-RSZ';
    
	input_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/medmd_2014_devel_ps.mat';
    output_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med12/medmd_2012_upgraded.mat';
    
    if exist(output_file, 'file'),
        fprintf('File exists\n');
        return;
    end
    
    fprintf('Loading metadata...\n');
	load(input_file, 'MEDMD'); 
    
    gt_info_file = '/net/per610a/export/das11f/plsang/codes/opensource/kuantinglai_cvpr2014/InstanceVideoDetect_v1.0/med12_GT_info.mat';
    load(gt_info_file);
    
    MED2012 = struct;
    
    fprintf('event id/name...\n');
    event_db_csv_file = '/net/per610a/export/das11f/plsang/trecvidmed/metadata/med12/EventDB.csv';
    [event_ids, event_names] = load_event_db_(event_db_csv_file);
    %MED2012.event_ids = arrayfun(@(x) sprintf('E%03d', x), [1:25], 'UniformOutput', false);
    
    Train = struct;
    Test = struct;
    Train.clips = {};
    Train.durations = [];
    Train.judge = struct;
    Test.clips = {};
    Test.durations = []; 
    Test.judge = struct;
    info = struct;
    
    fprintf('Duration, Fps...\n');
    for ii=1:length(fileList),
        video_id = fileList{ii};
        
        loc = MEDMD.lookup.(video_id);
        info.(video_id).loc = loc;         
        if ~isfield(MEDMD.info, video_id),
            video_file = fullfile(root_video_dir, loc);
            [duration, fps] = get_video_info_(video_file);
        else
            duration = MEDMD.info.(video_id).duration;
            fps = MEDMD.info.(video_id).fps;
        end
        
        info.(video_id).duration = duration;
        info.(video_id).fps = fps;
            
        if TrnInd(ii) == 1,
            Train.clips{end+1} = video_id;
            Train.durations(end+1) = duration;
            
            for jj=1:length(event_ids),
                event_id = event_ids{jj};
                if Label(ii,jj) == 1,
                    if ~isfield(Train.judge, event_id),
                        Train.judge.(event_id){1} = video_id;
                    else
                        Train.judge.(event_id){end+1} = video_id;
                    end
                end
            end
            
        elseif TstInd(ii) == 1,
            Test.clips{end+1} = video_id;
            Test.durations(end+1) = duration;
            
            for jj=1:length(event_ids),
                event_id = event_ids{jj};
                if Label(ii,jj) == 1,
                    if ~isfield(Test.judge, event_id),
                        Test.judge.(event_id){1} = video_id;
                    else
                        Test.judge.(event_id){end+1} = video_id;
                    end
                end
            end
        else
            error('Unknown video label\n');
        end
    end
    fprintf('Saving...\n');
    
    MED2012.Train = Train;
    MED2012.Test = Test;
    MED2012.info = info;
    MED2012.event_ids = event_ids;
    MED2012.event_names = event_names;
    MED2012.TrnInd = TrnInd;
    MED2012.TstInd = TstInd;
    MED2012.Label = Label;
    MED2012.clips = fileList';
    
    MEDMD = MED2012;
    save(output_file, 'MEDMD');
    
end
