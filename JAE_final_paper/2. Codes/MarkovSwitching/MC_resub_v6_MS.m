% HOUSE KEEPING
clear all;
clc;
close all;
seed=rng(100);
currentFolder=pwd;

addpath([currentFolder '/../auxfiles']);
addpath([currentFolder '/Subroutines']);

savefolder = [currentFolder '/results/MC_resub_v6_MS'];
mkdir(savefolder)   


%%
options_.Horizon = 48;                          % Horizon for calculation of impulse responses
options_.nrep= 50000;                           % Number of draws in MC chain; 
options_.burn_in = 0.25*options_.nrep;          % Burn-in period
options_.rwmh_sigma_prob = 0  ;                 % this is the mixture probability for the "RW" IG propsal on SIGMA
options_.rwmh_df = 5;                           % Tune-up parameter for mixture proposal distribution for (\Phi,\Sigma)
options_.nshocks =1;                            % Number of shocks (N)
options_.FEVD=0;                                % calculating FEVD?       
options_.savefig=1;                            % save figures?
options_.display=1;
options_.M=1;                                  % a vector of dimension N, containing number of proxies for each shock
options_.p = 1;                                % Number of lags
options_.irf_sign=1;
% Priors
% Prior for the VAR
priors.MP=0;                                    % Are hyperparameters optimized based on GLP?
priors.lambda=10;                              % overall tightness expressed as standard deviation (irrelevant if MP=1)
priors.alpha=2;                                 % lag decay (irrelevant if MP=1)
priors.Vc=10e6;                                 % prior variance in the MN prior for the coefficients multiplying the contant term (Default: Vc=10e6)
priors.pos=[];                                  % the position vector indicating stationary variable.
% Priors for the IV
priors.prior_type='IG';                         % 'IG' or 'FI' (fixed)
priors.pr_trunc=0.5;                            % only used for FIXED
priors.s0=0.2;                                 % prior location of the residual variance
priors.nu0=2;                                   % prior df of the residual variance
priors.psitune=1;                               % 0 psi set to the residual variance of an AR(1) based on entire sample (default), 1 psi set to the variance of pre-sample (initial lags) observations
priors.mu0=0;                                   % prior mean of the coefficent
priors.V0=1;                                % prior variance the coefficent

% beta ~ N(bbar,Bbar)
priors.bbar{1}=0;
priors.bbar{2}=1;
priors.Bbar{1}=10;
priors.Bbar{2}=10;


% (pii) ~ beta(a,b)
priors.pie11_0=[3 1];
priors.pie22_0=[3 1];


%% parfor loop here
T=500;
frac_informative_sample = 0.5;
nburns = 500;
sample_vector=[1 T-options_.p];
n_sims =50; % number of repetitions
res_TVP_SVAR=cell(n_sims,1);
res_Fixed_SVAR=cell(n_sims,1);

A=[0.95 0;0 0.9]; % VAR coefficients
B=[1 -0.5; 0.8 1];

parfor i=1:n_sims
    seed=rng(i+100);
    data=[];
    proxy=[];
    proxy{1,1}(1,1)=randn;
    data(:,1) = randn(2,1);

    for t=2:T+nburns
        epsi(:,t) = randn(2,1);
        data(:,t)=A*data(:,t-1)+B*epsi(:,t);

    end
    epsi=epsi';
    data=data';
    epsi = epsi(nburns+1:end,:);
    data = data(nburns+1:end,:);

    proxy{1,1}=epsi(1+options_.p:T,1);

    for t=1:T-options_.p
        if t<floor((T)*(1-frac_informative_sample))
            proxy{1,1}(t,1)=randn;
        end
    end
   
    [TVP_SVAR, draws]=main_MSBPSVAR_Minn_func_v1(data,proxy,sample_vector,options_,priors);
    

    Fixed_SVAR=BPSVAR_Minn_PM0(data,proxy,sample_vector,options_,priors);
    
    
    res_TVP_SVAR{i,1}=TVP_SVAR;
    res_Fixed_SVAR{i,1}=Fixed_SVAR;
    simul_data{i,1}=data;
    simul_proxy{i,1}=proxy;
    
end

%% saving results 
save([savefolder '/results.mat'],'res_TVP_SVAR','res_Fixed_SVAR','simul_data','simul_proxy') % save posterior moments





