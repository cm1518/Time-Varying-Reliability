function [SVAR, draws]=main_MSBPSVAR_Minn_func_v1(data,proxy,sample_vector,options_,priors,initS)

% This function esstimates the Bayesian Markov-Switching-IV-SVAR based on Caldara and Herbst
% (2019). The prior for the VAR bas been changed to the Giannone, Lenza and
% Primiceri (2015) setting. This version only has two hyperparameters:
% lambda (overall tightness, expressed as standard deviation) and alpha
% (lag decay).

% data is a n x T matrix of VAR obs
% proxy is a M x 1 cell, each cell contains a vector of proxy obs
% sample_vector is a M x 2 matrix indicating the starting (first column)
% and ending (second column) row of the proxy w.r.t. data.
% Ex. if there is only one proxy and it has starts and ends with VAR data,
% sample_vector = [1 T];


% The proxy equation is
% m(t) = beta(t)*e_shock(t) + nu(t)
% nu(t) ~ N(0,signu)
%
% beta(t) follow 2 states Markov process

% This code is a modified verson of Caldara and Herbst (2019)

% by Mu-Chun Wang 
% September, 2021



%------------------------------------------------------------
% SETTINGS
%------------------------------------------------------------
p = options_.p;                                 % Number of lags
nex_ = 1;                               % Constant
Horizon = options_.Horizon;                           % Horizon for calculation of impulse responses
nd = options_.nrep;                            % Number of draws in MC chain
bburn = 0.25*nd;                         % Burn-in period
ptileVEC = [0.05 0.16 0.50 0.84 0.95]; % Percentiles


% Priors 
% K priors must be imposed on vec(PIE), beta and SIGMA

% beta ~ N(bbar,Bbar)
bbar=priors.bbar;
Bbar=priors.Bbar;
      

% (pii) ~ beta(a,b)
pie11_0=priors.pie11_0;
pie22_0=priors.pie22_0;

s0 = priors.s0;
nu0 = priors.nu0;


K=2; % 2 states hard-coded
nIV=1; % 1 instrument hard-coded


%%
% b_0_prmean=priors.b_0_prmean;  % initial prior mean of time-varing roxy regression coefficient
% b_0_prvar=priors.b_0_prvar; % initial prior variance of of time-varing proxy regression coefficient
% sigma_prmean=priors.sigma_prmean;
% sigma_prvar=priors.sigma_prvar;


nadjust = 500; % window size of the automatic stabilization, usually doesn' matter.



pos=priors.pos; % this is important! the position vector indicating stationary variable.
Vc=priors.Vc;

if ~isfield(priors,'psitune')
    priors.psitune=0;
end;

if ~isfield(options_,'irf_sign')
    options_.irf_sign=1;
end;
if ~isfield(options_,'impactnorm')
    options_.impactnorm=0;
end;
if ~isfield(options_,'impactsize')
    options_.impactsize=1;
end;

%------------------------------------------------------------
% Sampler Settings
%------------------------------------------------------------
% this is the mixture probability for the "RW" IG propsal on SIGMA
rwmh_sigma_prob = options_.rwmh_sigma_prob;
rwmh_df = options_.rwmh_df;                            % Tune-up parameter for mixture proposal distribution for (\Phi,\Sigma)
nu = rwmh_df;                           % Tune-up parameter for mixture proposal distribution for (\Phi,\Sigma)

YY = data;
MM = proxy;

%% GLP hyperparameter maximization. The current version maximizes over the actual data only, without taking into account of proxies.     
if priors.MP==1
    if priors.psitune==0
        res = bvarGLP(YY,p,'mcmc',0,'sur',0,'noc',0,'MNalpha',1,'MNpsi',0,'pos',pos);
    elseif priors.psitune==1
        res = bvarGLP(YY,p,'mcmc',0,'sur',0,'noc',0,'MNalpha',1,'MNpsi',0,'MNpsitune',1,'pos',pos);
    end
    lambda=res.postmax.lambda;
    alpha=res.postmax.alpha;
elseif priors.MP==0
    lambda=priors.lambda;
    alpha=priors.alpha;
end
%% data matrix manipulations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dimensions
[TT,n]=size(YY);
k=n*p+1;         % # coefficients for each equation


% constructing the matrix of regressors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x=zeros(TT,k);
x(:,1)=1;
for i=1:p
    x(:,1+(i-1)*n+1:1+i*n)=lag(YY,i);
