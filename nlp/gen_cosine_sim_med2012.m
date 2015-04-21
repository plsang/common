function gen_cosine_sim_med2012
    output_file='/net/per610a/export/das11f/plsang/trecvidmed/metadata/med12/medmd_2012_fmt_event_cosims.mat';
    if exist(output_file, 'file'),
        fprintf('File exists <%s>\n', output_file);
    end
    
    filename='/net/per610a/export/das11f/plsang/trecvidmed/metadata/med12/medmd_2012.mat';
    fprintf('Loading meta file <%s>\n', filename);
    load(filename, 'MEDMD');
    
    sim_fea_dir = '/net/per610a/export/das11f/plsang/trecvidmed/feature/keyframes/deepcaffe_eventsim_hybrid';
    
    kf_dir = '/net/per610a/export/das11f/plsang/trecvidmed/keyframes';    

    cosims = struct();
    
    for ii=1:length(MEDMD.clips),
    
        if ~mod(ii, 100), fprintf('%d ', ii); end;
        
        video_id = MEDMD.clips{ii};
        ldc_pat = MEDMD.info.(video_id).loc;
        
        video_kf_dir = fullfile(kf_dir, ldc_pat);
		video_kf_dir = video_kf_dir(1:end-4);	
		kfs = dir([video_kf_dir, '/*.jpg']);
        num_keyframes = length(kfs);
        
        cosims_ = zeros(length(MEDMD.event_ids), num_keyframes);
        
        for jj=1:num_keyframes,
            sim_file = sprintf('%s/%s/%s.cosinesim.txt', sim_fea_dir, ldc_pat(1:end-4), kfs(jj).name(1:end-4));
            fh = fopen(sim_file);
            cosim = textscan(fh, '%f');
            fclose(fh);
            
            cosim = cosim{1};
            cosims_(:, jj) = cosim(1:length(MEDMD.event_ids));
        end
        
        cosims.(video_id) = cosims_;
        
    end    
    
    save(output_file, 'cosims');
end