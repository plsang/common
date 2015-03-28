
function videos = load_lookup_table_(f_clip_lookup)

	fh = fopen(f_clip_lookup, 'r');

	fprintf('Loading lookup table...\n');

	c_lookup = textscan(fh, '%s %s %s %s', 'delimiter', ',');

	fclose(fh);

	clips = c_lookup{1};
	disks = c_lookup{3};
	paths = c_lookup{4};


	rsz_vid_dir = '/net/per610a/export/das11f/plsang/dataset/MED2013/LDCDIST-RSZ';

	clip_ext = '.mp4';
	clip_prefix = 'HVC';

	videos = struct;
	
	for ii = 2:length(clips),
		if ~mod(ii, 1000),
			fprintf('%d ', ii);
		end
		
		clip = str2num(strtrim(strrep(clips{ii}, '"', '')));
		disk = strtrim(strrep(disks{ii}, '"', ''));
		path = strtrim(strrep(paths{ii}, '"', ''));
		
		clip_name = sprintf('%s%06d', clip_prefix, clip);
		clip_rel_path = fullfile(disk, path, [clip_name, '.mp4']);
		
		clip_org_path = fullfile(rsz_vid_dir, clip_rel_path);
		if ~exist(clip_org_path, 'file'),
			warning('File %s does not exist! skipped\n', clip_org_path);
			continue;
		end
		
		videos.(clip_name) = clip_rel_path;
		
	end
	
	fprintf('\n');

end
