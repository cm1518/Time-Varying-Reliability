delete SW_Model_sv.log
%delete SW_Model.m
%delete SW_Model_dynamic.m
delete SW_Model_sv_results.mat
%delete SW_Model_set_auxiliary_variables.m
%delete SW_Model_static.m
rmdir SW_Model_sv/Output
rmdir('SW_Model_sv','s')
% load polfunction
% clc