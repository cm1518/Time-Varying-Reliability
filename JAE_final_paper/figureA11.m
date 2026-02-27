%% Figure 1, plots  fixed coefficient and TVP IRFs either all 4 variables 
%% MAR version



clear all;
clc;
close all;
currentFolder=pwd;

addpath([currentFolder '/2. Codes/auxfiles']);
addpath([currentFolder '/2. Codes/Main']);


savefolder = [currentFolder '/figures'];
warning off;
mkdir(savefolder)   
warning on;


graph_opt.font_num=10;

str_iv_init={};
str_iv_end={};
macro_var_str_names={};

%% Loading data
 
data_file = '4. Data/data_combined.txt'; % this is important, load data in a very specific way

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


%% Loading results

% Which TVP-VAR?
VAR_select='gk_ff4_v1_q_hcauchy';
[priors,options_,q_s0_options]=model_specs_data_combined(VAR_select);
options_.savefig=1;
% clearing objects
sample_iv_init=[];
sample_iv_end=[];
sample_iv_init_row=[];
sample_iv_end_row=[];
proxy=[];
sample_vector=[];

% folders
folder1 = [currentFolder '/2. Codes/Main/results/' VAR_select ];
folder2 = [currentFolder '/2. Codes/Main/results/gk_ff4_v1_fixed'];

i_var_instr = options_.instrList;
nIV = size(i_var_instr,2);

[~,i_var] = ismember(options_.i_var_str,text(1,2:end));
[~,i_instr] = ismember(i_var_instr,text(1,2:end));

%************************************************/
% RETRIEVE POSITION OF FIRST AND LAST OBSERVATION/
%************************************************/
T0=options_.p;

sample_init = datenum(options_.str_sample_init, 'yyyy-mm-dd');
sample_end = datenum(options_.str_sample_end, 'yyyy-mm-dd');
%sample_iv_init = datenum(str_iv_init, 'yyyy-mm-dd');

[~, sample_init_row] = ismember(sample_init,nDate,'rows');
[~, sample_end_row] = ismember(sample_end,nDate,'rows');
%[~, sample_iv_row] = ismember(sample_iv_init,nDate,'rows');

for i=1:nIV
    sample_iv_init(i,1) = datenum(options_.str_iv_init{i,1}, 'yyyy-mm-dd');
    sample_iv_end(i,1) = datenum(options_.str_iv_end{i,1}, 'yyyy-mm-dd');
    [~, sample_iv_init_row(i,1)] = ismember(sample_iv_init(i,1),nDate,'rows');
    [~, sample_iv_end_row(i,1)] = ismember(sample_iv_end(i,1),nDate,'rows');
    proxy{i,1} = YYdata(sample_iv_init_row(i,1):sample_iv_end_row(i,1),i_instr(i));
    % reconstructing the location of instruments w.r.t. post-sample
    sample_vector(i,1) = sample_iv_init_row(i,1) - T0 - (sample_init_row-1);
    sample_vector(i,2) = sample_iv_end_row(i,1) - T0 - (sample_init_row-1);
end



data = YYdata(sample_init_row:sample_end_row,i_var);


load([folder1 '/irf_proxy2zero_v1.mat'])
load([folder1 '/post_proxy2zero_v1.mat'])
SVAR_TVP = SVAR;

load([folder2 '/irf.mat'])
load([folder2 '/post.mat'])

SVAR_Fixed = SVAR;



%% Plotting    .

for i=1:length(i_var_instr)
    switch i_var_instr{i}
        case 'ff4_tc'   
            proxy_name{i}='Gertler&Karadi';
        case 'rr_resid_full'
            proxy_name{i}='Romer&Romer';
        case 'MM_IV1'
            proxy_name{i}='Miranda-Agrippino&Ricco'; 
    end
end
macrovarSelec=options_.macrovarSelec;
macro_var_str_names=options_.macro_var_str_names;

