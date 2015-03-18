
% Setup constants for example
%filename = '/net/per900a/raid0/plsang/tools/improved_trajectory_release/test_sequences/person01_boxing_d1_uncomp.avi'; 
filename = '/net/per610a/export/das11f/plsang/dataset/MED/LDCDIST-RSZ/LDC2011E41/MED11EvaluationData/video/MED11TEST/HVC504244.mp4';

% Set up the mpeg audio decode command as a readable stream
cmd = ['LD_PRELOAD=/net/per900a/raid0/plsang/usr.local/lib/libstdc++.so /net/per610a/export/das09f/satoh-lab/ejmp/DenseTrackStab ', filename];

p = popenr_edu(cmd);

if p < 0
  error(['Error running popenr(', cmd,')']);
end

X = [];

tic

while true,

  % Get the next chunk of data from the process
  Y = popenr_edu(p, 436);
  
  if isempty(Y), break; end;
  
  X = [X Y];
  
end

toc

% Close pipe
popenr_edu(p, -1);


