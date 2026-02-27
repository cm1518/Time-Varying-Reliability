%% Monte Carlo: 1 subplot with 3 irfs that show the true IRFS as well as the point estimates for each MC run

clear all;
clc;
close all;
currentFolder=pwd;

addpath([currentFolder '/2. Codes/auxfiles']);
addpath([currentFolder '/2. Codes/Main']);


savefolder = [currentFolder '/figures'];
mkdir(savefolder)   



%% load data, which one? specify savefolder!

folder = [currentFolder '/2. Codes/Main/results/MC_v7_2'];  % Change here for the MC results file
load([folder '/results.mat'])




%%
number_of_MC = size(res_TVP_SVAR,1);
graph_opt.font_num=10;
macro_var_str_names={'Interest Rate', 'Output', 'Inflation'};

nv = size(res_TVP_SVAR{1,1}.LtildeFull,1);
%Horizon = size(res_TVP_SVAR{1,1}.LtildeFull,2);
Horizon =25;
H = Horizon -1;
nshock = size(res_TVP_SVAR{1,1}.LtildeFull,4); 
nshockplot=nshock;
FontSize    = 14;
linW        = 1;
%color_fix   = [176,196,222]/255;%[.7 .7 .7]+.1;
color_tvp   = [ 30,144,255]./255;
% color_tvp   = 'blue';%[.7 .7 .7]+.1;
color_fix   = 'red';
color_ms    = [220, 20, 60]./255;
patch_axis  = [0:1:H H:-1:0];


for i=1:number_of_MC
    % collecting all median IRFs
    median_IRF_TVP(:,:,i)=squeeze(res_TVP_SVAR{i,1}.LtildeFull(:,1:Horizon,3,1));
    median_IRF_Fixed(:,:,i)=squeeze(res_Fixed_SVAR{i,1}.LtildeFull(:,1:Horizon,3,1));
    
    % collecting all 68% IRFs
    
    lb_IRF_TVP(:,:,i)=squeeze(res_TVP_SVAR{i,1}.LtildeFull(:,1:Horizon,2,1));
    ub_IRF_TVP(:,:,i)=squeeze(res_TVP_SVAR{i,1}.LtildeFull(:,1:Horizon,4,1));
    
    lb_IRF_Fixed(:,:,i)=squeeze(res_Fixed_SVAR{i,1}.LtildeFull(:,1:Horizon,2,1));
    ub_IRF_Fixed(:,:,i)=squeeze(res_Fixed_SVAR{i,1}.LtildeFull(:,1:Horizon,4,1));
    
end
ptileVEC = [0.05 0.16 0.50 0.84 0.95]; 
% 
% figure('Name','MC1'),orient('landscape'),hold on,
% for ii = 1:4 % Variable
%     subplot(2,2,ii)
%     if ii ~= 4
%         
%         
%         p_1a1 = plot(0:1:H,quantile(median_IRF_TVP(ii,:,:),0.16,3),'color',color_tvp,'LineWidth',.5);
%         hold on
%         p_1a2 = plot(0:1:H,quantile(median_IRF_TVP(ii,:,:),0.84,3),'color',color_tvp,'LineWidth',.5);
%        
%         p_1b1 = plot(0:1:H,quantile(median_IRF_Fixed(ii,:,:),0.16,3),'color',color_fix,'LineWidth',.5);
%         p_1b2 = plot(0:1:H,quantile(median_IRF_Fixed(ii,:,:),0.84,3),'color',color_fix,'LineWidth',.5);
%   
%         if ii==1
%             p_2 = plot(0:1:H,r_em(1:Horizon),'k','LineWidth',2);
%         elseif ii==2
%             p_2 = plot(0:1:H,y_em(1:Horizon),'k','LineWidth',2);
%         elseif ii==3
%             p_2 = plot(0:1:H,pinf_em(1:Horizon),'k','LineWidth',2);
%         end
%         hline(0,'-k')
%         title(macro_var_str_names(:,ii),'FontSize',graph_opt.font_num,'FontWeight','bold','Interpreter','none')
% %         legend([p_1(1) p_2],{'Monte Carlo Realization','True DGP'},'Location','NorthEast'),legend boxoff
%         axis([0 H ylim])
%         set(gca,'XTick',0:12:H)
%         set(gca,'LineWidth',linW)
%         grid off,box on
%     else 
%         p_1a = plot(0:1:H,squeeze(res_TVP_SVAR{i,1}.LtildeFull(1,1:Horizon,3,1)),'color',color_tvp,'LineWidth',2);hold on
%         p_1b = plot(0:1:H,squeeze(res_Fixed_SVAR{i,1}.LtildeFull(1,1:Horizon,3,1)),'color',color_fix,'LineWidth',2);hold on
%         p_2 = plot(0:1:H,r_em(1:Horizon),'k','LineWidth',2);
%         title('Legend','FontSize',graph_opt.font_num,'FontWeight','bold','Interpreter','none')
%         legend([p_1a p_1b p_2],{'TVP SVAR','Fixed SVAR','True DGP'},'Location','NorthWest'),legend boxoff
%         set(gca,'XLim',[100 101],'YTickLabel',[],'XTickLabel',[]);
%     end
% end
% set(findall(gcf,'-property','FontSize'),'FontSize',FontSize,'FontWeight','Normal','FontName','Times New Roman')
% % sgtitle('Impulse Responses: DGP vs. MC')
% 
% % saveas(gcf,[savefolder '/fig6_pretty.pdf'])
% % saveas(gcf,[savefolder '/fig6_pretty.eps'],'epsc')
% % saveas(gcf,[savefolder '/fig6_pretty.fig'],'fig')


