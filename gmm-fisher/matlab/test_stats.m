%% test if getfk multiple times change the final result --> ok. don't worry
function test_stats
	codebook_file = '/net/per610a/export/das11f/plsang/trecvidmed13/feature/codebook/mfcc.bg.rastamat/data/codebook.gmm.256.39.mat';
	load(codebook_file);
	
	fisher_params.grad_weights = false;		% "soft" BOW
    fisher_params.grad_means = true;		% 1st order
    fisher_params.grad_variances = true;	% 2nd order
    fisher_params.alpha = single(1.0);		% power normalization (set to 1 to disable)
    fisher_params.pnorm = single(0.0);		% norm regularisation (set to 0 to disable)
	
    feats = single(rand(39, 22000));
    
    cpp_handle = mexFisherEncodeHelperSP('init', codebook, fisher_params);
	 
	code1 = mexFisherEncodeHelperSP('encode', cpp_handle, feats);
	
	[code_1, stats1] = mexFisherEncodeHelperSP('encodestats', cpp_handle, feats(:,1:10000));
	
    [code_2, stats2] = mexFisherEncodeHelperSP('encodestats', cpp_handle, feats(:,10001:end));
    
    stats = stats1 + stats2;
    code2 = mexFisherEncodeHelperSP('getfkstats', cpp_handle, stats);
    
    mexFisherEncodeHelperSP('clear', cpp_handle);
	
    if sum(~eq(code1, code2)) == 0,
		fprintf('Equal!');
	end
    
end

function test_accumulate_1
	codebook_file = '/net/per900a/raid0/plsang/trecvidmed10/feature/bow.codebook.trecvidmed10.devel/densetrajectory.mbh/data/codebook.gmm.256.mat';
	load(codebook_file);
	
	fisher_params.grad_weights = false;		% "soft" BOW
    fisher_params.grad_means = true;		% 1st order
    fisher_params.grad_variances = true;	% 2nd order
    fisher_params.alpha = single(1.0);		% power normalization (set to 1 to disable)
    fisher_params.pnorm = single(0.0);		% norm regularisation (set to 0 to disable)
	
    feats = single(rand(192, 2000));
    
    cpp_handle = mexFisherEncodeHelperSP('init', codebook, fisher_params);
	 
	code1 = mexFisherEncodeHelperSP('encode', cpp_handle, feats);
    
    mexFisherEncodeHelperSP('clear', cpp_handle);
    
    cpp_handle = mexFisherEncodeHelperSP('init', codebook, fisher_params);
	 
	mexFisherEncodeHelperSP('accumulate', cpp_handle, feats(:,1:1000));
    
    mexFisherEncodeHelperSP('accumulate', cpp_handle, feats(:,1001:2000));
    
    code2 = mexFisherEncodeHelperSP('getfk', cpp_handle);
    
    if sum(~eq(code1, code2)) == 0,
		fprintf('Equal!');
	end
    
end