
% Setup constants for example
filepath = '/net/per900a/raid0/plsang/dataset/MED10_Resized/HVC1060.mp4'; %HVC180809.mp4
[vpath, fname, fext] = fileparts(filepath);

start_frame = 1000;
end_frame = 1100;
tmpdir = '/net/per900a/raid0/plsang/tmp';
[~, tmpname] = fileparts(tempname);
tmpfile = sprintf('%s/%s', tmpdir, tmpname);
tmpfile
fh = fopen(tmpfile, 'w');
fprintf(fh, '%s %d %d', fname, start_frame, end_frame);
fclose(fh);
% creat a tmp file to specify input information
binpath = '/net/per900a/raid0/plsang/tools/stip-2.0-linux/bin/stipdet';


%cmd = ['/net/per900a/raid0/plsang/tools/stip-2.0-linux/bin/stipdet -i ./test/med10_HVC51.lst -ext .mp4 -vpath /net/sfv215/export/raid4/ledduy/trecvid-med-2011/devel/MED10/ -o ./test/med10_HVC51.stip -det harris3d -vis no'];
%cmd = sprintf('LD_LIBRARY_PATH=/home/plsang/usr/lib_cxx:/home/plsang/usr/local/lib:/usr/local/lib:/home/plsang/usr/boost-1.48.0/stage/lib:/net/per900a/raid0/plsang/usr.local/lib %s -i %s -vpath %s/ -ext %s -det harris3d -vis no -stdout yes', binpath, tmpfile, vpath, fext);
cmd = sprintf('LD_LIBRARY_PATH=/net/per900a/raid0/plsang/usr.local/lib %s -i %s -vpath %s/ -ext %s -det harris3d -vis no -stdout yes', binpath, tmpfile, vpath, fext);
cmd
%cmd = ['/home/plsang/code/dense_trajectory_release/release/DenseTrack_MBH ', filename, ' -S 5154 -E 5184 -G 1'];

p = popenr_stip(cmd);

if p < 0
  error(['Error running popenr(', cmd,')']);
end

X = [];

popenr_stip(p, 1000, 'readline');
popenr_stip(p, 1000, 'readline');
tic

while true,
  % Get the next chunk of data from the process
  Y = popenr_stip(p, 171, 'float');
  if isempty(Y), break; end;
  Y(1:9)
  X = [X Y];
  
end

toc

% Close pipe
popenr_stip(p, -1);
delete(tmpfile)


