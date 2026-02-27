function l =  loglik_tvm_given_y_x(m, u, sigma_tr, omega, bet, signu,x,a)
% modified by Mu-Chun Wang to incorporate multiple instruments and
% time-varying parameters 
% 
% bet is a T x M matrix of TVP with M instruments
% signu is a M x 1 vector of proxy error std 
% with exogenous regressors x (nxt) and coefficient vector a (1xn)

scale_mat = omega'/sigma_tr;
SIGMA = diag(signu.^2);

z = m' - bet'.*repmat(scale_mat*u',size(m,2),1) - a*x;

l = sum(log(mvnpdf(z', [], SIGMA)));




