
function med14_gen_web_metadata()
	fprintf('Loading metadata...\n');
    medmd_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/medmd_2014_devel_ps.mat';
    load(medmd_file, 'MEDMD'); 

	%% gen list kindredtest
    output_file = '/net/per610a/export/das11f/plsang/trecvidmed14/metadata/common/trecvidmed14.kindredtest.lst';
    fh = fopen(output_file, 'w');
    for ii=1:length(MEDMD.RefTest.KINDREDTEST.clips),
        fprintf(fh, '%s\n', MEDMD.RefTest.KINDREDTEST.clips{ii});
    end
    fclose(fh);
	
    event_ids = arrayfun(@(x) sprintf('E%03d', x), [21:40], 'UniformOutput', false);
    for ii=1:length(event_ids),
        event_id = event_ids{ii};
        output_file = sprintf('/net/per610a/export/das11f/plsang/trecvidmed14/metadata/common/kindredtest/%s.kindredtest.lst', event_id);    
        fh = fopen(output_file, 'w');
        for jj=1:length(MEDMD.RefTest.KINDREDTEST.ref.(event_id)),
            fprintf(fh, '%s\n', MEDMD.RefTest.KINDREDTEST.ref.(event_id){jj});
        end
        fclose(fh);
    end
    
end
