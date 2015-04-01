function X = popen_full()

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

    fulldim = 396;
    X = zeros(fulldim, BLOCK_SIZE, 'single');
    ptr = 1;
    
    pblock = 5000;
    numel = pblock * fulldim;
    
    while true,

      % Get the next chunk of data from the process
      Y = popenr(p, numel, 'float');
      
      if size(Y, 1) ~= numel,
        ncol = size(Y, 1)/fulldim;
        X(:, ptr:ptr+ncol-1) = reshape(Y, fulldim, ncol);
        ptr = ptr + ncol;
        break;
      else
        X(:, ptr:ptr + pblock - 1) = reshape(Y, fulldim, pblock);
        ptr = ptr + pblock;
      end
      
    end

    X(:, ptr:end) = [];

    % Close pipe
    popenr(p, -1);

end

