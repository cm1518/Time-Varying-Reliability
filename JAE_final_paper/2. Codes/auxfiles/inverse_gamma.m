function y = inverse_gamma(n,a,b);
% PURPOSE: random inverse gammma IG(a,b);
%---------------------------------------------------
% USAGE:   y = inverse_gamma(n,a,b);
% where:   n = sample
% 			  a = shape, b = scale
%---------------------------------------------------      
% RETURNS: y = random vector inv gamma draw mean b/(a-1)
% --------------------------------------------------

% written by:
% Matteo Ciccarelli

if nargin ~= 3
   error('Wrong # of arguments to norm_rnd');
end;

if any(any(a<=0))
   error('inverse_gamma: parameter a is wrong')
end

if any(any(b<=0))
   error('inverse_gamma: parameter b is wrong')
end

chi = chis_rnd(n,2*a);
y = 2*b./chi;
