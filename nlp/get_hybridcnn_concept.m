 function get_hybridcnn_concept
    hybrid_file = '/net/per920a/export/das14a/satoh-lab/plsang/places205/hybridCNN_upgraded/categoryIndex_hybridCNN.csv';
    imagenet_synset_file = '/net/per610a/export/das11f/plsang/deepcaffe/caffe-rc/data/ilsvrc12/synset_words.txt';
    
    fh = fopen(hybrid_file);
    c1 = textscan(fh, '%s %d');
    fclose(fh);
    
    fh = fopen(imagenet_synset_file);
    c2 = textscan(fh, '%s %[^\n]');
    fclose(fh);
    
    c1 = c1{1};
    concepts = {};
    for ii=1:length(c1),
        c = c1{ii};
        mem_idx = find(ismember(c2{1}, c));
        if ~isempty(mem_idx),
            concepts{ii} = c2{2}{mem_idx};
        else
            splits = regexp(c, '\/', 'split');
            new_c = strrep(splits{2}, '_', ' ');
            if length(splits) > 2,
                new_c = sprintf('%s, %s', new_c, strrep(splits{3}, '_', ' '));
            end
            concepts{ii} = new_c;
        end
    end
    
    output_file = '/net/per920a/export/das14a/satoh-lab/plsang/places205/hybridCNN_upgraded/categoryIndex_hybridCNN.combined.csv';
    length(concepts)
    fh = fopen(output_file, 'w');
    for ii=1:length(concepts),
        fprintf(fh, '%s\n', concepts{ii});
    end
    fclose(fh);
 end
 