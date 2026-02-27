% HOUSE KEEPING
clear all;
clc;
close all;
seed=rng(100);
currentFolder=pwd;
rmpath(genpath([currentFolder '/../4.5.4']));% PLEASE change this line to the correct path where you have installed dynare 4.5.4

addpath([currentFolder '/../auxfiles']);
addpath([currentFolder '/Subroutines']);
addpath([currentFolder '/../MarkovSwitching']);

savefolder = [currentFolder '/results/MC_v5_1_rnd_MS'];
mkdir(savefolder)   

load MC_v5_1_data.mat


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
options_.p = 4;                                % Number of lags
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

% beta ~ N(bbar,Bbar)
priors.bbar{1}=0;
priors.bbar{2}=0;
priors.Bbar{1}=0.001;
priors.Bbar{2}=10;


% (pii) ~ beta(a,b)
priors.pie11_0=[6 1];
priors.pie22_0=[6 1];

priors.mu0=0;                                   % prior mean of the coefficent
priors.V0=1;                                % prior variance the coefficent

%% parfor loop here
T=250;
sample_vector=[1 T-options_.p];
n_sims =100; % number of repetitions
res_TVP_SVAR=cell(n_sims,1);
res_Fixed_SVAR=cell(n_sims,1);
sigma_m = 0.2290; % stdev of MP shock of the SW-DGP
kappa =0.25;
% reliability definition
% rho = beta^2 / (beta^2 + sigma^2)

rel=ones(246,1)/(1+kappa*(sigma_m)^2);


T_noise=227;

vec = [zeros(1,T-T_noise-options_.p), ones(1,T_noise)];


parfor i=1:n_sims
    seed=rng(i+100);
    data=[];
    proxy=[];
    data=[r_sim(1:T,i) y_sim(1:T,i) pie_sim(1:T,i)];
    proxy{1,1}=ms_sim(1+options_.p:T,i);

    sigma_m = 0.2290; % stdev of MP shock of the SW-DGP
    proxy{1,1}(:,1)=proxy{1,1}(:,1)+randn(T-options_.p,1)*sqrt(kappa)*sigma_m;
    vec_ = logical(vec(randperm(T-options_.p)));
    for ii=1:T-options_.p
        if vec_(ii)==1
            proxy{1,1}(ii,1)=randn*sqrt(kappa)*sigma_m;
        end
    end
   
    [SVAR, draws]=main_MSBPSVAR_Minn_func_v1(data,proxy,sample_vector,options_,priors);
    

    Fixed_SVAR=BPSVAR_Minn_PM0(data,proxy,sample_vector,options_,priors);
    
    
    res_TVP_SVAR{i,1}=SVAR;
    res_Fixed_SVAR{i,1}=Fixed_SVAR;
    simul_data{i,1}=data;
    simul_proxy{i,1}=proxy;
    
end
load MC_v5_1_data.mat

%% saving results 
save([savefolder '/results.mat'],'res_TVP_SVAR','res_Fixed_SVAR','simul_data','simul_proxy') % save posterior moments





