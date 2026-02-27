function [SVAR, draws]=main_BTVPSVAR_Minn_signutgiven_func(data,proxy,signut,sample_vector,options_,priors,q_s0_options)

% This function esstimates the Bayesian IV-SVAR based on Caldara and Herbst
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
% prior for signu is IG(nu0/2, nu0*s0^2/2)

% beta(t) = beta(t-1) + v(t)
% v(t) ~ N(0,q)
%
% priors
% p(beta(0)) ~ N(b_0_prmean,b_0_prvar)
% p(q) ~ IG(q_nu0/2, q_nu0*q_s0^2/2)
%
% suppose you're using hyperparameter estimation of q_s0, prior choice for
% q_s0 has to be made (currently supporting uniform, inverse gamma,
% half-cauchy, and half-t
%
% This code is a modified verson of Caldara and Herbst (2019)

% by Mu-Chun Wang 
% March, 2021



%------------------------------------------------------------
% SETTINGS
%------------------------------------------------------------
p = options_.p;                                 % Number of lags
nex_ = 1;                               % Constant
Horizon = options_.Horizon;                           % Horizon for calculation of impulse responses
nd = options_.nrep;                            % Number of draws in MC chain
bburn = 0.25*nd;                         % Burn-in period
ptileVEC = [0.05 0.16 0.50 0.86 0.95]; % Percentiles

%------------------------------------------------------------
% PRIOR SELECTION -- SIGMA_NU
% IG - Inverse Gamma
% FI - Truncated at pr_trunc x std(M_t)
%------------------------------------------------------------
% currently, priors for different IV regression are the same, can be easily
% modified.
prior_type = priors.prior_type;
pr_trunc = priors.pr_trunc;                      % only used for FIXED



b_0_prmean=priors.b_0_prmean;  % initial prior mean of time-varing roxy regression coefficient
b_0_prvar=priors.b_0_prvar; % initial prior variance of of time-varing proxy regression coefficient
s0 = priors.s0;
nu0 = priors.nu0;

q_s0 = priors.q_s0; % inverse gamma prior location of the time-variation innovation STANDARD DEVIATION
q_nu0 =priors.q_nu0; % inverse gamma prior degree of freedom 

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
% MCMC Algorithm
%------------------------------------------------------------

record=0;     
counter = 0;

disp('                                                                  ');
disp('        BAYESIAN ESTIMATION OF VAR VIA BLOCK MCMC                 ');
disp('                                                                  ');

% Drop constant from M
nIV=size(proxy,1);
for i=1:nIV
    MM_nT(i,1)=size(proxy{i,1},1);
end


for i=1:nIV
    bet{i,1} = 0.01*ones(MM_nT(i,1),1);
end
%signu = 0.04*ones(nIV,1);
q = q_s0;

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



lnp0 = loglik_tvmsv_given_y_unbalanced(MM, Udraw(ndum+1:end, :),sample_vector, LC, Q(:,1), bet, signut);

% Initialize Omega1 for IRFs
nshocks=1;
Omega1 = [LC(:,nshocks);zeros((p-1)*n,nshocks)];


nq = 1;
acpt_rf   = 0;
acpt_Q    = 0;
acpt_q    = zeros(1,nIV);  

Fstar = F;
Sigmadrawstar = Sigmadraw;


nCalc=0;
% MCMC Chain 
% Define objects that store the draws
Ltilde = zeros(nd-bburn,Horizon+1,n,nshocks);                      % define array to store IRF
LtildeAdd = zeros(nd-bburn,Horizon+1,n+nCalc,nshocks);
irfCalc = zeros(nd-bburn,Horizon+1,nCalc,nshocks);                     % store labor productivity IRF
W = zeros(nd-bburn,Horizon+1,n+nCalc,nshocks);                         % define array to store FVD

%e_shock=zeros(record-bburn,t);
for i = 1:nIV    
    REL{i,1}=zeros(record-bburn,MM_nT(i,1));
    BET{i,1}=zeros(record-bburn,MM_nT(i,1));
    SDDR_numer{i,1}=zeros(record-bburn,MM_nT(i,1));
    %SDDR_denom{i,1}(record-bburn,:) =denom{i,1};

end
SIG=zeros(record-bburn,nIV);
qdraws=zeros(record-bburn,nIV);
q_s0draws=zeros(record-bburn,nIV);

jrep    = zeros(1,nIV);
jsux    = zeros(1,nIV);

%% prior simulator for dynamic SDDR
nrep_prior=10000;
q_s0_=q_s0;
%         q_s0_options.nu: df hyperparameter 
%         q_s0_options.scale: scale (or location) hyperparameter
%         q_s0_options.upper_bound: upper bound for uniform, also the cutoff value for the MH samples 
%         q_s0_options.lower_bound: lower bound for uniform, also the cutoff value for the MH samples
%
for j=1:nrep_prior
    for i=1:nIV
        if q_s0_options.est_q_s0_flag == 1
            switch q_s0_options.prior
                case 'inv-gamma' % inverse gamma (scaled-inverse-chi2 specification)
                    q_s0_(i)=inverse_gamma(1,  q_s0_options.nu/2, q_s0_options.nu*q_s0_options.scale.^2/2 );
                case 'half-cauchy'
                    q_s0_(i)=rhalfcauchy(1,q_s0_options.scale);
                case 'uniform'
                    q_s0_(i)=q_s0_options.lower_bound+(q_s0_options.upper_bound-q_s0_options.lower_bound)*rand;
                   
            end
        end    
        qpriordraw = inverse_gamma(1,q_nu0(i)/2, q_nu0(i)*q_s0_(i)^2/2);
        alpbar=b_0_prmean(i); 
        denom_=[];
        for it=1:MM_nT(i,1)
            Vbar=b_0_prvar(i)+(qpriordraw*(j-1));  
            denom_(it,1) = exp(-(1/2)*log(2*pi)- (1/2)*log(Vbar) - (1/2)*(alpbar^2/Vbar));

        end
        SDDR_denom{i,1}(j,:)=denom_;
    end
    
end
%% MCMC starts
while record<nd

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

        lnp1 = loglik_tvmsv_given_y_unbalanced(MM, Udrawstar(ndum+1:end, :),sample_vector, LCstar, Q(:,1), bet, signut);

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

        lnp1 = loglik_tvmsv_given_y_unbalanced(MM, Udrawstar(ndum+1:end, :),sample_vector, LCstar, Q(:,1), bet, signut);

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

    lnp1 = loglik_tvmsv_given_y_unbalanced(MM, Udraw(ndum+1:end, :),sample_vector, LC, Qstar(:,1), bet, signut);

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
    t =size(Xe,1);
    
    % bayesian TVP model using Carter and Kohn filter

    for i = 1:nIV
        % btdraw is a draw of the coefficients, b(t), conditional on
        % all other parameteres

        [btdraw,log_lik] = carter_kohn(MM{i,1}',Xe(sample_vector(i,1):sample_vector(i,2),1),signut{i,1}.^2,q(i),1,1,MM_nT(i,1),b_0_prmean(i),b_0_prvar(i));   

        btdraw=btdraw';
        bet{i,1} = btdraw;
        Btemp = btdraw(2:MM_nT(i,1),:) - btdraw(1:MM_nT(i,1)-1,:);
        sse_2=Btemp(1:MM_nT(i,1)-1,:)'*Btemp(1:MM_nT(i,1)-1,:);
        % ...and subsequently draw q, the innovation variance of b(t)
        % from IG

%            Qinv        = inv(sse_2 + q_s0(i)^2);
%            Qinvdraw   = wish(Qinv,t+q_nu0(i));
%            q(i)       = inv(Qinvdraw);            % this is a draw from Q
         q_nu1 = MM_nT(i,1) + q_nu0(i); 
         q_s12 = sse_2 + q_nu0(i)*q_s0(i)^2;
         q(i) = inverse_gamma(1,q_nu1/2, q_s12/2);
         
         % estimate hyperparameter q_s0, draw from Random-Walk MH block
         if q_s0_options.est_q_s0_flag == 1
             loglik_old=[];
             loglik_new=[];
             % Get likelihood of q given the current q_s0. This is just the prior of q(given q_s0)
             loglik_old=linv_gam_pdf(q(i),q_nu0(i)/2, q_nu0(i)*q_s0(i)^2/2);
             % prior density for q_s0, depending on the exact prior
             lpriordens_old = priordens(q_s0(i), q_s0_options);
             % posterior kernel of the old draw   
             loglik_old = loglik_old + lpriordens_old; 
             % Draw a new q_s0 from random walk MH
             q_s0_new = q_s0(i)+randn*q_s0_options.tuning_para(i); 
             % Calculate the likelihood of q given the new q_s0
             lpriordens_new = priordens(q_s0_new, q_s0_options); %evaluate prior density with the new kQ draw
             % posterior kernel of the new draw             
             loglik_new = linv_gam_pdf(q(i),q_nu0(i)/2, q_nu0(i)*q_s0_new^2/2);
             loglik_new = loglik_new+lpriordens_new;
             % Calculate the acceptance ratio; 
             logalpha = loglik_new-loglik_old;
             % Accept according to Metropolis algorithm
             if(log(rand)<logalpha) && q_s0_new>q_s0_options.lower_bound && q_s0_new<q_s0_options.upper_bound
                q_s0(i)=q_s0_new;
                accept_flag=1;
                acpt_q(i) = acpt_q(i) + 1;
             else
                accept_flag=0;
             end
         
         
             % automatic stabilization of MH
             if  record>0 && record/nadjust == round(record/nadjust) && record<=bburn && q_s0_options.acc_tuning==1 %% Tuning phase     
                [q_s0_options.tuning_para(i)]=automatic_stabilization(q_s0_options.tuning_para(i),jsux(i),jrep(i),q_s0_options);
                jsux(i)=0;jrep(i) = 0;
             end

            jsux(i)=jsux(i)+accept_flag;
            jrep(i) = jrep(i) + 1;
        
         end


        % SDDR
        % DK smoother to get smoothed tv parameter states
        [alphat,Vt] = durbin_koopman(MM{i,1}',Xe(sample_vector(i,1):sample_vector(i,2),1),signut{i,1}.^2,q(i),1,1,MM_nT(i,1),b_0_prmean(i),b_0_prvar(i),[]);
   
        %qpriordraw = inverse_gamma(1,q_nu0(i)/2, q_nu0(i)*q_s0(i)^2/2);
        alpbar=b_0_prmean(i);

        numer_=[];
        denom_=[];
        for j=1:MM_nT(i,1)
            numer_(j,1) = exp(-(1/2)*log(2*pi)- (1/2)*log(Vt(:,:,j)) - (1/2)*(alphat(:,j)^2/Vt(:,:,j)));
            %Vbar=b_0_prvar(i)+(q(i)*(j-1));  
            %denom_(j,1) = exp(-(1/2)*log(2*pi)- (1/2)*log(Vbar) - (1/2)*(alpbar^2/Vbar));

        end
        numer{i,1} = numer_;
        %denom{i,1} =denom_;
        %bet = mvnrnd(mup, signu^2*Vp);
    end

    lnp0 = loglik_tvmsv_given_y_unbalanced(MM, Udrawstar(ndum+1:end, :),sample_vector, LCstar, Q(:,1), bet, signut);

    record=record+1;
    counter = counter +1;
    if counter==0.05*nd && options_.display==1
        disp(['         DRAW NUMBER:   ', num2str(record)]);
        disp('                                                                  ');
        disp(['     REMAINING DRAWS:   ', num2str(nd-record)]);
        disp('                                                                  ');
        counter = 0;

        fprintf('RF acpt rate: %5.3f\n',   acpt_rf/record)
        for i =1:nIV
            fprintf('q(%1.0f) acpt rate: %5.3f\n',  i, acpt_q(i)/record)
        end
        fprintf('Q acpt rate: %5.3f\n',    acpt_Q/(record*nq))
        fprintf('Q acpt number: %5.0f\n',    acpt_Q)
    end

    if record > bburn



        ffactor = LC*Q;



        %e_shock(record-bburn,:) = Xe;
        for i = 1:nIV    
            REL{i,1}(record-bburn,:) = bet{i,1}.^2./(bet{i,1}.^2 + signut{i,1}.^2);
            BET{i,1}(record-bburn,:) = bet{i,1};
            %SIG(record-bburn,i) = signu(i);
            SDDR_numer{i,1}(record-bburn,:) =numer{i,1};
            %SDDR_denom{i,1}(record-bburn,:) =denom{i,1};
            qdraws(record-bburn,i) =q(i);
            q_s0draws(record-bburn,i) =q_s0(i);
       end

        IRF_T    = vm_irf(F,J,ffactor,Horizon+1,n,Omega1);        
        Ltilde(record-bburn,:,:,:) = IRF_T(1:Horizon+1,:,:);

        draws.Xe(:,record-bburn) = Xe(:,1);
        if options_.FEVD ==1
            W(record-bburn,:,:,:)=variancedecompositionFD(F,J,Sigmadraw,ffactor,n,Horizon,[]);
        end
    end
end
    
    
LtildeAdd(:,:,1:n,:) = Ltilde;
LtildeAdd(:,:,n+1:n+nCalc,:) = irfCalc;

%SVAR.LtildeImpact = LtildeAdd(:,1,:,:);

LtildeFull = quantile(LtildeAdd,ptileVEC);
SVAR.LtildeFull = permute(LtildeFull,[3,2,1,4]);

WhFull = quantile(W,ptileVEC);
SVAR.WhFull = permute(WhFull,[3,2,1,4]);

%draws.e_shock = e_shock;
%SVAR.e_shockFull = quantile(e_shock,ptileVEC);

for i =1:nIV
    SVAR.RELFull{i,1}  = quantile(REL{i,1},ptileVEC);
    SVAR.BETFull{i,1}  = quantile(BET{i,1},ptileVEC);
end
SVAR.SIGFull  = quantile(SIG,ptileVEC);
SVAR.qFull  = quantile(qdraws,ptileVEC);
SVAR.q_s0Full  = quantile(q_s0draws,ptileVEC);
draws.SIG = SIG;
draws.BET = BET;
draws.q = qdraws;
draws.q_s0 = q_s0draws;
SVAR.acpt_rf = acpt_rf/record;
SVAR.acpt_Q  = acpt_Q/(record*nq);
SVAR.number_Q = acpt_Q;
SVAR.p = p;
SVAR.nd = nd;
SVAR.bburn = bburn;
SVAR.lambda=lambda;
SVAR.alpha=alpha;
SVAR.sample_vector = sample_vector;
SVAR.Xe = quantile(draws.Xe,ptileVEC,2);

for i =1:nIV   
    SVAR.BF{i,1} = squeeze(mean(SDDR_numer{i,1})./mean(SDDR_denom{i,1}));
    SVAR.PM0{i,1}= squeeze(SVAR.BF{i,1}./ (1+SVAR.BF{i,1}));
end 




