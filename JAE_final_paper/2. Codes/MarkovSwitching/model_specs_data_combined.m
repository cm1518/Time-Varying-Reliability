function [priors,options_]=model_specs_data_combined(VAR_select)


switch VAR_select
    

        
case 'gk_ff4_MS_beta_v2'
        %%
        options_.i_var_str =  {'gs1','logcpi','logip','ebp'};
        options_.macro_var_str_names =  {'Gov Bond 1y', 'CPI', 'IP', 'Excess Bond Premium'}; % Name of variables (for plots)
        options_.macrovarSelec=[1:4];

        options_.instrList = {'ff4_tc'}; % Which Proxy?
        options_.M=1;                                  % a vector of dimension N, containing number of proxies for each shock
        options_.p = 12;                                % Number of lags
        options_.irf_sign=1;
        
        % Sample dates
        % -------------------------------------------------------------------------
        options_.str_sample_init     = '1979-07-01';         % Starting date of the sample (include pre-sample)
        % str_sample_init     = '1986-01-01';         % Starting date of the sample (include pre-sample)
        options_.str_sample_end      = '2012-06-01';         % End date of the sample

        % Proxy dates
        % -------------------------------------------------------------------------
        % 
        options_.str_iv_init{1,1}    = '1991-01-01';         % Starting date of the sample for the proxy 1
        options_.str_iv_end{1,1}     = '2012-06-01';         % Ending date of the sample for the proxy 1
                
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
        priors.s0=0.001;                                 % prior location of the residual variance
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
        
      
end