end

y0=mean(YY(1:p,:),1);
X=x(p+1:end,:);
Y=YY(p+1:end,:);
[T,n]=size(Y);

% MN prior mean
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
b=zeros(k,n);
diagb=ones(n,1);
diagb(pos)=0;   % Set to zero the prior mean on the first own lag for variables selected in the vector pos
b(2:n+1,:)=diag(diagb);


nv      = size(Y,2);     %* number of variables */
nobs    = size(Y,1);  %* number of observations */


n = nv;


% Define matrices to compute IRFs      
J = [eye(n);repmat(zeros(n),p-1,1)]; % Page 12 RWZ
F = zeros(n*p,n*p);    % Matrix for Companion Form
I  = eye(n);
for i=1:p-1
    F(i*n+1:(i+1)*n,(i-1)*n+1:i*n) = I;
end

% priors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% residual variance of AR(1) for each variable
SS=zeros(n,1);
for i=1:n
    ar1=ols1(Y(2:end,i),[ones(T-1,1),Y(1:end-1,i)]);
    SS(i)=ar1.sig2hatols;
end
d=n+2;
psi=SS*(d-n-1);

omega=zeros(k,1);
omega(1)=Vc;
for i=1:p
    omega(1+(i-1)*n+1:1+i*n)=(d-n-1)*(lambda^2)*(1/(i^alpha))./psi;
end

% prior scale matrix for the covariance of the shocks
PSI=diag(psi);
% Estimation Preliminaries
ndum = 0;
nex = nex_;

% posterior mode of the VAR coefficients
betahat=(X'*X+diag(1./omega))\(X'*Y+diag(1./omega)*b);

% VAR residuals
epshat=Y-X*betahat;

%F(1:n,1:n*p)    = B(1:n*p,:)';
F(1:n,1:n*p)    = betahat(2:end,:)';




%------------------------------------------------------------
%% MCMC Algorithm
%------------------------------------------------------------

record=0;     
counter = 0;
isave=0;

disp('                                                                  ');
disp('        BAYESIAN ESTIMATION OF VAR VIA BLOCK MCMC                 ');
disp('                                                                  ');

% Drop constant from M
nIV=size(proxy,1);
for i=1:nIV
    MM_nT(i,1)=size(proxy{i,1},1);
end




%     [Q, ~] = qr(randn(n, nIV));
Xstar = randn(n, 1);
Q = Xstar / norm(Xstar);

