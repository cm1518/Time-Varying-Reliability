function SVAR=BPSVAR_Minn(data,proxy,sample_vector,options_,priors)

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

%------------------------------------------------------------
% SETTINGS
%------------------------------------------------------------
p = options_.p;                                 % Number of lags
nex_ = 1;                               % Constant
Horizon = options_.Horizon;                           % Horizon for calculation of impulse responses
nd = options_.nrep;                            % Number of draws in MC chain
bburn = 0.25*nd;                         % Burn-in period
fflagFEVD = 1;                          % Compute FEVD
ptileVEC = [0.05 0.16 0.50 0.84 0.95]; % Percentiles

%------------------------------------------------------------
% PRIOR SELECTION -- SIGMA_NU
% IG - Inverse Gamma
% FI - Truncated at pr_trunc x std(M_t)
%------------------------------------------------------------
% currently, priors for different IV regression are the same, can be easily
% modified.
prior_type = priors.prior_type;
pr_trunc = priors.pr_trunc;                      % only used for FIXED

mu0 = priors.mu0;                             % prior mean
V0 = priors.V0;                             % prior variance

s0 = priors.s0;
nu0 = priors.nu0;

pos=priors.pos; % this is important! the position vector indicating stationary variable.
Vc=priors.Vc;

if ~isfield(priors,'psitune')
    priors.psitune=0;
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

e = eye(n); % create identity matrix
aalpha_index = 2:n;
ddelta_index = 1;
a = cell(p,1);

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

disp('                                                                  ');
disp('        BAYESIAN ESTIMATION OF VAR VIA BLOCK MCMC                 ');
disp('                                                                  ');

% Drop constant from M
nIV=size(proxy,1);

for i=1:nIV
    bet(i,1) = 0.01;
    signu(i,1) = 0.04;
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


lnp0 = loglik_m_given_y_mult(MM, Udraw(ndum+1:end, :), LC, Q, bet, signu,sample_vector);

% Initialize Omega1 for IRFs
nshocks=1;
Omega1 = [LC(:,nshocks);zeros((p-1)*n,nshocks)];

nq = 1;
acpt_rf   = 0;
acpt_Q    = 0;


Fstar = F;
Sigmadrawstar = Sigmadraw;

