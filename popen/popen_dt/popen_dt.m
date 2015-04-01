function X = popen_dt()

    % Setup constants for example
    % filename = '/net/per900a/raid0/plsang/dataset/MED11_Resized/MED11DEV/HVC000965.mp4'; %HVC180809.mp4
    filename = '/net/per610a/export/das11f/plsang/codes/opensource/improved_trajectory_release/test_sequences/person01_boxing_d1_uncomp.avi';

    % Set up the mpeg audio decode command as a readable stream
    % cmd = ['/net/per900a/raid0/plsang/tools/dense_trajectory_release/release/DenseTrack_MBH ', filename, ' -G 1'];
    %cmd = ['/home/plsang/code/dense_trajectory_release/release/DenseTrack_MBH ', filename, ' -S 5154 -E 5184 -G 1'];
    bin = 'LD_PRELOAD=/net/per900a/raid0/plsang/usr.local/lib/libstdc++.so /net/per610a/export/das11f/plsang/codes/opensource/improved_trajectory_release/release/DenseTrackStab_HOGHOFMBH';

    cmd = sprintf('%s %s', bin, filename);

    p = popenr(cmd);

    if p < 0
      error(['Error running popenr(', cmd,')']);
    end

    BLOCK_SIZE=20000;

    X = zeros(396, BLOCK_SIZE, 'single');
    ptr = 1;

    while true,

      % Get the next chunk of data from the process
      Y = popenr(p, 396, 'float');
      
      if isempty(Y), break; end;
      
      X(:, ptr) = Y;
      ptr = ptr + 1;
      
    end

    X(:, ptr:end) = [];

    % Close pipe
    popenr(p, -1);

end

