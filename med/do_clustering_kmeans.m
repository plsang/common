function codebook = do_clustering_kmeans(proj_dir, feat_pat, cluster_count, num_threads, output_suffix, num_features)
%DO_CLUSTERING Summary of this function goes here
%   Detailed explanation goes here
	
	run('/net/per610a/export/das11f/plsang/tools/vlfeat-0.9.20/toolbox/vl_setup');
     
    if ~exist('num_threads', 'var'),
		num_threads = 1;
	end
	
    vl_threads(num_threads);
    
	if ~exist('num_features', 'var'),
		num_features = 1000000;
	end
	
	if ~exist('cluster_count', 'var'),
		cluster_count = 4000;
	end
	
    if ~exist('output_suffix', 'var'),
		output_suffix = '';
	end
    
	f_selected_feats = sprintf('%s/feature/codebook/%s/selected_feats_%d.mat', ...
		proj_dir, feat_pat, num_features);
		
	if ~exist(f_selected_feats, 'file'),
		error('File %s not found!\n', f_selected_feats);
	end
	
	load(f_selected_feats, 'feats');
    
	feat_dim = size(feats, 1);
	
    if isempty(output_suffix),
        output_file = sprintf('%s/feature/codebook/%s/codebook.kmeans.%d.%d.mat', ...
            proj_dir, feat_pat, cluster_count, feat_dim);
    else
        output_file = sprintf('%s/feature/codebook/%s/codebook.kmeans.%d.%d.%s.mat', ...
            proj_dir, feat_pat, cluster_count, feat_dim, output_suffix);
    end
    
		
	if exist(output_file),
		fprintf('File [%s] already exist. skipped!\n', output_file);
		return;
	end
    
    codebook = vl_kmeans(feats, cluster_count, 'verbose', 'algorithm', 'elkan', 'MaxNumIterations', 150);
	
	fprintf('Done training codebook!\n');
    save(output_file, 'codebook', '-v7.3'); 
    
end

