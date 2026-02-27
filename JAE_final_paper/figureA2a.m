%% Monte Carlo: plotted true values and point estimates of reliability path.

clear all;
clc;
close all;
currentFolder=pwd;

addpath([currentFolder '/2. Codes/auxfiles']);
addpath([currentFolder '/2. Codes/Main']);


savefolder = [currentFolder '/figures'];
mkdir(savefolder)   



%% load data, which one? specify savefolder!
folder = [currentFolder '/2. Codes/Main/results/MC_v5_1'];  % Change here for the MC results file
load([folder '/results.mat'])




%%
number_of_MC = size(res_TVP_SVAR,1);
graph_opt.font_num=10;

% reliability definition
% rho = beta^2 / (beta^2 + sigma^2)
sigma_m = 0.2290; % stdev of MP shock of the SW-DGP
kappa =0.25;
rel=ones(246,1)/(1+kappa*(sigma_m)^2);
rel(5:140,1)=0;
rel(150:230,1)=0;


FontSize    = 14;
linW        = 1;
color_fix   = [176,196,222]/255;%[.7 .7 .7]+.1;
color_tvp   = [ 30,144,255]./255;
color_ms    = [220, 20, 60]./255;

figure('Name','MC'),orient('landscape'),hold on,
for i=1:number_of_MC
    p_1=plot(res_TVP_SVAR{i,1}.RELFull{1,1}(3,:),'color',color_fix,'LineWidth',linW);
    hold on
end
p_2=plot(rel,'k','LineWidth',2);
legend([p_1(1) p_2],{'Monte Carlo Realization','True DGP'},'Location','NorthWest'),legend boxoff
%hline(0,'-k')
%title(macro_var_str_names(:,ii),'FontSize',graph_opt.font_num,'FontWeight','bold','Interpreter','none')
axis tight,grid off,box on,
title('Reliability: \rho_{DGP} vs. \rho_{MC}')
xlabel('Periods')
set(findall(gcf,'-property','FontSize'),'FontSize',FontSize,'FontWeight','Normal','FontName','Times New Roman')

%saveas(gcf,[savefolder '/fig_MC_v51_reliability.pdf'])
%saveas(gcf,[savefolder '/fig_MC_v51_reliability.eps'],'epsc')
%saveas(gcf,[savefolder '/fig_MC_v51_reliability.fig'],'fig')

