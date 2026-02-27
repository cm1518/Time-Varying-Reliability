clear
close all
clc

currentFolder=pwd;

addpath([currentFolder '/2. Codes/auxfiles']);
addpath([currentFolder '/2. Codes/Main']);

VariableNames = ["T=200, 1%","T=200, 10%","T=200, 50%",...
                            "T=500, 1%","T=500, 10%","T=500, 50%",...
                             "T=1000, 1%","T=1000, 10%","T=1000, 50%"];
RowNames =["h=1","h=6","h=12","h=24"];

horizons =[1,6,12,24];


for i = 1:9

    rmse{i}=MC_irf_rmse_func(['MC_resub_v' num2str(i)]);
    var1_rmse(:,i) = rmse{i}.TVP(:,1)./rmse{i}.Fixed(:,1); 
    var2_rmse(:,i) = rmse{i}.TVP(:,2)./rmse{i}.Fixed(:,2); 

     
    T_var1_rmse(:,i) = table(var1_rmse(horizons,i) );
    T_var2_rmse(:,i) = table(var2_rmse(horizons,i) );

end
  % RMSE of posterior median IRF to true IRF
 
T_var1_rmse.Properties.Description = 'RMSE of TVP model / RMSE of fixed model, variable 1 to shock 1';
T_var2_rmse.Properties.Description = 'RMSE of TVP model / RMSE of fixed model, variable 2 to shock 1';

T_var1_rmse.Properties.VariableNames = VariableNames;
T_var2_rmse.Properties.VariableNames = VariableNames;
T_var1_rmse.Properties.RowNames = RowNames;
T_var2_rmse.Properties.RowNames = RowNames;

T_var1_rmse
T_var2_rmse