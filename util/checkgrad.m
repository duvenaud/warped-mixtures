function [d dy dh] = checkgrad(f, X, e, varargin)

% checkgrad checks the derivatives in a function, by comparing them to finite
% differences approximations. The partial derivatives and the approximation
% are printed and the norm of the difference divided by the norm of the sum is
% returned as an indication of accuracy.
%
% usage: checkgrad('f', X, e, other, ...)
%
% where X is the argument and e is the small perturbation used for the finite
% differences, and "other, ..." are optional additional parameters which get
% passed to f. The function f should be of the type 
%
% [fX, dfX] = f(X, other, ...)
%
% where fX is the function value and dfX is a vector of partial derivatives.
%
% Carl Edward Rasmussen, 2011-12-19

Z = unwrap(X);
[y dy] = eval([f, '(X, varargin{:})']);       % get the partial derivatives dy
dy = unwrap(dy);

dh = zeros(length(Z),1) ;
for j = 1:length(Z)
  dx = zeros(length(Z),1);
  dx(j) = dx(j) + e;                               % perturb a single dimension
  y2 = eval([f, '(rewrap(X,Z+dx), varargin{:})']);
  y1 = eval([f, '(rewrap(X,Z-dx), varargin{:})']);
  dh(j) = (y2 - y1)/(2*e);
end

disp('   Analytic  Numerical')
disp([dy dh])                                           % print the two vectors
d = norm(dh-dy)/norm(dh+dy);       % return norm of diff divided by norm of sum
