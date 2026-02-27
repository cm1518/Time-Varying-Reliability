function l =  loglik_m_given_y_mult(m, u, sigma_tr, omega, bet, signu, sample_vector)
% modified by Mu-Chun Wang to incorporate multiple instruments 
% sample_vector is a M x 2 matrix indicating the starting (first column)
% and ending (second column) row of the proxy w.r.t. data
%
%

M = size(m,1);
scale_mat = omega'/sigma_tr;
e = scale_mat*u'; % dimension 1 x T1
for i = 1:M
    SIGMA = signu(i,1).^2;

    z = m{i,1}' - bet(i,1).*e(1,sample_vector(i,1):sample_vector(i,2));

    l_(i) = sum(log(mvnpdf(z', [], SIGMA)));
end


l=sum(l_);



