function [ code ] = kcb_encode( feats, codebook, kdtree )
%KCBENCODE Summary of this function goes here

    max_comps = 500;
    num_nn = 5;
    sigma = 0.2;
    kcb_type = 'unc';
        
    if max_comps ~= 1
        % using ann...
        code = featpipem.lib.KCBEncode(feats, codebook, num_nn, ...
            sigma, kdtree, max_comps, kcb_type, false);
    else
        % using exact assignment...
        code = featpipem.lib.KCBEncode(feats, codebook, num_nn, ...
            sigma, [], [], kcb_type, false);
    end
    
    code = single(code);
end

