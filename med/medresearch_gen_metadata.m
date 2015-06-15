function gen_metadata
	%gen_video_list
	%gen_video_description
	copy_video_and_keyframes
end

function gen_video_list
	meta_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/medmd_2014_devel_ps.mat';
	load(meta_file, 'MEDMD');
	
	% gen_video_list
	list_file = '/net/per610a/export/das11f/plsang/medresearch/data/medresearch.txt';
	if ~exist(list_file, 'file'),
		clips = MEDMD.Research.default.clips;
		fh = fopen(list_file, 'w');
		for ii = 1:length(clips),
			fprintf(fh, '%s\n', clips{ii});
		end
		fclose(fh);
	else
		fprintf('File <%s> already exist!\n', list_file);
	end
		
end

function gen_video_description
	meta_file = '/net/per610a/export/das11f/plsang/dataset/MED2013/LDCDIST/LDC2014E27-V3/MEDDATA/databases/RESEARCH_20140513_JudgementMD.csv';
	fh = fopen(meta_file);
	csv_infos = textscan(fh, '%q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q %q', 'delimiter', ',');
	fclose(fh);
	
	infos_ = parse_raw_csv_infos_(csv_infos);
	
	clip_prefix = 'HVC';
	
	desc_dir = '/net/per610a/export/das11f/plsang/medresearch/view/descriptions';
	
	for ii = 1:length(infos_.ClipID),
		clip_id = infos_.ClipID{ii};
		clip_name = sprintf('%s%s', clip_prefix, clip_id);
		desc_file = sprintf('%s/%s.txt', desc_dir, clip_name);
		fh = fopen(desc_file, 'w');
		fprintf(fh, '%s', infos_.SYNOPSIS{ii});
		fclose(fh);
	end
		
end

function copy_video_and_keyframes
	meta_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/medmd_2014_devel_ps.mat';
	load(meta_file, 'MEDMD');
	
	% copy original videos
	clips = MEDMD.Research.default.clips;
	
	input_org_dir = '/net/per610a/export/das11f/plsang/dataset/MED2013/LDCDIST';
	input_rsz_dir = '/net/per610a/export/das11f/plsang/dataset/MED2013/LDCDIST-RSZ';
	
	output_org_dir = '/net/per610a/export/das11f/plsang/medresearch/videos';
	output_rsz_dir = '/net/per610a/export/das11f/plsang/medresearch/videos-rsz';
	
	input_kf_dir = '/net/per610a/export/das11f/plsang/trecvidmed14/keyframes';
	output_kf_dir = '/net/per610a/export/das11f/plsang/medresearch/keyframes';
	
	for ii=1:length(clips),
		if ~mod(ii, 10), fprintf('%d ', ii); end;
		% for original videos
		clipid = clips{ii};
		
		output_file = sprintf('%s/%s.mp4', output_org_dir, clipid);
		if exist(output_file, 'file'),
			continue;
		end
		
		if ~isfield(MEDMD.lookup, clipid),
			warning('File <%s> does not have look up info!!! \n', clipid);
			continue;
		end
		
		cmd = sprintf('cp %s/%s %s', input_org_dir, MEDMD.lookup.(clipid), output_org_dir);
		system(cmd);
		
		% for resized videos
		cmd = sprintf('cp %s/%s %s', input_rsz_dir, MEDMD.lookup.(clipid), output_rsz_dir);
		system(cmd);
		
		% for keyframes
		cmd = sprintf('cp -R %s/%s %s', input_kf_dir, MEDMD.lookup.(clipid)(1:end-4), output_kf_dir);
		system(cmd);
		
	end
	% copy resize videos
		
end

function infos = parse_raw_csv_infos_(csv_infos)
	%fprintf('--- Parsing raw csv file ...\n');
	
	infos = struct;
	
	for ii = 1:length(csv_infos),
		field = strtrim(strrep(csv_infos{ii}{1}, '"', ''));
		
		% trim '"' in all elements
		% Non-scalar in output --> Set 'UniformOutput' to false.
		values = cellfun(@(x) strtrim(strrep(x, '"', '')), csv_infos{ii}(2:end), 'UniformOutput', false );

		infos.(field) = values;
	end
	
end

