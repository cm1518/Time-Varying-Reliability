% runs all scripts for Monte Carlo simulations
% requires installation of Dynare 4.5.4. The default installation folder
% should be '/2. Codes/4.5.4/'

clear all
close all
currentFolder=pwd;
cd([currentFolder '/2. Codes/Main']);


MC_v5_1_simu; 
MC_v5_1; 
MC_v6_1_simu; 
MC_v6_1; 
MC_v7_1_simu; 
MC_v7_1; 
MC_v7_2; 
run_MC_resub;
MC_v5_1_MSDGP