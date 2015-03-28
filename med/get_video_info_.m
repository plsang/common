
function [duration, fps] = get_video_info_(video_file)
    
    % duration
    cmd_d = sprintf('ffmpeg -i %s 2>&1 | sed -n "s/.*Duration: \\([^,]*\\), .*/\\1/p"', video_file);
    [~, duration] = system(cmd_d);
    
    if isempty(duration), error('empty duration'); end
    
    pattern = '(?<hh>\d\d)\:(?<mm>\d\d)\:(?<ss>\d\d.\d+)';
    info = regexp(strtrim(duration), pattern, 'names');
    duration = str2num(info.hh)*3600 + str2num(info.mm)*60 + str2num(info.ss);
    
    
    % fps
    cmd_fps = sprintf('ffmpeg -i %s 2>&1 | sed -n "0,/.*, \\(.*\\) fps.*/s/.*, \\(.*\\) fps.*/\\1/p"', video_file);
    [~, fps] = system(cmd_fps);	
    
    if isempty(fps), error('empty fps'); end
    
    fps = str2num(strtrim(fps));
    
end
