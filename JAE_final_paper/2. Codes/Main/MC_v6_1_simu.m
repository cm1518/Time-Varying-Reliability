% HOUSE KEEPING
clear all;
clc;
close all;
seed=rng(100);
currentFolder=pwd;

addpath([currentFolder '/Subroutines']);
addpath([currentFolder '/../4.5.4/matlab']);% PLEASE change this line to the correct path where you have installed dynare 4.5.4




%% Simulate data from Dynare
dynare SW_Model noclearall
close all

y_sim=squeeze(sim_array(1,:,:));
pie_sim=squeeze(sim_array(2,:,:));
r_sim=squeeze(sim_array(3,:,:));
ms_sim=squeeze(sim_array(4,:,:));
clear sim_array

save('MC_v6_1_data.mat','y_sim','pie_sim','r_sim','ms_sim','r_em','y_em','pinf_em','ms_em') % save posterior moments