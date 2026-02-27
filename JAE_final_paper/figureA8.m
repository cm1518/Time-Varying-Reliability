%% Monte Carlo: plotted true values and point estimates of beta path.

clear all;
clc;
close all;
currentFolder=pwd;

addpath([currentFolder '/../2. Codes/auxfiles']);
addpath([currentFolder '/../2. Codes/Main']);


savefolder = [currentFolder '/figures'];
mkdir(savefolder)   



%% load data, which one? specify savefolder!
folder = [currentFolder '/../2. Codes/Main/results/MC_v7_2'];  % Change here for the MC results file
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

xbars1 = [1 4];
xbars2 = [141 149];
xbars3 = [231 246];

for i=1:number_of_MC
   maxbeta(i,1)=max(res_TVP_SVAR{i,1}.BETFull{1,1}(3,:));
   minbeta(i,1)=min(res_TVP_SVAR{i,1}.BETFull{1,1}(3,:));
end

maxbeta=max(maxbeta);
minbeta=min(minbeta);

%minbeta = -0.1;
%maxbeta = 0.3;

FontSize    = 14;
linW        = 1;
color_fix   = [176,196,222]/255;%[.7 .7 .7]+.1;
color_tvp   = [ 30,144,255]./255;
color_ms    = [220, 20, 60]./255;

figure('Name','MC'),orient('landscape'),hold on,


pS=plot(res_TVP_SVAR{1,1}.BETFull{1,1}(3,:),'color',color_fix,'LineWidth',linW);
hold on

fill([xbars1(1) xbars1(1), xbars1(2) xbars1(2)],[minbeta maxbeta maxbeta minbeta],  [0.8 0.8 0.8],'LineStyle','none')
fill([xbars2(1) xbars2(1), xbars2(2) xbars2(2)],[minbeta maxbeta maxbeta minbeta],  [0.8 0.8 0.8],'LineStyle','none')
fill([xbars3(1) xbars3(1), xbars3(2) xbars3(2)],[minbeta maxbeta maxbeta minbeta],  [0.8 0.8 0.8],'LineStyle','none')
 
for i=1:number_of_MC
    p_1=plot(res_TVP_SVAR{i,1}.BETFull{1,1}(3,:),'color',color_fix,'LineWidth',linW);
  
end
%p_2=plot(rel,'k','LineWidth',2);
%legend([p_1(1) p_2],{'Monte Carlo Realization','True DGP'},'Location','NorthWest'),legend boxoff
%hline(0,'-k')
%title(macro_var_str_names(:,ii),'FontSize',graph_opt.font_num,'FontWeight','bold','Interpreter','none')
axis tight,grid off,box on,
title('\beta_t')
xlabel('Periods')
set(findall(gcf,'-property','FontSize'),'FontSize',FontSize,'FontWeight','Normal','FontName','Times New Roman')

saveas(gcf,[savefolder '/fig_MC_v71_beta.pdf'])
saveas(gcf,[savefolder '/fig_MC_v71_beta.eps'],'epsc')
saveas(gcf,[savefolder '/fig_MC_v71_beta.fig'],'fig')

