run('/net/per610a/export/das11f/plsang/codes/opensource/cvx/cvx_startup');

echo on

m = 1000;
%S = rand(m,1);
y = 2*(randi(2, m, 1)-1)-1;

d = 100;
X = rand(d, m);
Sim = rand(d, 1);
%S = X'*Sim;
%w = rand(d, 1);
%wSim = w.*Sim;
%S = X'*wSim;

cvx_begin
   variable x(1)
   variable t(m)
   variable w(d)
   
   minimize( sum(t) )
   subject to
      t >= 0;
      t >= y.*((X'*(w.*Sim))-x);
      {w} <In> simplex(d);
cvx_end

echo off
