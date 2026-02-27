%% -----------------
% HOUSE KEEPING
%----------------

clear all;
clc;
close all;
currentFolder=pwd;

addpath([currentFolder '\auxfiles']);


%% Loading data
 
data_file = 'U:\Eigene Dateien\Research\TimeVaryingProxyReliability\4. Data\data_combined.txt'; % this is important, load data in a very specific way
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

i_var_str =  {'gs1','logcpi','logip','ebp'};
macro_var_str_names =  {'Gov Bond 1y', 'CPI', 'IP', 'Excess Bond Premium'}; % Name of variables (for plots)
i_var_instr = {'ff4_tc','rr_resid_full','MM_IV1'};
proxy_name={'Gertler&Karadi','Romer&Romer','Miranda-Agrippino&Ricco'};
macrovarSelec=[1:4];
% Sample dates
% -------------------------------------------------------------------------
str_sample_init     = '1979-07-01';         % Starting date of the sample (include pre-sample)
% str_sample_init     = '1986-01-01';         % Starting date of the sample (include pre-sample)
str_sample_end      = '2012-06-01';         % End date of the sample

% Proxy dates
% -------------------------------------------------------------------------
% 
str_iv_init{1,1}    = '1991-01-01';         % Starting date of the sample for the proxy 1
str_iv_end{1,1}     = '2012-06-01';         % Ending date of the sample for the proxy 1
str_iv_init{2,1}    = '1980-07-01';         % Starting date of the sample for the proxy 2
str_iv_end{2,1}     = '2007-12-01';         % Ending date of the sample for the proxy 2
str_iv_init{3,1}    = '1991-01-01';         % Starting date of the sample for the proxy 3
str_iv_end{3,1}     = '2009-12-01';         % Ending date of the sample for the proxy 3


nIV = size(i_var_instr,2);



[~,i_var] = ismember(i_var_str,text(1,2:end));
[~,i_instr] = ismember(i_var_instr,text(1,2:end));

%************************************************/
% RETRIEVE POSITION OF FIRST AND LAST OBSERVATION/
%************************************************/
T0=12;

sample_init = datenum(str_sample_init, 'yyyy-mm-dd');
sample_end = datenum(str_sample_end, 'yyyy-mm-dd');
%sample_iv_init = datenum(str_iv_init, 'yyyy-mm-dd');

[~, sample_init_row] = ismember(sample_init,nDate,'rows');
[~, sample_end_row] = ismember(sample_end,nDate,'rows');
%[~, sample_iv_row] = ismember(sample_iv_init,nDate,'rows');

for i=1:nIV
    sample_iv_init(i,1) = datenum(str_iv_init{i,1}, 'yyyy-mm-dd');
    sample_iv_end(i,1) = datenum(str_iv_end{i,1}, 'yyyy-mm-dd');
    [~, sample_iv_init_row(i,1)] = ismember(sample_iv_init(i,1),nDate,'rows');
    [~, sample_iv_end_row(i,1)] = ismember(sample_iv_end(i,1),nDate,'rows');
    proxy{i,1} = YYdata(sample_iv_init_row(i,1):sample_iv_end_row(i,1),i_instr(i));
    % reconstructing the location of instruments w.r.t. post-sample
    sample_vector(i,1) = sample_iv_init_row(i,1) - T0 - (sample_init_row-1);
    sample_vector(i,2) = sample_iv_end_row(i,1) - T0 - (sample_init_row-1);
end



data = YYdata(sample_init_row:sample_end_row,i_var);


%% Plotting    .

linW = 1.5;
[nbplt,nr,nc,lr,lc,nstar] = pltorg(length(macrovarSelec));


figure('Name','Aggregate Variables')
for ii = 1:4
    datechar=nDate(sample_init_row:sample_end_row,1);
    subplot(nr,nc,ii)
    plot(datechar,data(:,ii),'k','LineWidth',linW)
    dateFormat = 10;
    datetick('x',dateFormat)
    axis tight
    grid on
    title([macro_var_str_names{ii}],'Interpreter','none')
end

saveas(gcf,'data.pdf')
saveas(gcf,'data.eps','epsc')
saveas(gcf,'data.fig','fig')


figure('Name','Proxies')
for ii = 1:length(i_var_instr)
    datechar=nDate(sample_iv_init_row(ii,1):sample_iv_end_row(ii,1),1);
    subplot(nr,nc,ii)
    plot(datechar,proxy{ii,1},'k','LineWidth',linW)
    dateFormat = 10;
    datetick('x',dateFormat)
    axis tight
    grid on
    title(['Proxy: ' proxy_name{ii}],'Interpreter','none')
end


saveas(gcf,'proxies.pdf')
saveas(gcf,'proxies.eps','epsc')
saveas(gcf,'proxies.fig','fig')


close all

