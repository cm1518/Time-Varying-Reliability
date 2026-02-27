function [xi_s, P_s] = kalman_smoother(y,x,A,H,R,F,Q,T,r,xi10,P10)
% Kalman smoother.
% Using notation from Hamilton 
% y(t) = A(t)*x(t) + H(t)*xi(t) + w(t), eps(t)~N(0,R(t))
% xi(t+1) = F*xi(t) + v(t+1), v(t)~N(0,Q(t))

% y(t) is n x 1
% A(t)' is n x k 
% x(t) is k x 1
% H(t)' is n x r
% R(t) is n x n
% xi(t) is r x 1
% F(t) is r x r
% Q(t) is r x r
% MSE matrix of state is P_t+1|t is r x r
% initial state for xi_1|0 and P_1|0 are provided

% input matrices are
% y is n x T
% x is k x T 
% A is k x n x T 
% H is r x n x T
% R is n x n x T 
% F is r x r x T
% Q is r x r x T 

% Kalman Filter
% Initialization

xi_tt = zeros(r,T); % xi_t|t
xi_pred = zeros(r,T); % xi_t+1|t
xi_s = zeros(r,T);

P_tt = zeros(r,r,T); % P_t|t
P_pred = zeros(r,r,T); % P_t+1|t
P_s = zeros(r,r,T);

xi_pred(:,1) = xi10;
P_pred(:,:,1) = P10;



for t=1:T
    if isempty(x)
        cfe = y(:,t) - H(:,:,t)'*xi_pred(:,t);   % conditional forecast error
    else
        cfe = y(:,t) - A(:,:,t)'*x(:,t) - H(:,:,t)'*xi_pred(:,t);   % conditional forecast error
    end
    f = H(:,:,t)\(H(:,:,t)'*P_pred(:,:,t)*H(:,:,t) + R(:,:,t));    % variance of the conditional forecast error
    %inv_f = inv(f);
    xi_tt(:,t) = xi_pred(:,t) + P_pred(:,:,t)*f*cfe;
    P_tt(:,:,t) = P_pred(:,:,t) - P_pred(:,:,t)*f*H(:,:,t)'*P_pred(:,:,t);

    if t < T
        xi_pred(:,t+1) = F(:,:,t)*xi_tt(:,t);
        P_pred(:,:,t+1) = F(:,:,t)*P_tt(:,:,t)*F(:,:,t)'; + Q(:,:,t);
    end
end

xi_s(:,T)=xi_tt(:,T);
P_s(:,:,T)=P_tt(:,:,T);
% Smoothing
for t=T-1:-1:1
    J = P_tt(:,:,t)*F(:,:,t)'/P_pred(:,:,t+1);
    xi_s(:,t) =  xi_tt(:,t) + J*(xi_s(:,t+1)-xi_pred(:,t+1));
    P_s(:,:,t) = P_tt(:,:,t) + J*(P_s(:,:,t+1)-P_pred(:,:,t+1))*J';
end
