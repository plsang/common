function [ code ] = vq_encode( feats, codebook, kdtree)

    max_comps = 50;
            
    if max_comps ~= -1
        % using ann...
        codeids = vl_kdtreequery(kdtree, codebook, feats, ...
            'MaxComparisons', max_comps);
    else
        % using exact assignment...
        [~, codeids] = min(vl_alldist(codebook, feats), [], 1);
    end
    
    code = vl_binsum(zeros(size(codebook, 2), 1), 1, double(codeids));
    code = single(code);
    
end

