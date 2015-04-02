function sge_save( output_file, code )
    [output_dir, file_name] = fileparts(output_file);
    if ~exist(output_dir, 'file'),
        mkdir(output_dir);
        while ~strcmp(file_name, 'feature'),
            change_perm(output_dir, 777, 0);
            [output_dir, file_name] = fileparts(output_dir);
        end
    end
    
    save( output_file, 'code');
    change_perm(output_file); 
    
end