nCalc=0;
% MCMC Chain 
% Define objects that store the draws
Ltilde = zeros(nd-bburn,Horizon+1,n,nshocks);                      % define array to store IRF
LtildeAdd = zeros(nd-bburn,Horizon+1,n+nCalc,nshocks);
irfCalc = zeros(nd-bburn,Horizon+1,nCalc,nshocks);                     % store labor productivity IRF
W = zeros(nd-bburn,Horizon+1,n+nCalc,nshocks);                         % define array to store FVD
EETA  = zeros(nd-bburn,n-1);
ppsi_levels = zeros(nd-bburn,n);
ppsi_diff   = zeros(nd-bburn,n-1);
REL = zeros(nd-bburn,1);
BET = zeros(nd-bburn,1);
SIG = zeros(nd-bburn,1);
A0MAT = zeros(nd-bburn, n, n);
ApMAT = zeros(nd-bburn, n*p+nex, n);



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

        lnp1 = loglik_m_given_y_mult(MM, Udrawstar(ndum+1:end, :), LCstar, Q(:,nshocks), bet, signu,sample_vector);

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

        lnp1 = loglik_m_given_y_mult(MM, Udrawstar(ndum+1:end, :), LCstar, Q(:,nshocks), bet, signu,sample_vector);

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

    lnp1 = loglik_m_given_y_mult(MM, Udraw(ndum+1:end, :), LC, Qstar(:,nshocks), bet, signu,sample_vector);

    % metropolis hastings
    alp = exp(lnp1 - lnp0);
    if rand < alp
        lnp0 = lnp1;
        Q = Qstar;
        acpt_Q = acpt_Q+1;
    end

    % normalize A0
    A0 = A0chol*Q;
    if A0(1) < 0
        Q = -Q;
    end

    %------------------------------------------------------------
    % STEP THREE: BET and SIGMA from MVN-IG / MVN-IW
    %------------------------------------------------------------
    scale_mat = Q' / LC;
    Xe = (scale_mat*Udraw(ndum+1:end, :)')';
    for i=1:nIV
        Xe_=Xe(sample_vector(i,1):sample_vector(i,2),1); % correct sample for the specific IV
        % bayesian linear regresion model
        Bhat = (Xe_'*Xe_)\(Xe_'*MM{i,1});
        Vp = inv(Xe_'*Xe_ + inv(V0/signu(i,1)^2));
        mup = Vp * (Xe_'*Xe_*Bhat + inv(V0)*mu0);

        if (prior_type == 'IG')          
            nu1 = size(Xe_, 1)-1 + nu0;
            s1 = ( (MM{i,1}-Xe_*mup)'*(MM{i,1}-Xe_*mup) + nu0*s0^2)/nu1;

            signu(i,1) = igrand(s1, nu1);
        elseif (prior_type == 'FI')     
            signu(i,1) = pr_trunc*std(MM{i,1});
        end

        bet(i,1) = mvnrnd(mup, signu(i,1)^2*Vp);
    end


    lnp0 = loglik_m_given_y_mult(MM, Udrawstar(ndum+1:end, :), LCstar, Q(:,nshocks), bet, signu,sample_vector);

    record=record+1;
    counter = counter +1;
    if counter==0.05*nd
        disp(['         DRAW NUMBER:   ', num2str(record)]);
        disp('                                                                  ');
        disp(['     REMAINING DRAWS:   ', num2str(nd-record)]);
        disp('                                                                  ');
        counter = 0;

        fprintf('RF acpt rate: %5.3f\n',   acpt_rf/record)
        fprintf('Q acpt rate: %5.3f\n',    acpt_Q/(record*nq))
    end

    if record > bburn

        ffactor = LC*Q;
        A0 = A0chol*Q;
        %Aplus = Bdraw(1:n*p,:)*A0;
        Aplus = Bdraw(2:end,:)*A0;

        % Compute cumulative coefficients 
        a0 = A0(:,1);
        for l=1:p
            a{l} = Aplus((l-1)*n+1:l*n,1);
        end
        aalpha = zeros(p+1,n-1);
        for j=1:n-1
            jj=aalpha_index(1,j);
            aalpha(1,j)  = -((e(:,jj)'*a0));
            for l=1:p
                aalpha(l+1,j)  = ((e(:,jj)'*a{l}));
            end
        end
        ddelta = zeros(p+1,1);
        ddelta(1,1) = ((e(:,ddelta_index )'*a0));
        for l=1:p
            ddelta(l+1,1)  = -((e(:,ddelta_index )'*a{l}));
        end
        tmp_levels   = zeros(1,n-1);

        for l=0:p
            tmp_levels = aalpha(l+1,1:n-1) + tmp_levels;
        end
        % variables in levels
        tmp_diff   = zeros(1,n-1);
        for l=0:p
            for ii=0:l
                tmp_diff = aalpha(ii+1,:) +  tmp_diff ;
            end
        end
        tmpR=0;
        for l=0:p
            tmpR=ddelta(l+1,1)+tmpR;
        end

        aalphaEta = aalpha./a0(1);
        ddeltaEta = ddelta./a0(1);
        den = ddeltaEta(1) + sum(ddeltaEta(2:end));       
        num = sum(aalphaEta);
        numtemp = sum(cumsum(aalphaEta));
        for i=1:nIV
            REL(record-bburn,i) = bet(i,1)^2/(bet(i,1)^2 + signu(i,1)^2);
            BET(record-bburn,i) = bet(i,1);
            SIG(record-bburn,i) = signu(i,1);
        end
        EETA(record-bburn,:) = -A0(2:n,1)./A0(1,1);
        ppsi_levels(record-bburn,:) = [sum(ddeltaEta(2:end)) num];
        ppsi_diff(record-bburn,1:n-1)   = numtemp;

        IRF_T    = vm_irf(F,J,ffactor,Horizon+1,n,Omega1);        
        Ltilde(record-bburn,:,:,:) = IRF_T(1:Horizon+1,:,:);

        if fflagFEVD ==1
            W(record-bburn,:,:,:)=variancedecompositionFD(F,J,Sigmadraw,ffactor,n,Horizon,[]);
        end
    end
end


LtildeAdd(:,:,1:n,:) = Ltilde;
LtildeAdd(:,:,n+1:n,:) = irfCalc;

SVAR.LtildeImpact = LtildeAdd(:,1,:,:);

LtildeFull = quantile(LtildeAdd,ptileVEC);
SVAR.LtildeFull = permute(LtildeFull,[3,2,1,4]);

WhFull = quantile(W,ptileVEC);
SVAR.WhFull = permute(WhFull,[3,2,1,4]);

SVAR.EETAFull = quantile(EETA,ptileVEC);
SVAR.PPSIFull = quantile(ppsi_levels,ptileVEC);
SVAR.PPSIDFull = quantile(ppsi_diff,ptileVEC);
SVAR.RELFull  = quantile(REL,ptileVEC);
SVAR.BETFull  = quantile(BET,ptileVEC);
SVAR.SIGFull  = quantile(SIG,ptileVEC);
SVAR.SIG = SIG;
SVAR.BET = BET;
SVAR.acpt_rf = acpt_rf/record;
SVAR.acpt_Q  = acpt_Q/(record*nq);
SVAR.p = p;
SVAR.nd = nd;
SVAR.bburn = bburn;
SVAR.fflagFEVD = fflagFEVD;
SVAR.pr_trunc = 0;
SVAR.pr_truncFlag = 0;
SVAR.EETA = EETA;
SVAR.lambda=lambda;
SVAR.alpha=alpha;

