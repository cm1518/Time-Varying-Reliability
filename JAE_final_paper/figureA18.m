%% MAR  instrument 1 by 3 subplot with CPI IRF (and fixed coefficient IRF for MAR instrument), as well as estimated beta path and reliability



clear all;
clc;
close all;
currentFolder=pwd;

addpath([currentFolder '/../2. Codes/auxfiles']);
addpath([currentFolder '/../2. Codes/Main']);


savefolder = [currentFolder '/figures'];
warning('off')
mkdir(savefolder)
warning('on')


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


%% plotting NS, BS, GLK Path and Target
vector_of_names={'ns'};

%% Loading results, looping over names
for kk=1:length(vector_of_names)
    % Which TVP-VAR?
    VAR_select=['gk_' vector_of_names{kk} '_v1_q_hcauchy'];
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

    folder1 = [currentFolder '/../2. Codes/Main/results_norm2GK/' VAR_select ];
    folder2 = [currentFolder '/../2. Codes/Main/results_norm2GK/gk_' vector_of_names{kk} '_v1_fixed'];


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


load([folder1 '/irf.mat'])
load([folder1 '/post.mat'])
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
            case 'ns_sum'
                proxy_name{i}='Nakamura-Steinsson'; 
            case 'path_sum'
                proxy_name{i}='GKL Path'; 
            case 'target_sum'
                proxy_name{i}='GKL Target';             
            case 'MPS_ORTH'
                proxy_name{i}='Bauer-Swanson'; 
        end
    end
macrovarSelec=2;
macro_var_str_names='CPI';



nv = size(SVAR.LtildeFull,1);
Horizon = size(SVAR.LtildeFull,2);
H = Horizon -1;
nshock = size(SVAR.LtildeFull,4);
nshockplot=nshock;
FontSize    = 12;
linW        = 1;
color_fix   = [.7 .7 .7]+.1;
color_tvp   = [ 30,144,255]./255;
color_ms    = [220, 20, 60]./255;
patch_axis  = [0:1:H H:-1:0];

figure,orient('Landscape')
% Plot CPI IRFs
subplot(2,2,1:2),hold on,
% plotting fixed coeff IRF
patch_fix = [squeeze(SVAR_Fixed.LtildeFull(macrovarSelec,1:Horizon,2,1))';
    flipdim(squeeze(SVAR_Fixed.LtildeFull(macrovarSelec,1:Horizon,4,1)),2)']';
p_1 = patch(patch_axis,patch_fix,color_fix,'EdgeColor','None');
plot(0:1:H,squeeze(SVAR_Fixed.LtildeFull(macrovarSelec,1:Horizon,3,1)),...
    'Color',color_fix-.2,'LineStyle','-','Marker','none','LineWidth',linW)
% plotting tvp coeff IRF
patch_tvp = [squeeze(SVAR_TVP.LtildeFull(macrovarSelec,1:Horizon,2,1))';
    flipdim(squeeze(SVAR_TVP.LtildeFull(macrovarSelec,1:Horizon,4,1)),2)']';
p_2 = patch(patch_axis,patch_tvp,color_tvp,'EdgeColor','None');
plot(0:1:H,squeeze(SVAR_TVP.LtildeFull(macrovarSelec,1:Horizon,3,1)),...
    'Color',color_tvp,'LineStyle','-','Marker','none','LineWidth',linW)
hline(0,'-k')
alpha(.5)

axis([0 H ylim])
legend([p_1 p_2],{'\beta: Constant','\beta_t: Random Walk'},'Location','NorthEast'),legend boxoff
%     set(gca,'XTick',0:12:H)
%     set(gca,'LineWidth',linW)
xlabel('Horizon (month)')
set(gca,'XTick',0:12:H)
grid on;box on
title('Posterior impulse response function of CPI')


datechar=nDate(sample_iv_init_row(1,1):sample_iv_end_row(1,1),1);
patch_axis  = [datechar' flipdim(datechar,1)'];
% beta(t)
subplot(2,2,3),hold on,
patch_fix = [repmat(SVAR_Fixed.BETFull(1,2),1,length(datechar)) repmat(SVAR_Fixed.BETFull(1,4),1,length(datechar))];
p_1 = patch(patch_axis,patch_fix,color_fix,'EdgeColor','None');
plot(datechar,repmat(SVAR_Fixed.BETFull(1,3),1,length(datechar)),'Color',color_fix-.2,'LineStyle','-','LineWidth',linW);
% TVP
patch_tvp = [SVAR_TVP.BETFull{1,1}(2,:) flipdim(SVAR_TVP.BETFull{1,1}(4,:),2)];
p_2 = patch(patch_axis,patch_tvp,color_tvp,'EdgeColor','None');
plot(datechar,SVAR_TVP.BETFull{1,1}(3,:)','Color',color_tvp,'LineStyle','-','LineWidth',linW);
alpha(.5)
% legend([p_1 p_2],{'Time-Constant','Random Walk'},'Location','NorthEast'),legend boxoff
xlabel('Time')
dateFormat = 10;
datetick('x',dateFormat)
axis tight
grid('on'),box('on')
title('\beta versus \beta_t')

% reliability
subplot(2,2,4),hold on,
patch_fix = [repmat(SVAR_Fixed.RELFull(1,2),1,length(datechar)) repmat(SVAR_Fixed.RELFull(1,4),1,length(datechar))];
p_1 = patch(patch_axis,patch_fix,color_fix,'EdgeColor','None');
plot(datechar,repmat(SVAR_Fixed.RELFull(1,3),1,length(datechar)),'Color',color_fix,'LineStyle','-','LineWidth',linW);
% TVP
patch_tvp = [SVAR_TVP.RELFull{1,1}(2,:) flipdim(SVAR_TVP.RELFull{1,1}(4,:),2)];
p_2 = patch(patch_axis,patch_tvp,color_tvp-.1,'EdgeColor','None');
plot(datechar,SVAR_TVP.RELFull{1,1}(3,:)','Color',color_tvp,'LineStyle','-','LineWidth',linW);
alpha(.5)
% legend([p_1 p_2],{'Time-Constant','Random Walk'},'Location','NorthEast'),legend boxoff
dateFormat = 10;
datetick('x',dateFormat)
axis tight
set(gca,'YLim',[0 1])
grid('on'),box('on')
title('Reliability: \rho versus \rho_t')
xlabel('Time')
% sgtitle('Miranda-Agrippino & Rocco instrument');
set(findall(gcf,'-property','FontSize'),'FontSize',FontSize,'FontWeight','Normal','FontName','Times New Roman')




end

