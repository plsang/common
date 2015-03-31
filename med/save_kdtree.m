function save_kdtree(codebook_file)
	
	run('/net/per610a/export/das11f/plsang/tools/vlfeat-0.9.20/toolbox/vl_setup');
    load(codebook_file);
    
    [dir, name] = fileparts(codebook_file);
    kdtree_file = sprintf('%s/%s.kdtree.mat', dir, name); 
    if ~exist(kdtree_file, 'file'),
        kdtree = vl_kdtreebuild(codebook);
        save(kdtree_file, 'kdtree');
    else
        fprintf('File existed');
    end
        
end

