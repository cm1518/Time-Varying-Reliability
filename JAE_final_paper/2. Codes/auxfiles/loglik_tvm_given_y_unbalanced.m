function l =  loglik_tvm_given_y_unbalanced(m, u ,sample_vector, sigma_tr, omega, bet, signu)
% modified by Mu-Chun Wang to incorporate multiple instruments and
% time-varying parameters
% Instruments are allowed to be unbalanced with different starting and
% ending sample w.r.t. to data
%
% sample_vector is a M x M matrix with each row indicating the start and
% end of the proxy sample: 
% example: two proxies m1 and m2 with m1 starting from 1 to 100 and m2 from
% 21 to 74. the associated sample_vector is [1 100; 21 74];
%
% m is a M x 1 cell of instruments, each cell contains a column vector of
% instrument
% bet is a M x 1 cell of TVP with M instruments
% signu is a M x 1 vector of proxy error std 

M = size(m,1);
scale_mat = omega'/sigma_tr;
e = scale_mat*u'; % dimension 1 x T1

for i = 1:M


    z = m{i,1}' - bet{i,1}'.*e(1,sample_vector(i,1):sample_vector(i,2));
    z = z'./signu(i,1);
    l_(i) = sum(log(normpdf(z')));
end

l=sum(l_);



