
% Setup constants for example
filename = '/net/per900a/raid0/plsang/dataset/MED11_Resized/MED11DEV/HVC000965.mp4'; %HVC180809.mp4

% Set up the mpeg audio decode command as a readable stream
cmd = ['/net/per900a/raid0/plsang/tools/dense_trajectory_release/release/DenseTrack_MBH ', filename, ' -G 1'];
%cmd = ['/home/plsang/code/dense_trajectory_release/release/DenseTrack_MBH ', filename, ' -S 5154 -E 5184 -G 1'];

p = popenr(cmd);

if p < 0
  error(['Error running popenr(', cmd,')']);
end

X = [];

tic

while true,

  % Get the next chunk of data from the process
  Y = popenr(p, 199, 'float');
  
  if isempty(Y), break; end;
  
  X = [X Y];
  
end

toc

% Close pipe
popenr(p, -1);


