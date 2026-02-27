function [bdraw,log_lik] = carter_kohn_univariate(y,Z,Ht,Qt,t,B0,V0)
% Carter and Kohn (1994), On Gibbs sampling for state space models.

% Kalman Filter
bp = B0;
Vp = V0;
bt = zeros(t,1);
Vt = zeros(1,t);
log_lik = 0;
for i=1:t
    R = Ht(i,:);
    H = Z(i,:);
    cfe = y(:,i) - H*bp;   % conditional forecast error
    f = H*Vp*H' + R;    % variance of the conditional forecast error
    %inv_f = inv(f);
    inv_f = H'/f;
    %log_lik = log_lik + log(det(f)) + cfe'*inv_f*cfe;
    %btt = bp + Vp*H'*inv_f*cfe;
    %Vtt = Vp - Vp*H'*inv_f*H*Vp;
    btt = bp + Vp*inv_f*cfe;
    Vtt = Vp - Vp*inv_f*H*Vp;
    if i < t
        bp = btt;
        Vp = Vtt + Qt;
    end
    bt(i,:) = btt;
    Vt(:,i) = Vtt;
end

% draw Sdraw(T|T) ~ N(S(T|T),P(T|T))
bdraw = zeros(t,1);
bdraw(t,:) = mvnrnd(btt,Vtt,1);

% Backward recurssions
for i=1:t-1
    bf = bdraw(t-i+1,:)';
    btt = bt(t-i,:)';
    Vtt = Vt(:,t-i);
    f = Vtt + Qt;
    %inv_f = inv(f);
    inv_f = Vtt/f;
    cfe = bf - btt;
    %bmean = btt + Vtt*inv_f*cfe;
    %bvar = Vtt - Vtt*inv_f*Vtt;
    bmean = btt + inv_f*cfe;
    bvar = Vtt - inv_f*Vtt;
    
    bdraw(t-i,:) = mvnrnd(bmean,bvar,1); %bmean' + randn(1,m)*chol(bvar);
end
%bdraw = bdraw';