S=PSI + epshat'*epshat + (betahat-b)'*diag(1./omega)*(betahat-b);
[V E]=eig(S);
Sinv=V*diag(1./abs(diag(E)))*V';
eta=mvnrnd(zeros(1,n),Sinv,T+d);
drawSIGMA=(eta'*eta)\eye(n);
Sigmadraw=drawSIGMA;
%[cholSIGMA,junk]=chol(drawSIGMA);
%betadraw=betahat+mvnrnd(zeros(k,1),(x'*x+diag(1./omega))\eye(k),n)'*cholSIGMA;
cholSIGMA=cholred((drawSIGMA+drawSIGMA')/2);
cholZZinv = cholred((x'*x+diag(1./omega))\eye(k));
Bdraw=betahat + cholZZinv'*randn(size(betahat))*cholSIGMA;
Udraw = Y-X*Bdraw;      % Store residuals for IV regressions

LC =chol(Sigmadraw,'lower');
A0chol = (LC')\eye(size(LC,1));

% initial values for Gibbs-sampler
betadraw=zeros(1,K);
% sophisticated guesses
scale_mat = Q(:,1)'/LC;
Xe = (scale_mat*Udraw')'; % dimension 1 x T1

dep=MM{1,1};
indep=Xe(sample_vector(1,1):sample_vector(1,2),1);
St=kmeans(dep,K); % obtaining first guess of states using kmeans from Statistics and Machine Learning Toolbox
%St=initS;
Nj=statecount(St',K);

pie11draw=Nj(1,1)/sum(Nj(1,:));
pie22draw=Nj(2,2)/sum(Nj(2,:));
piedraw=[pie11draw 1-pie22draw; 1-pie11draw pie22draw];

t =size(St,1);
for i=1:K
    y_=dep(St==i,1);
    X_=indep(St==i,:);
    betadraw(:,i)=(X_'*X_)\(X_'*y_);
end
for it=1:t      
    bett(it,1)= betadraw(St(it,1));        
end
bet{1,1}=bett;
signu2 = ( (MM{1,1}-Xe(sample_vector(1,1):sample_vector(1,2),1).*bet{1,1})'*(MM{1,1}-Xe(sample_vector(1,1):sample_vector(1,2),1).*bet{1,1}) + nu0*s0);



lnp0 = loglik_tvm_given_y_unbalanced(MM, Udraw(ndum+1:end, :),sample_vector, LC, Q(:,1), bet, sqrt(signu2));

% Initialize Omega1 for IRFs
nshocks=1;
Omega1 = [LC(:,nshocks);zeros((p-1)*n,nshocks)];


nq = 1;
acpt_rf   = 0;
acpt_Q    = 0;
acpt_ic =   0;
acpt_q    = zeros(1,nIV);  
acpt_r    = zeros(1,nIV);  
Fstar = F;
Sigmadrawstar = Sigmadraw;


nCalc=0;
% MCMC Chain 
% Define objects that store the draws
Ltilde = zeros(nd-bburn,Horizon+1,n,nshocks);                      % define array to store IRF
%LtildeAdd = zeros(nd-bburn,Horizon+1,n+nCalc,nshocks);
%irfCalc = zeros(nd-bburn,Horizon+1,nCalc,nshocks);                     % store labor productivity IRF
W = zeros(nd-bburn,Horizon+1,n,nshocks);                         % define array to store FVD
REL = zeros(nd-bburn,t);
SIG =zeros(nd-bburn,1);
BETdraw =zeros(nd-bburn,K);
PROB1 = zeros(nd-bburn,t);



while isave<nd

    %------------------------------------------------------------
    % Gibbs Sampling Algorithm
    %------------------------------------------------------------
    % STEP ONE: Draw from the B, SigmaB | Y
    %------------------------------------------------------------
    % Step 1: Draw from the marginal posterior for Sigmau p(Sigmau|Y,X)
    if (rand()<rwmh_sigma_prob)     % draw sigma* ~ IW(sigma, nu), phi*|sigma*, Y
        nu = nobs;
        Sigmadrawstar = iwishrnd(Sigmadraw, nu);

        cholSIGMA=cholred((drawSIGMA+drawSIGMA')/2);
        cholZZinv = cholred((x'*x+diag(1./omega))\eye(k));
        Bdrawstar=betahat + cholZZinv'*randn(size(betahat))*cholSIGMA;
        Udrawstar = Y-X*Bdrawstar;              % Store residuals for IV regressions

        LCstar    = chol(Sigmadrawstar,'lower');
        A0cholstar    = (LCstar')\eye(size(LCstar,1));

        %Fstar(1:n,1:n*p)    = Bdrawstar(1:n*p,:)';
        Fstar(1:n,1:n*p)    = Bdrawstar(2:end,:)';

        lnp1 = loglik_tvm_given_y_unbalanced(MM, Udrawstar(ndum+1:end, :),sample_vector, LCstar, Q(:,1), bet, sqrt(signu2));

        q1 = pdf_ln_iwish(Sigmadraw, nu, Sigmadrawstar);
        q0 = pdf_ln_iwish(Sigmadrawstar, nu, Sigmadraw);

        psigma1 = pdf_ln_iwish(S, T+d, Sigmadrawstar);
        psigma0 = pdf_ln_iwish(S, T+d, Sigmadraw);            

        % metropolis hastings
        alp = exp((lnp1+psigma1) - (lnp0+psigma0) - (q1 - q0));



    else                            % draw phi*, sigma* ~ phi, sigma | Y

        eta=mvnrnd(zeros(1,n),Sinv,T+d);
        drawSIGMA=(eta'*eta)\eye(n);
        Sigmadrawstar=drawSIGMA;

        cholSIGMA=cholred((drawSIGMA+drawSIGMA')/2);
        cholZZinv = cholred((x'*x+diag(1./omega))\eye(k));
        Bdrawstar=betahat + cholZZinv'*randn(size(betahat))*cholSIGMA;


        Udrawstar = Y-X*Bdrawstar;      % Store residuals for IV regressions

        LCstar    = chol(Sigmadrawstar,'lower');
        A0cholstar    = (LCstar')\eye(size(LCstar,1));

        %Fstar(1:n,1:n*p)    = Bdrawstar(1:n*p,:)';
        Fstar(1:n,1:n*p)    = Bdrawstar(2:end,:)';

        lnp1 = loglik_tvm_given_y_unbalanced(MM, Udrawstar(ndum+1:end, :),sample_vector, LCstar, Q(:,1), bet, sqrt(signu2));

        % metropolis hastings
        alp = exp(lnp1 - lnp0);

    end 

    if rand < alp
        lnp0 = lnp1;

        Udraw = Udrawstar;
        LC = LCstar;
        A0chol = A0cholstar;

        F = Fstar;
        Sigmadraw = Sigmadrawstar;
        Bdraw = Bdrawstar;           
        acpt_rf = acpt_rf+1;
    end

    %------------------------------------------------------------
    % STEP TWO: Draw from Q distribution
    %------------------------------------------------------------
    %            [Qstar, ~] = qr(randn(n, nIV));
    Xstar = randn(n, 1);
    Qstar = Xstar / norm(Xstar);

    lnp1 = loglik_tvm_given_y_unbalanced(MM, Udrawstar(ndum+1:end, :),sample_vector, LCstar, Qstar(:,1), bet, sqrt(signu2));

    % metropolis hastings
    alp = exp(lnp1 - lnp0);
    if rand < alp
        lnp0 = lnp1;
        Q = Qstar;
        acpt_Q = acpt_Q+1;

    end

    % normalize A0
    A0 = A0chol*Q;
    
    if options_.irf_sign==1
        if A0(1) < 0
            Q = -Q;
        end
    elseif options_.irf_sign==-1
        if A0(1) > 0
            Q = -Q;
        end
    end

    %------------------------------------------------------------
    % STEP THREE: BET and SIGMA from MVN-IG / MVN-IW
    %------------------------------------------------------------
    scale_mat = Q' / LC;
    Xe = (scale_mat*Udraw(ndum+1:end, :)')';
    
    
    % Markov Switching proxy parameters

    beta_flag=1;
   
    dep=MM{1,1};
    t =size(dep,1);
    indep=Xe(sample_vector(1,1):sample_vector(1,2),1);
    


    %% Multi-move sampler
    P=piedraw; % redefining to Hamilton's notation
    A=[eye(K)-P;ones(1,K)];
    tmp=(A'*A)\A';
    xitt_1=tmp(:,end); % start with invariant probablitlies
    xitt_1 = max([xitt_1 zeros(K,1)],[],2); % This line eliminates roundoff error @
    for it=1:t % filtering
        
        for j=1:K
            u_=dep(it,1)-indep(it,:)*betadraw(:,j);
            loglike(j,1)=-((1/2)*log(2*pi)-0.5*log(signu2)-(0.5*(u_^2)/signu2));
                
        end
        ll=exp(loglike-max(loglike)); % numerical stabilizeation, see Frühwirth-Schnatter book
        xitt(:,it)=(xitt_1.*ll)./sum(xitt_1.*ll,1);
        xitt_1=P*xitt(:,it); 
    
    
    end
    St(t,1)= randsample(K,1,true,xitt(:,t)); % sample S(T) from xi(T|T)
    prob1(t,1)= xitt(1,t);
     for it=t-1:-1:1
         prob=P(St(it+1,1),:)'.*xitt(:,it)/sum(P(St(it+1,1),:)'.*xitt(:,it));
         St(it,1)= randsample(K,1,true,prob);
         prob1(it,1) =prob(1,1);
     end
     
     
     %% drawing pi1,pi2,...,piK from Dirichlet

    Nj=statecount(St',K); %counts number of transitions, output is a matrix of transition numbers
    
    pie11draw=betarnd(pie11_0(1)+Nj(1,1),pie11_0(2)+Nj(1,2));
    pie22draw=betarnd(pie22_0(1)+Nj(2,2),pie22_0(2)+Nj(2,1));
    piedraw=[pie11draw 1-pie22draw; 1-pie11draw pie22draw];
%     for j=1:K
%        piedraw(:,j)=drchrnd(piei{j}+Nj(:,j)',1); % drawing each column of the transition matrix pie
%     end;
    
        %%  drawing beta(i) from Normal
    
    for j=1:K
        % extracting state dependent vectors 
        y_=dep(St==j,1);
        X_=indep(St==j,:);
               
        omeg_ = signu2;
        
        Bpo(j)=1/(1/(Bbar{j})+(1/omeg_)*(X_'*X_));  % posterior variance of beta
        bpo(j)=Bpo(j)*((1/Bbar{j})*bbar{j}+(1/omeg_)*X_'*y_); % posterior mean of beta
       

        betadraw(j)=mvnrnd(bpo(j),Bpo(j)); % this is a draw of beta

    end
    
    if betadraw(1)<betadraw(2)
        acpt_ic=acpt_ic+1;
    end
    
    for it=1:t      
        bett(it,1)= betadraw(St(it,1));        
    end
    bet{1,1}=bett;
    %%  drawing signu from IG
%        if (prior_type == 'IG')          
            nu1 = size(Xe, 1)-1 + nu0;
            %s1 = ( (MM(:,i)-Xe.*bet(:,i))'*(MM(:,i)-Xe.*bet(:,i)) + nu0*s0^2)/nu1;
            s12 = ( (MM{1,1}-Xe(sample_vector(1,1):sample_vector(1,2),1).*bet{1,1})'*(MM{1,1}-Xe(sample_vector(1,1):sample_vector(1,2),1).*bet{1,1}) + nu0*s0);
            %signu(i) = igrand(s1, nu1);
            signu2 = inverse_gamma(1,nu1/2,s12/2);

%        elseif (prior_type == 'FI')     
%            signu = pr_trunc*std(MM{1,1});
%        end


  
     %%


    lnp0 = loglik_tvm_given_y_unbalanced(MM, Udrawstar(ndum+1:end, :),sample_vector, LCstar, Q(:,1), bet, sqrt(signu2));

    record=record+1;
    counter = counter +1;
    if counter==0.05*nd && options_.display==1
        disp(['         ITER NUMBER:   ', num2str(record)]);
        disp('                                                                  ');
        disp(['     REMAINING DRAWS:   ', num2str(nd-isave)]);
        disp('                                                                  ');
        counter = 0;

        fprintf('RF acpt rate: %5.3f\n',   acpt_rf/record)
        fprintf('Q acpt rate: %5.3f\n',    acpt_Q/(record*nq))
        fprintf('Q acpt number: %5.0f\n',    acpt_Q)
        fprintf('state constraint acpt rate: %5.3f\n',    acpt_ic/record)
    end


    if record > bburn 
        if betadraw(1)<betadraw(2) 
            isave=isave+1;
                

            ffactor = LC*Q;
            IRF_T    = vm_irf(F,J,ffactor,Horizon+1,n,Omega1);        
            Ltilde(isave,:,:,:) = IRF_T(1:Horizon+1,:,:);
            %e_shock(isave,:) = Xe;


            if options_.FEVD ==1
                W(isave,:,:,:)=variancedecompositionFD(F,J,Sigmadraw,ffactor,n,Horizon,[]);
            end    


            REL(isave,:) = bett.^2./(bett.^2 + signu2);
            SIG(isave,1) = signu2;
            PROB1(isave,:) =prob1;
            BETdraw(isave,:) = betadraw;



        end
    end
    

end
    
    
%LtildeAdd(:,:,1:n,:) = Ltilde;
%LtildeAdd(:,:,n+1:n+nCalc,:) = irfCalc;

%SVAR.LtildeImpact = LtildeAdd(:,1,:,:);

LtildeFull = quantile(Ltilde,ptileVEC);
SVAR.LtildeFull = permute(LtildeFull,[3,2,1,4]);

WhFull = quantile(W,ptileVEC);
SVAR.WhFull = permute(WhFull,[3,2,1,4]);

%draws.e_shock = e_shock;
%SVAR.e_shockFull = quantile(e_shock,ptileVEC);

SVAR.RELFull  = quantile(REL,ptileVEC);

SVAR.SIGFull  = quantile(SIG,ptileVEC);
SVAR.BETFull  = quantile(BETdraw,ptileVEC);
SVAR.PROB1Full  = quantile(PROB1,ptileVEC);

draws.IRF_MP = squeeze(Ltilde(:,:,1,:));
draws.SIG = SIG;
draws.BET = BETdraw;


SVAR.acpt_rf = acpt_rf/record;
SVAR.acpt_Q  = acpt_Q/(record*nq);
SVAR.number_Q = acpt_Q;
SVAR.p = p;
SVAR.nd = nd;
SVAR.bburn = bburn;
SVAR.lambda=lambda;
SVAR.alpha=alpha;
SVAR.sample_vector = sample_vector;





