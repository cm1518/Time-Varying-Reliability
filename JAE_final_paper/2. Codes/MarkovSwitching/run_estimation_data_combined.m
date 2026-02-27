%% -----------------
% HOUSE KEEPING
%----------------

clear all;
clc;
close all;
currentFolder=pwd;

%addpath([currentFolder '\auxfiles']);

addpath([currentFolder '/../auxfiles']);

%------------------------------------------------------------
% SETTINGS
%------------------------------------------------------------
%% Preliminaries
% VAR and MCMC settings
options_tmp.Horizon = 48;                          % Horizon for calculation of impulse responses
options_tmp.nrep= 100000;                           % Number of draws in MC chain; 
options_tmp.burn_in = 0.25*options_tmp.nrep;          % Burn-in period
options_tmp.rwmh_sigma_prob = 0.25  ;                 % this is the mixture probability for the "RW" IG propsal on SIGMA
options_tmp.rwmh_df = 5;                           % Tune-up parameter for mixture proposal distribution for (\Phi,\Sigma)
options_tmp.nshocks =1;                            % Number of shocks (N)
options_tmp.FEVD=0;                                % calculating FEVD?       
options_tmp.savefig=1;                            % save figures?
options_tmp.display=1;


VAR_select_cell ={

                   'gk_ff4_MS_beta_v2',...
        
                                       };
                
graph_opt.font_num=10;

nn=length(VAR_select_cell);


str_iv_init={};
str_iv_end={};
macro_var_str_names={};

%% Loading data
data_file = '../../4. Data/data_combined.txt'; % this is important, load data in a very specific way
 
%data_file = 'U:\Eigene Dateien\Research\TimeVaryingProxyReliability\4. Data\data_combined.txt'; % this is important, load data in a very specific way
%********************************************************
% Import data series                                    *
%*******************************************************/
newData1 = importdata(data_file);
% Create new variables in the base workspace from those fields.
vars = fieldnames(newData1);
for i = 1:length(vars)
    assignin('base', vars{i}, newData1.(vars{i}));
end
YYdata = newData1.data;
text = newData1.textdata;
% clear data textdata
nDate = datenum(text(2:end,1));


%%
for k=1:nn
options_=[];
% Which VAR?
VAR_select = VAR_select_cell{k};

[priors,options_tmp1]=model_specs_data_combined(VAR_select);


options_.M=options_tmp1.M;  
options_.p = options_tmp1.p;                                 % Number of lags
options_.irf_sign=options_tmp1.irf_sign;  
options_.Horizon=options_tmp.Horizon;
options_.nrep=options_tmp.nrep;
options_.burn_in=options_tmp.burn_in;
options_.rwmh_sigma_prob=options_tmp.rwmh_sigma_prob;
options_.rwmh_df=options_tmp.rwmh_df;
options_.nshocks=options_tmp.nshocks;
options_.FEVD=options_tmp.FEVD;          
options_.savefig=options_tmp.savefig;
options_.display=options_tmp.display;

              
%% clearing objects


sample_iv_init=[];
sample_iv_end=[];
sample_iv_init_row=[];
sample_iv_end_row=[];
proxy=[];
sample_vector=[];



% folders
savefolder = [currentFolder '/results/' VAR_select];
mkdir(savefolder)   


i_var_instr = options_tmp1.instrList;
nIV = size(i_var_instr,2);



[~,i_var] = ismember(options_tmp1.i_var_str,text(1,2:end));
[~,i_instr] = ismember(i_var_instr,text(1,2:end));

%************************************************/
% RETRIEVE POSITION OF FIRST AND LAST OBSERVATION/
%************************************************/
T0=options_.p;

sample_init = datenum(options_tmp1.str_sample_init, 'yyyy-mm-dd');
sample_end = datenum(options_tmp1.str_sample_end, 'yyyy-mm-dd');
%sample_iv_init = datenum(str_iv_init, 'yyyy-mm-dd');

[~, sample_init_row] = ismember(sample_init,nDate,'rows');
[~, sample_end_row] = ismember(sample_end,nDate,'rows');
%[~, sample_iv_row] = ismember(sample_iv_init,nDate,'rows');

for i=1:nIV
    sample_iv_init(i,1) = datenum(options_tmp1.str_iv_init{i,1}, 'yyyy-mm-dd');
    sample_iv_end(i,1) = datenum(options_tmp1.str_iv_end{i,1}, 'yyyy-mm-dd');
    [~, sample_iv_init_row(i,1)] = ismember(sample_iv_init(i,1),nDate,'rows');
    [~, sample_iv_end_row(i,1)] = ismember(sample_iv_end(i,1),nDate,'rows');
    proxy{i,1} = YYdata(sample_iv_init_row(i,1):sample_iv_end_row(i,1),i_instr(i));
    % reconstructing the location of instruments w.r.t. post-sample
    sample_vector(i,1) = sample_iv_init_row(i,1) - T0 - (sample_init_row-1);
    sample_vector(i,2) = sample_iv_end_row(i,1) - T0 - (sample_init_row-1);
end



data = YYdata(sample_init_row:sample_end_row,i_var);



%% Call MCMC
% data is a n x T matrix of VAR obs
% proxy is a M x 1 cell, each cell contains a vector of proxy obs
% sample_vector is a M x 2 matrix indicating the starting (first column)
% and ending (second column) row of the proxy w.r.t. data.
% Ex. if there is only one proxy and it has starts and ends with VAR data (after initial observations p),
% sample_vector = [1 T];
seed=rng(100);
[SVAR, draws]=main_MSBPSVAR_Minn_func_v1(data,proxy,sample_vector,options_,priors);
IRF=SVAR.LtildeFull;

save([savefolder '/irf.mat'],'IRF')
save([savefolder '/post.mat'],'SVAR')
%save([savefolder '/draws.mat'],'draws')


end