FontSize    = 14;
nv          = size(SVAR.LtildeFull,1);
Horizon     = size(SVAR.LtildeFull,2);
H           = Horizon -1;
nshock      = size(SVAR.LtildeFull,4); 
nshockplot  = nshock;
linW        = 1.5;
[nbplt,nr,nc,lr,lc,nstar] = pltorg(length(macrovarSelec));

color_fix   = [.7 .7 .7]+.1;
color_tvp   = [ 30,144,255]./255;
color_ms    = [220, 20, 60]./255;
patch_axis = [0:1:H H:-1:0];

% Plot Macro IRFs
figure('Name','All Variables'),orient('Landscape')
for ii = 1:length(macrovarSelec) % Variable
    subplot(nr,nc,ii),hold('on')
    % plotting fixed coeff IRF
%     p1=plot(0:1:H,squeeze(SVAR_Fixed.LtildeFull(macrovarSelec(ii),1:Horizon,3,1)),'r','LineWidth',linW);
%     hline(0,'-k')
%     plot(0:1:H,squeeze(SVAR_Fixed.LtildeFull(macrovarSelec(ii),1:Horizon,2,1)),'r--','LineWidth',linW)
%     plot(0:1:H,squeeze(SVAR_Fixed.LtildeFull(macrovarSelec(ii),1:Horizon,4,1)),'r--','LineWidth',linW)     
    patch_fix = [squeeze(SVAR_Fixed.LtildeFull(macrovarSelec(ii),1:Horizon,2,1))';
        flipdim(squeeze(SVAR_Fixed.LtildeFull(macrovarSelec(ii),1:Horizon,4,1)),2)']';
    p_1 = patch(patch_axis,patch_fix,color_fix,'EdgeColor','None');
    plot(0:1:H,squeeze(SVAR_Fixed.LtildeFull(macrovarSelec(ii),1:Horizon,3,1)),'Color',color_fix-.2,'LineStyle','-','LineWidth',linW)
    
    
    % plotting TVP IRF 
%     p2=plot(0:1:H,squeeze(SVAR_TVP.LtildeFull(macrovarSelec(ii),1:Horizon,3,1)),'b','LineWidth',linW);
%     plot(0:1:H,squeeze(SVAR_TVP.LtildeFull(macrovarSelec(ii),1:Horizon,2,1)),'b--','LineWidth',linW)
%     plot(0:1:H,squeeze(SVAR_TVP.LtildeFull(macrovarSelec(ii),1:Horizon,4,1)),'b--','LineWidth',linW)
    patch_tvp = [squeeze(SVAR_TVP.LtildeFull(macrovarSelec(ii),1:Horizon,2,1))';
        flipdim(squeeze(SVAR_TVP.LtildeFull(macrovarSelec(ii),1:Horizon,4,1)),2)']';
    p_2 = patch(patch_axis,patch_tvp,color_tvp,'EdgeColor','None');
    plot(0:1:H,squeeze(SVAR_TVP.LtildeFull(macrovarSelec(ii),1:Horizon,3,1)),'Color',color_tvp,'LineStyle','-','LineWidth',linW)
    hline(0,'-k')
 
    alpha(.5)
     
    title(macro_var_str_names(:,macrovarSelec(ii)),'FontSize',graph_opt.font_num,'FontWeight','bold','Interpreter','none')
    axis([0 H ylim])
    if ii==4,legend([p_1 p_2],{'\beta: Constant','\beta_t: Random Walk'},'Location','NorthEast'),legend boxoff,end
    if ii>2,xlabel('Horizon (month)'),end
    set(gca,'XTick',0:12:H)
%     set(gca,'LineWidth',linW)
    grid on;box on
end
% sgtitle('Impulse Responses: median and 68 prob. band')
set(findall(gcf,'-property','FontSize'),'FontSize',FontSize,'FontWeight','Normal','FontName','Times New Roman')




