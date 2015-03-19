
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

