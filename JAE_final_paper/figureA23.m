%% Figure 2, estimated beta and reliability for TVP and fixed coefficient (1 by 2 subplot)



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
VAR_select='gk_ff4_v1_q0_001_r0_001';
[priors,options_,q_s0_options]=model_specs_data_combined_SV(VAR_select);
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
folder2 = [currentFolder '/2. Codes/Main/results/gk_ff4_v1_q_hcauchy'];

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
f = 0.25/SVAR.LtildeFull(1,1,3);
SVAR.LtildeFull=f*SVAR.LtildeFull;
SVAR_TVP = SVAR;

load([folder2 '/irf.mat'])
load([folder2 '/post.mat'])
f = 0.25/SVAR.LtildeFull(1,1,3);
SVAR.LtildeFull=f*SVAR.LtildeFull;
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


FontSize    = 14;
linW        = 2;
color_fix   = [.7 .7 .7]+.1;
color_tvp   = [ 30,144,255]./255;
color_ms    = [220, 20, 60]./255;

%% Plot Relevance & Reliability
figure('Name','Relevance'),orient('Landscape'),hold('on')
datechar = nDate(sample_iv_init_row(1,1):sample_iv_end_row(1,1),1);
patch_axis  = [datechar' flipdim(datechar,1)'];

subplot(2,2,1),hold('on'),
%beta
% fixed coeff
patch_fix = [SVAR_Fixed.BETFull{1,1}(2,:) flipdim(SVAR_Fixed.BETFull{1,1}(4,:),2)];
p_1 = patch(patch_axis,patch_fix,color_fix,'EdgeColor','None');
plot(datechar,SVAR_Fixed.BETFull{1,1}(3,:)','Color',color_fix,'LineStyle','-','LineWidth',linW);
% TVP
patch_tvp = [SVAR_TVP.BETFull{1,1}(2,:) flipdim(SVAR_TVP.BETFull{1,1}(4,:),2)];
p_2 = patch(patch_axis,patch_tvp,color_tvp,'EdgeColor','None');
plot(datechar,SVAR_TVP.BETFull{1,1}(3,:)','Color',color_tvp,'LineStyle','-','LineWidth',linW);
alpha(.5)
legend([p_1 p_2],{'no SV','with SV'},'Location','NorthEast'),legend boxoff
%     set(gca,'XTick',0:12:H)
%     set(gca,'LineWidth',linW)
xlabel('Time')
dateFormat = 10;
datetick('x',dateFormat)
axis tight
grid('on'),box('on')
title('Parameter')


subplot(2,2,2),hold('on'),
%SV
% fixed coeff
patch_fix = [repmat(SVAR_Fixed.SIGFull(1,2),1,length(datechar)) repmat(SVAR_Fixed.SIGFull(1,4),1,length(datechar))];
p_1 = patch(patch_axis,patch_fix,color_fix,'EdgeColor','None');
plot(datechar,repmat(SVAR_Fixed.SIGFull(1,3),1,length(datechar)),'Color',color_fix-.2,'LineStyle','-','LineWidth',linW);
% TVP
patch_tvp = [SVAR_TVP.SIGFull{1,1}(2,:) flipdim(SVAR_TVP.SIGFull{1,1}(4,:),2)];
p_2 = patch(patch_axis,patch_tvp,color_tvp,'EdgeColor','None');
plot(datechar,SVAR_TVP.SIGFull{1,1}(3,:)','Color',color_tvp,'LineStyle','-','LineWidth',linW);
alpha(.5)
legend([p_1 p_2],{'no SV','with SV'},'Location','NorthEast'),legend boxoff
%     set(gca,'XTick',0:12:H)
%     set(gca,'LineWidth',linW)
xlabel('Time')
dateFormat = 10;
datetick('x',dateFormat)
axis tight
grid('on'),box('on')
title('Volatility')



% reliability
subplot(2,2,3),hold('on'),
% fixed coeff
patch_fix = [SVAR_Fixed.RELFull{1,1}(2,:) flipdim(SVAR_Fixed.RELFull{1,1}(4,:),2)];
p_1 = patch(patch_axis,patch_fix,color_fix-.1,'EdgeColor','None');
plot(datechar,SVAR_Fixed.RELFull{1,1}(3,:)','Color',color_fix,'LineStyle','-','LineWidth',linW);
% TVP
patch_tvp = [SVAR_TVP.RELFull{1,1}(2,:) flipdim(SVAR_TVP.RELFull{1,1}(4,:),2)];
p_2 = patch(patch_axis,patch_tvp,color_tvp-.1,'EdgeColor','None');
plot(datechar,SVAR_TVP.RELFull{1,1}(3,:)','Color',color_tvp,'LineStyle','-','LineWidth',linW);
alpha(.5)
legend([p_1 p_2],{'no SV','with SV'},'Location','NorthEast'),legend boxoff
dateFormat = 10;
datetick('x',dateFormat)
set(gca,'YLim',[0 1])
axis tight
grid('on'),box('on')
title('Reliability')

set(findall(gcf,'-property','FontSize'),'FontSize',FontSize,'FontWeight','Normal','FontName','Times New Roman')






