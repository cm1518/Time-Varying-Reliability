function [Imc, sp, p_filt, p_smooth, pd]= simstate_ms(xi,lik,pinit,smoothdens)

% simulate  indicators with L states 
% from the posterior distribution proportional to 
% likelihood*unrestricted Markov switching prior

% (all indicators are assumed to start in state j with probability pinit)

% Sampling method used: multi move sampling (forward filtering - backward sampling)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input: 

% xi .. transition matrix  of  a processes with L states

% lik .. likelihood  : L  times T 
%  lik(k,t) is the likelihood of all data at time t which are relevant for process m,
%    if we assume that the process m takes the value k at time t

% pinit ... inital distribution

% Output:

% Imc ... path of the indicator sampled from the posterior (1 times (T+1) );
%         including the value at t=0.
% comments:
% 1.  Imc(1,t+1) refers to the value of process m at time t

% sp ... sum of the logarithm of all normalizing constants obtained during
% comments:
% 1. sp  is identical with the log of the marginal likelihood of the conditioning parameters
%    where the m-th indicator process I is integrated out
% 2. sp might give a wrong value if you canceled constants when computing the likelihood
%    (note that even 1/sqrt(2*pi) matters in a setting with a random partion of the data
%    depending on some of the parameters of interest)

% Author: Sylvia Fruehwirth-Schnatter
% Last change: November 7, 2006

T=size(lik,2);
L=size(xi,1); % total number of states


% 1.  forward filtering: compute the filter probabilities P(I(t,m)=k|data up to t) 
%     recursively with t running from 2 to T 
%
%     the procedure is vectorized for size(xi,3)=1 in which case the filter probabilities 
%     P(I(t,m)=k|data up to t)  are computed simultaniously for all components 
%     m = 1, ... ,M  and realisations k = 1, ..., L

p_filt=zeros(L,T+1);
p_filt(:,1)=pinit;
sp=0;


for t=1:T
    p = (xi'*p_filt(:,t)).*lik(:,t);
    st=sum(p,1);
    sp = sp + log(st);
    p_filt(:,t+1) = p/st;  
end   

% 2. backward sampling: sample I(t,:) from the smoothed probabilities P(I(t,m)=k|data up to T) 
%   backwardly with t running from T to 2  

% 2.a. sample  I(T,:) from the filter probabilities P(I(T,m)=k|data up to T)

Imc=ones(T+1,1);  

if L>2
    Imc(T+1,1) = sum(cumsum(p_filt(1:L-1,T+1)) < rand) + 1;    
else
    Imc(T+1,1) = (p_filt(1,T+1) < rand) + 1;    
end    
pd =log(p_filt(Imc(T+1,1),T+1));

if smoothdens p_smooth = p_filt; else p_smooth =[]; end

for t = (T):-1:1
    %  compute the marginal smoother density  
    
    %p_smooth(:,t) = p_filt(:,t).* sum ( xi.*repmat( (p_smooth(:,t+1)./ (xi'* p_filt(:,t)))',L,1) ,2);
    
    if smoothdens p_smooth(:,t) = p_filt(:,t).*  ( xi* (p_smooth(:,t+1)./ (xi'* p_filt(:,t))) ); end
    
    %  simulate 
    
    p = p_filt(:,t) .* xi(:,Imc(t+1,1));
    p = p/sum(p);
    if L>2
        Imc(t,1) = sum(cumsum(p(1:L-1)) < rand) + 1; 
    else
        Imc(t,1) = (p(1) < rand) + 1; 
    end
    pd=pd+log(p(Imc(t,1)));  
    
end

Imc=Imc'; 
 