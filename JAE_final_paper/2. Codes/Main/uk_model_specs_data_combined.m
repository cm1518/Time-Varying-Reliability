function [priors,options_,q_s0_options]=uk_model_specs_data_combined(VAR_select)


switch VAR_select
 
case 'ctv_cm2_v1_q_hcauchy'
        %%
        options_.i_var_str =  {'i_1YR','CPI','unempl','fxbis','corp_spread','mortg_spread','us_baa'};
        options_.macro_var_str_names =  {'One-Year Rate','CPI','Unemployment','Exchange Rate','Corporate Spread','Mortgage Spread','BAA Corporate Spread - US'}; % Name of variables (for plots)
        options_.macrovarSelec=[1:7];

        options_.instrList = {'cm2'}; % Which Proxy? 'cm2' for Cesa-Bianchi et. al and 'cloyne' for Cloyne and Hürtgen  
        options_.M=1;                                  % a vector of dimension N, containing number of proxies for each shock
        options_.p = 2;                                % Number of lags
        options_.irf_sign=1;
        
        % Sample dates
        % -------------------------------------------------------------------------
        options_.str_sample_init     = '1992-01-01';         % Starting date of the sample (include pre-sample)
        % str_sample_init     = '1986-01-01';         % Starting date of the sample (include pre-sample)
        options_.str_sample_end      = '2015-01-01';         % End date of the sample

        % Proxy dates
        % -------------------------------------------------------------------------
        % 
        options_.str_iv_init{1,1}    = '1997-06-01';        % Starting date of the sample for the proxy 1
        options_.str_iv_end{1,1}     = '2015-01-01';         % Ending date of the sample for the proxy 1
                
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

        priors.q_s0 = ones(1,options_.M)*0.01; % inverse gamma prior location of the time-variation innovation STANDARD DEVIATION
        priors.q_nu0 = ones(1,options_.M)*2; % inverse gamma prior degree of freedom 

        % Specification of the hyper-prior for q_s0
        q_s0_options.est_q_s0_flag =1; % using hyper-prior for q_s0? 
        q_s0_options.prior = 'half-cauchy'; % 'inv-gamma' 'half-cauchy' 'half-t' 'uniform'
        q_s0_options.nu = 4; % df hyperparameter 
        q_s0_options.scale = 0.01; % scale (or location) hyperparameter
        q_s0_options.upper_bound = 1; % upper bound for uniform, also the cutoff value for the MH samples 
        q_s0_options.lower_bound = 0.0001; % lower bound for uniform, also the cutoff value for the MH samples

        q_s0_options.tuning_para =ones(1,options_.M)*0.01; % standard deviation of the random walk innovation (should be the siza of MM_nVar)
        % you may have to tune this parameter a bit in order to get acceptable average acceptance ratio even using automatic stabilization.
        % the alogorithm stops if the average acceptance ratio gets too low. a
        % general rule of thumb is to DECREASE this parameter if acceptance ratio
        % is to low

        q_s0_options.acc_tuning =1; % flag for automatic stabilization of average acceptance ratio for q_s0 (only during the burn-in period)
        q_s0_options.AcceptanceTarget = 0.33; % target average acceptance ratio
        q_s0_options.relax=0.3; % relaxation parameter for the automatic stabilization, usually doesn' matter.
 
case 'ctv_cm2_v1_fixed'
        %%
        options_.i_var_str =  {'i_1YR','CPI','unempl','fxbis','corp_spread','mortg_spread','us_baa'};
        options_.macro_var_str_names =  {'One-Year Rate','CPI','Unemployment','Exchange Rate','Corporate Spread','Mortgage Spread','BAA Corporate Spread - US'}; % Name of variables (for plots)
        options_.macrovarSelec=[1:7];

        options_.instrList = {'cm2'}; % Which Proxy?
        options_.M=1;                                  % a vector of dimension N, containing number of proxies for each shock
        options_.p = 2;                                % Number of lags
        options_.irf_sign=1;
        
        % Sample dates
        % -------------------------------------------------------------------------
        options_.str_sample_init     = '1992-01-01';         % Starting date of the sample (include pre-sample)
        % str_sample_init     = '1986-01-01';         % Starting date of the sample (include pre-sample)
        options_.str_sample_end      = '2015-01-01';         % End date of the sample

        % Proxy dates
        % -------------------------------------------------------------------------
        % 
        options_.str_iv_init{1,1}    = '1997-06-01';        % Starting date of the sample for the proxy 1
        options_.str_iv_end{1,1}     = '2015-01-01';         % Ending date of the sample for the proxy 1
                
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
        priors.mu0=0;                                   % prior mean of the coefficent
        priors.V0=1;                                % prior variance the coefficent
        priors.s0=0.2;                                 % prior location of the residual variance
        priors.nu0=2;                                   % prior df of the residual variance based on entire sample (default), 1 psi set to the variance of pre-sample (initial lags) observations


end


        