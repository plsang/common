run('/net/per610a/export/das11f/plsang/codes/opensource/cvx/cvx_startup');

echo on

m = 10000;
S = rand(m,1);
%y = 2*(randi(2, m, 1)-1)-1;
y = [ones(100, 1); -ones(m-100, 1)];
%y = randi(1, m, 1);

cvx_begin
   variable x(1);
   variable t(m);
   minimize( sum(t) );
   subject to
      t >= 0;
      t >= y.*(S-x);
      x <= max(S);
      x >= 0;
cvx_end

echo off
