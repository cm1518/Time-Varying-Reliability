% HOUSE KEEPING
clear all;
clc;
close all;
seed=rng(100);
currentFolder=pwd;

addpath([currentFolder '/Subroutines']);
addpath(genpath([currentFolder '/../4.5.4']));% PLEASE change this line to the correct path where you have installed dynare 4.5.4

savefolder = [currentFolder '/results/MC_v7_1'];
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
save('MC_v7_1_data.mat') 