figure('Name','MC2'),orient('landscape'),hold on,
for ii = 1:4 % Variable
    subplot(2,2,ii),hold on;
    if ii ~= 4
        
        
%         p_1a1 = plot(0:1:H,mean(lb_IRF_TVP(ii,:,:),3),'color',color_tvp,'LineWidth',1);
%         hold on
%         p_1a2 = plot(0:1:H,mean(ub_IRF_TVP(ii,:,:),3),'color',color_tvp,'LineWidth',1);
       
        patch_tmp = [mean(lb_IRF_TVP(ii,:,:),3) flipdim(mean(ub_IRF_TVP(ii,:,:),3),2)];
        p_1a2 = patch(patch_axis,patch_tmp,color_tvp,'EdgeColor','None');
        alpha(.5)
        p_1b1 = plot(0:1:H,mean(lb_IRF_Fixed(ii,:,:),3),'color',color_fix,'LineWidth',1);
        p_1b2 = plot(0:1:H,mean(ub_IRF_Fixed(ii,:,:),3),'color',color_fix,'LineWidth',1);
  
        if ii==1
            p_2 = plot(0:1:H,r_em(1:Horizon),'k','LineWidth',2);
        elseif ii==2
            p_2 = plot(0:1:H,y_em(1:Horizon),'k','LineWidth',2);
        elseif ii==3
            p_2 = plot(0:1:H,pinf_em(1:Horizon),'k','LineWidth',2);
        end
        hline(0,'-k')
        title(macro_var_str_names(:,ii),'FontSize',graph_opt.font_num,'FontWeight','bold','Interpreter','none')
%         legend([p_1(1) p_2],{'Monte Carlo Realization','True DGP'},'Location','NorthEast'),legend boxoff
        axis([0 H ylim])
        set(gca,'XTick',0:12:H)
        set(gca,'LineWidth',linW)
        grid off,box on
    else 
        patch_tmp = [squeeze(res_TVP_SVAR{i,1}.LtildeFull(1,1:Horizon,3,1)) flipdim(squeeze(res_TVP_SVAR{i,1}.LtildeFull(1,1:Horizon,3,1)),2)];
        p_1a = patch(patch_axis,patch_tmp,color_tvp,'EdgeColor','None');

%         p_1a = plot(0:1:H,squeeze(res_TVP_SVAR{i,1}.LtildeFull(1,1:Horizon,3,1)),'color',color_tvp,'LineWidth',2);hold on
        p_1b = plot(0:1:H,squeeze(res_Fixed_SVAR{i,1}.LtildeFull(1,1:Horizon,3,1)),'color',color_fix,'LineWidth',2);hold on
        alpha(.5)
        p_2 = plot(0:1:H,r_em(1:Horizon),'k','LineWidth',2);
        title('Legend','FontSize',graph_opt.font_num,'FontWeight','bold','Interpreter','none')
        legend([p_1a p_1b p_2],{'TVP SVAR','Fixed SVAR','True DGP'},'Location','NorthWest'),legend boxoff
        set(gca,'XLim',[100 101],'YTickLabel',[],'XTickLabel',[]);box on;
    end
end
set(findall(gcf,'-property','FontSize'),'FontSize',FontSize,'FontWeight','Normal','FontName','Times New Roman')
sgtitle('Impulse Responses: MC average of 68% bands')

