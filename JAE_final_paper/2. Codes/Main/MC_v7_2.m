% HOUSE KEEPING
clear all;
clc;
close all;
seed=rng(100);
currentFolder=pwd;

addpath([currentFolder '/Subroutines']);
addpath(genpath([currentFolder '/../4.5.4']));% PLEASE change this line to the correct path where you have installed dynare 4.5.4


savefolder = [currentFolder '/results/MC_v7_2'];
mkdir(savefolder)   



%% Simulate data from Dynare
n_sims =100; % number of repetitions
T=250;

sigma_(1) = 0.2290;
sigma_(2) = 0.5017;
sigma_(3) = 0.3583;
sigma_(4) = 0.6752;
sigma_(5) = 0.5678;
sigma_(6) = 0.2181;
sigma_(7) = 0.2663;

kappa=0.25;

sigma2 = sigma_.^2;

sigma2_low =sigma2;
sigma2_low(1) = kappa*sigma2(1);

sigma2_high =sigma2;
sigma2_high(1) =(1+kappa)*sigma2(1);

for i=1:n_sims
    simulated_shocks(:,:,i)=mvnrnd(zeros(7,1),diag(sigma2_high),T);
    simulated_shocks(5:140,:,i)=mvnrnd(zeros(7,1),diag(sigma2_low),140-5+1);
    simulated_shocks(150:230,:,i)=mvnrnd(zeros(7,1),diag(sigma2_low),230-150+1);

end



save simulated_shocks.mat simulated_shocks

SW_Model_sv_v1; 

%clean_folder_SW_sv;

clearvars -except y_sim pie_sim r_sim ms_sim currentFolder n_sims T savefolder r_em y_em pinf_em ms_em;
% clean_workspace_SW_sv;
% adding path here to avoid interfering with dynare
addpath([currentFolder '/../auxfiles']);
rmpath(genpath('C:\Program Files\Dynare\4.5.4\matlab'));% removing dynare path

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

priors.b_0_prmean = ones(1,options_.M)*0; % initial prior mean of time-varing roxy regression coefficient
priors.b_0_prvar = ones(1,options_.M); % initial prior variance of of time-varing proxy regression coefficient

priors.mu0=0;                                   % prior mean of the coefficent
priors.V0=1;   

priors.q_s0 = ones(1,options_.M)*0.01; % inverse gamma prior location of the time-variation innovation STANDARD DEVIATION
priors.q_nu0 = ones(1,options_.M)*2; % inverse gamma prior degree of freedom 

% Specification of the hyper-prior for q_s0
q_s0_options.est_q_s0_flag =1; % using hyper-prior for q_s0? 
q_s0_options.prior = 'half-cauchy'; % 'inv-gamma' 'half-cauchy' 'half-t' 'uniform'
q_s0_options.nu = 4; % df hyperparameter 
q_s0_options.scale = 0.01; % scale (or location) hyperparameter
q_s0_options.upper_bound = 1; % upper bound for uniform, also the cutoff value for the MH samples 
q_s0_options.lower_bound = 0.0001; % lower bound for uniform, also the cutoff value for the MH samples
q_s0_options.tuning_para =ones(1,options_.M)*0.001; % standard deviation of the random walk innovation (should be the siza of MM_nVar)
q_s0_options.acc_tuning =1; % flag for automatic stabilization of average acceptance ratio for q_s0 (only during the burn-in period)
q_s0_options.AcceptanceTarget = 0.33; % target average acceptance ratio
q_s0_options.relax=0.3; % relaxation parameter for the automatic stabilization, usually doesn' matter.

%% parfor loop here

sample_vector=[1 T-options_.p];

res=cell(n_sims,1);
sigma_m = 0.2290; % stdev of MP shock of the SW-DGP

% reliability definition
% rho = beta^2 / (beta^2 + sigma^2)

rel=ones(246,1);


parfor i=1:n_sims
%for i=1:n_sims
    
    kappa=0.25;

    sigma2 = 0.2290^2;
    sigma2_low =kappa*sigma2(1);
    sigma2_high =(1+kappa)*sigma2(1);
    seed=rng(i+100);
    data=[]
    proxy=[];
    data=[r_sim(1:T,i) y_sim(1:T,i) pie_sim(1:T,i)];
    eMP=ms_sim(1+options_.p:T,i);
    
    proxy{1,1}(:,1)=eMP/sqrt(sigma2_high(1))+sqrt(0.25)*randn(T-options_.p,1);
    proxy{1,1}(5:140,1)=eMP(5:140,1)/sqrt(sigma2_low(1))+sqrt(0.25)*randn(140-5+1,1);
    proxy{1,1}(150:230,1)=eMP(150:230,1)/sqrt(sigma2_low(1))+sqrt(0.25)*randn(230-150+1,1);
    
    
    
    %proxy{1,1}(:,1)=eMP;
    [TVP_SVAR, draws]=main_BTVPSVAR_Minn_func(data,proxy,sample_vector,options_,priors,q_s0_options);
    Fixed_SVAR=BPSVAR_Minn_PM0(data,proxy,sample_vector,options_,priors);

    
    res_TVP_SVAR{i,1}=TVP_SVAR;
    res_Fixed_SVAR{i,1}=Fixed_SVAR;
    simul_data{i,1}=data;
    simul_proxy{i,1}=proxy;
    
end

%% saving results 
save([savefolder '/results.mat'],'res_TVP_SVAR','res_Fixed_SVAR','simul_data','simul_proxy','r_em','y_em','pinf_em','ms_em') % save posterior moments
