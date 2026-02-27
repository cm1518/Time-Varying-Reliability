clear all
close all

currentFolder=pwd;
cd([currentFolder '/2. Codes/Main']);

Fixed_BPSVAR_GK;
Fixed_BPSVAR_GK_proxy_adjusted;
Fixed_BPSVAR_normalizedtoGK;
run_setting_proxy_to_zero_FixedCoeff_v1;
run_estimation_data_combined;
run_estimation_data_combined_proxy_adjusted;
run_estimation_data_combined_normalizedtoGK;
run_setting_proxy_to_zero_v1;
run_estimation_uk_data_combined;
run_estimation_uk_data_combined_fixed;
run_estimation_data_combined_SV;
run_estimation_data_combined_lagsinproxyeq

