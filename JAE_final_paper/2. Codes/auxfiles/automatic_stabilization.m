function [tuning_para]=automatic_stabilization(tuning_para,jsux_kQ,jrep,options_)
% For RW-MH sampling:
% adjusting the std of the proposal increment innovation. if acceptance
% ratio is too low (cfactor<1), decrease the std, increse otherwise
%
% the tuning algorithm is controlled with a relaxation parameter
% 0<relax<1, adjustment is "faster" for higher relaxation parameter

% Tuning phase 

test1 = jsux_kQ/jrep;
%disp(['Average Acceptance Ratio kQ - Burn In: ' num2str(test1)])
if test1<1e-6
    error('Average acceptance ratio for q_s0 during the tuning phase is too low')
end;
cfactor1= test1/options_.AcceptanceTarget;
tuning_para =  (1-options_.relax)*tuning_para+options_.relax*(tuning_para.*cfactor1); 





