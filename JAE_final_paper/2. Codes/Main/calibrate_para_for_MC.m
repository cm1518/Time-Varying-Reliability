% HOUSE KEEPING
clear all;
clc;
close all;
seed=rng(100);
currentFolder=pwd;
rmpath([currentFolder '\..\auxfiles']);% removing path here to avoid interfering with dynare
addpath([currentFolder '\Subroutines']);
addpath('C:\Program Files\Dynare\4.5.4\matlab'); %whereever your dynare is

savefolder = [currentFolder '\results\test'];
mkdir(savefolder)   



%% Simulate data from Dynare
dynare SW_Model noclearall
close all

y_sim=squeeze(sim_array(1,:,:));
pie_sim=squeeze(sim_array(2,:,:));
r_sim=squeeze(sim_array(3,:,:));
ms_sim=squeeze(sim_array(4,:,:));
clear sim_array


clean_folder_SW
clean_workspace_SW

% adding path here to avoid interfering with dynare
addpath([currentFolder '\..\auxfiles']);

%% parfor loop here
options_.p=4;
T=250;
sample_vector=[1 T-options_.p];
n_sims =100; % number of repetitions
res=cell(n_sims,1);
proxy=[];
for i=1:n_sims
    data=[];
    data=[r_sim(1:T,i) y_sim(1:T,i) pie_sim(1:T,i)];
    proxy_=ms_sim(1+options_.p:T,i);
    sigma_m = 0.2290; % stdev of MP shock of the SW-DGP
    proxy1(:,i)=proxy_(:,1)+randn(T-options_.p,1)*0.1*sigma_m;
    proxy1(5:100,i)=randn(100-5+1,1)*0.1*sigma_m;
    proxy1(150:200,i)=randn(200-150+1,1)*0.1*sigma_m;

    proxy2(:,i)=proxy_(:,1)+randn(T-options_.p,1)*0.1*sigma_m;
    proxy2(5:100,i)=proxy_(5:100,1)+randn(100-5+1,1)*0.1*sigma_m;
    proxy2(150:200,i)=proxy_(150:200,1)+randn(200-150+1,1)*0.1*sigma_m;
    
end

avg_std_1=mean(std(proxy1,0,2))
avg_std_2=mean(std(proxy2,0,2))
