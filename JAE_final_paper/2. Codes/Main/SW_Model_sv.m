%
% Status : main Dynare file
%
% Warning : this file is generated automatically by Dynare
%           from model file (.mod)

if isoctave || matlab_ver_less_than('8.6')
    clear all
else
    clearvars -global
    clear_persistent_variables(fileparts(which('dynare')), false)
end
tic0 = tic;
% Save empty dates and dseries objects in memory.
dates('initialize');
dseries('initialize');
% Define global variables.
global M_ options_ oo_ estim_params_ bayestopt_ dataset_ dataset_info estimation_info ys0_ ex0_
options_ = [];
M_.fname = 'SW_Model_sv';
M_.dynare_version = '4.5.4';
oo_.dynare_version = '4.5.4';
options_.dynare_version = '4.5.4';
%
% Some global variables initialization
%
global_initialization;
diary off;
diary('SW_Model_sv.log');
M_.exo_names = 'em';
M_.exo_names_tex = 'em';
M_.exo_names_long = 'em';
M_.exo_names = char(M_.exo_names, 'ea');
M_.exo_names_tex = char(M_.exo_names_tex, 'ea');
M_.exo_names_long = char(M_.exo_names_long, 'ea');
M_.exo_names = char(M_.exo_names, 'eb');
M_.exo_names_tex = char(M_.exo_names_tex, 'eb');
M_.exo_names_long = char(M_.exo_names_long, 'eb');
M_.exo_names = char(M_.exo_names, 'eg');
M_.exo_names_tex = char(M_.exo_names_tex, 'eg');
M_.exo_names_long = char(M_.exo_names_long, 'eg');
M_.exo_names = char(M_.exo_names, 'eqs');
M_.exo_names_tex = char(M_.exo_names_tex, 'eqs');
M_.exo_names_long = char(M_.exo_names_long, 'eqs');
M_.exo_names = char(M_.exo_names, 'epinf');
M_.exo_names_tex = char(M_.exo_names_tex, 'epinf');
M_.exo_names_long = char(M_.exo_names_long, 'epinf');
M_.exo_names = char(M_.exo_names, 'ew');
M_.exo_names_tex = char(M_.exo_names_tex, 'ew');
M_.exo_names_long = char(M_.exo_names_long, 'ew');
M_.endo_names = 'y';
M_.endo_names_tex = 'y';
M_.endo_names_long = 'y';
M_.endo_names = char(M_.endo_names, 'pinf');
M_.endo_names_tex = char(M_.endo_names_tex, 'pinf');
M_.endo_names_long = char(M_.endo_names_long, 'pinf');
M_.endo_names = char(M_.endo_names, 'r');
M_.endo_names_tex = char(M_.endo_names_tex, 'r');
M_.endo_names_long = char(M_.endo_names_long, 'r');
M_.endo_names = char(M_.endo_names, 'ms');
M_.endo_names_tex = char(M_.endo_names_tex, 'ms');
M_.endo_names_long = char(M_.endo_names_long, 'ms');
M_.endo_names = char(M_.endo_names, 'ewma');
M_.endo_names_tex = char(M_.endo_names_tex, 'ewma');
M_.endo_names_long = char(M_.endo_names_long, 'ewma');
M_.endo_names = char(M_.endo_names, 'epinfma');
M_.endo_names_tex = char(M_.endo_names_tex, 'epinfma');
M_.endo_names_long = char(M_.endo_names_long, 'epinfma');
M_.endo_names = char(M_.endo_names, 'yf');
M_.endo_names_tex = char(M_.endo_names_tex, 'yf');
M_.endo_names_long = char(M_.endo_names_long, 'yf');
M_.endo_names = char(M_.endo_names, 'a');
M_.endo_names_tex = char(M_.endo_names_tex, 'a');
M_.endo_names_long = char(M_.endo_names_long, 'a');
M_.endo_names = char(M_.endo_names, 'b');
M_.endo_names_tex = char(M_.endo_names_tex, 'b');
M_.endo_names_long = char(M_.endo_names_long, 'b');
M_.endo_names = char(M_.endo_names, 'g');
M_.endo_names_tex = char(M_.endo_names_tex, 'g');
M_.endo_names_long = char(M_.endo_names_long, 'g');
M_.endo_names = char(M_.endo_names, 'qs');
M_.endo_names_tex = char(M_.endo_names_tex, 'qs');
M_.endo_names_long = char(M_.endo_names_long, 'qs');
M_.endo_names = char(M_.endo_names, 'spinf');
M_.endo_names_tex = char(M_.endo_names_tex, 'spinf');
M_.endo_names_long = char(M_.endo_names_long, 'spinf');
M_.endo_names = char(M_.endo_names, 'sw');
M_.endo_names_tex = char(M_.endo_names_tex, 'sw');
M_.endo_names_long = char(M_.endo_names_long, 'sw');
M_.endo_names = char(M_.endo_names, 'kpf');
M_.endo_names_tex = char(M_.endo_names_tex, 'kpf');
M_.endo_names_long = char(M_.endo_names_long, 'kpf');
M_.endo_names = char(M_.endo_names, 'kp');
M_.endo_names_tex = char(M_.endo_names_tex, 'kp');
M_.endo_names_long = char(M_.endo_names_long, 'kp');
M_.endo_names = char(M_.endo_names, 'cf');
M_.endo_names_tex = char(M_.endo_names_tex, 'cf');
M_.endo_names_long = char(M_.endo_names_long, 'cf');
M_.endo_names = char(M_.endo_names, 'invef');
M_.endo_names_tex = char(M_.endo_names_tex, 'invef');
M_.endo_names_long = char(M_.endo_names_long, 'invef');
M_.endo_names = char(M_.endo_names, 'c');
M_.endo_names_tex = char(M_.endo_names_tex, 'c');
M_.endo_names_long = char(M_.endo_names_long, 'c');
M_.endo_names = char(M_.endo_names, 'inve');
M_.endo_names_tex = char(M_.endo_names_tex, 'inve');
M_.endo_names_long = char(M_.endo_names_long, 'inve');
M_.endo_names = char(M_.endo_names, 'w');
M_.endo_names_tex = char(M_.endo_names_tex, 'w');
M_.endo_names_long = char(M_.endo_names_long, 'w');
M_.endo_names = char(M_.endo_names, 'lab');
M_.endo_names_tex = char(M_.endo_names_tex, 'lab');
M_.endo_names_long = char(M_.endo_names_long, 'lab');
M_.endo_names = char(M_.endo_names, 'zcapf');
M_.endo_names_tex = char(M_.endo_names_tex, 'zcapf');
M_.endo_names_long = char(M_.endo_names_long, 'zcapf');
M_.endo_names = char(M_.endo_names, 'rkf');
M_.endo_names_tex = char(M_.endo_names_tex, 'rkf');
M_.endo_names_long = char(M_.endo_names_long, 'rkf');
M_.endo_names = char(M_.endo_names, 'kf');
M_.endo_names_tex = char(M_.endo_names_tex, 'kf');
M_.endo_names_long = char(M_.endo_names_long, 'kf');
M_.endo_names = char(M_.endo_names, 'pkf');
M_.endo_names_tex = char(M_.endo_names_tex, 'pkf');
M_.endo_names_long = char(M_.endo_names_long, 'pkf');
M_.endo_names = char(M_.endo_names, 'labf');
M_.endo_names_tex = char(M_.endo_names_tex, 'labf');
M_.endo_names_long = char(M_.endo_names_long, 'labf');
M_.endo_names = char(M_.endo_names, 'wf');
M_.endo_names_tex = char(M_.endo_names_tex, 'wf');
M_.endo_names_long = char(M_.endo_names_long, 'wf');
M_.endo_names = char(M_.endo_names, 'rrf');
M_.endo_names_tex = char(M_.endo_names_tex, 'rrf');
M_.endo_names_long = char(M_.endo_names_long, 'rrf');
M_.endo_names = char(M_.endo_names, 'mc');
M_.endo_names_tex = char(M_.endo_names_tex, 'mc');
M_.endo_names_long = char(M_.endo_names_long, 'mc');
M_.endo_names = char(M_.endo_names, 'zcap');
M_.endo_names_tex = char(M_.endo_names_tex, 'zcap');
M_.endo_names_long = char(M_.endo_names_long, 'zcap');
M_.endo_names = char(M_.endo_names, 'rk');
M_.endo_names_tex = char(M_.endo_names_tex, 'rk');
M_.endo_names_long = char(M_.endo_names_long, 'rk');
M_.endo_names = char(M_.endo_names, 'k');
M_.endo_names_tex = char(M_.endo_names_tex, 'k');
M_.endo_names_long = char(M_.endo_names_long, 'k');
M_.endo_names = char(M_.endo_names, 'pk');
M_.endo_names_tex = char(M_.endo_names_tex, 'pk');
M_.endo_names_long = char(M_.endo_names_long, 'pk');
M_.endo_partitions = struct();
M_.param_names = 'curvw';
M_.param_names_tex = 'curvw';
M_.param_names_long = 'curvw';
M_.param_names = char(M_.param_names, 'cgy');
M_.param_names_tex = char(M_.param_names_tex, 'cgy');
M_.param_names_long = char(M_.param_names_long, 'cgy');
M_.param_names = char(M_.param_names, 'curvp');
M_.param_names_tex = char(M_.param_names_tex, 'curvp');
M_.param_names_long = char(M_.param_names_long, 'curvp');
M_.param_names = char(M_.param_names, 'constelab');
M_.param_names_tex = char(M_.param_names_tex, 'constelab');
M_.param_names_long = char(M_.param_names_long, 'constelab');
M_.param_names = char(M_.param_names, 'constepinf');
M_.param_names_tex = char(M_.param_names_tex, 'constepinf');
M_.param_names_long = char(M_.param_names_long, 'constepinf');
M_.param_names = char(M_.param_names, 'constebeta');
M_.param_names_tex = char(M_.param_names_tex, 'constebeta');
M_.param_names_long = char(M_.param_names_long, 'constebeta');
M_.param_names = char(M_.param_names, 'cmaw');
M_.param_names_tex = char(M_.param_names_tex, 'cmaw');
M_.param_names_long = char(M_.param_names_long, 'cmaw');
M_.param_names = char(M_.param_names, 'cmap');
M_.param_names_tex = char(M_.param_names_tex, 'cmap');
M_.param_names_long = char(M_.param_names_long, 'cmap');
M_.param_names = char(M_.param_names, 'calfa');
M_.param_names_tex = char(M_.param_names_tex, 'calfa');
M_.param_names_long = char(M_.param_names_long, 'calfa');
M_.param_names = char(M_.param_names, 'czcap');
M_.param_names_tex = char(M_.param_names_tex, 'czcap');
M_.param_names_long = char(M_.param_names_long, 'czcap');
M_.param_names = char(M_.param_names, 'csadjcost');
M_.param_names_tex = char(M_.param_names_tex, 'csadjcost');
M_.param_names_long = char(M_.param_names_long, 'csadjcost');
M_.param_names = char(M_.param_names, 'ctou');
M_.param_names_tex = char(M_.param_names_tex, 'ctou');
M_.param_names_long = char(M_.param_names_long, 'ctou');
M_.param_names = char(M_.param_names, 'csigma');
M_.param_names_tex = char(M_.param_names_tex, 'csigma');
M_.param_names_long = char(M_.param_names_long, 'csigma');
M_.param_names = char(M_.param_names, 'chabb');
M_.param_names_tex = char(M_.param_names_tex, 'chabb');
M_.param_names_long = char(M_.param_names_long, 'chabb');
M_.param_names = char(M_.param_names, 'cfc');
M_.param_names_tex = char(M_.param_names_tex, 'cfc');
M_.param_names_long = char(M_.param_names_long, 'cfc');
M_.param_names = char(M_.param_names, 'cindw');
M_.param_names_tex = char(M_.param_names_tex, 'cindw');
M_.param_names_long = char(M_.param_names_long, 'cindw');
M_.param_names = char(M_.param_names, 'cprobw');
M_.param_names_tex = char(M_.param_names_tex, 'cprobw');
M_.param_names_long = char(M_.param_names_long, 'cprobw');
M_.param_names = char(M_.param_names, 'cindp');
M_.param_names_tex = char(M_.param_names_tex, 'cindp');
M_.param_names_long = char(M_.param_names_long, 'cindp');
M_.param_names = char(M_.param_names, 'cprobp');
M_.param_names_tex = char(M_.param_names_tex, 'cprobp');
M_.param_names_long = char(M_.param_names_long, 'cprobp');
M_.param_names = char(M_.param_names, 'csigl');
M_.param_names_tex = char(M_.param_names_tex, 'csigl');
M_.param_names_long = char(M_.param_names_long, 'csigl');
M_.param_names = char(M_.param_names, 'clandaw');
M_.param_names_tex = char(M_.param_names_tex, 'clandaw');
M_.param_names_long = char(M_.param_names_long, 'clandaw');
M_.param_names = char(M_.param_names, 'crpi');
M_.param_names_tex = char(M_.param_names_tex, 'crpi');
M_.param_names_long = char(M_.param_names_long, 'crpi');
M_.param_names = char(M_.param_names, 'crdy');
M_.param_names_tex = char(M_.param_names_tex, 'crdy');
M_.param_names_long = char(M_.param_names_long, 'crdy');
M_.param_names = char(M_.param_names, 'cry');
M_.param_names_tex = char(M_.param_names_tex, 'cry');
M_.param_names_long = char(M_.param_names_long, 'cry');
M_.param_names = char(M_.param_names, 'crr');
M_.param_names_tex = char(M_.param_names_tex, 'crr');
M_.param_names_long = char(M_.param_names_long, 'crr');
M_.param_names = char(M_.param_names, 'crhoa');
M_.param_names_tex = char(M_.param_names_tex, 'crhoa');
M_.param_names_long = char(M_.param_names_long, 'crhoa');
M_.param_names = char(M_.param_names, 'crhoas');
M_.param_names_tex = char(M_.param_names_tex, 'crhoas');
M_.param_names_long = char(M_.param_names_long, 'crhoas');
M_.param_names = char(M_.param_names, 'crhob');
M_.param_names_tex = char(M_.param_names_tex, 'crhob');
M_.param_names_long = char(M_.param_names_long, 'crhob');
M_.param_names = char(M_.param_names, 'crhog');
M_.param_names_tex = char(M_.param_names_tex, 'crhog');
M_.param_names_long = char(M_.param_names_long, 'crhog');
M_.param_names = char(M_.param_names, 'crhols');
M_.param_names_tex = char(M_.param_names_tex, 'crhols');
M_.param_names_long = char(M_.param_names_long, 'crhols');
M_.param_names = char(M_.param_names, 'crhoqs');
M_.param_names_tex = char(M_.param_names_tex, 'crhoqs');
M_.param_names_long = char(M_.param_names_long, 'crhoqs');
M_.param_names = char(M_.param_names, 'crhoms');
M_.param_names_tex = char(M_.param_names_tex, 'crhoms');
M_.param_names_long = char(M_.param_names_long, 'crhoms');
M_.param_names = char(M_.param_names, 'crhopinf');
M_.param_names_tex = char(M_.param_names_tex, 'crhopinf');
M_.param_names_long = char(M_.param_names_long, 'crhopinf');
M_.param_names = char(M_.param_names, 'crhow');
M_.param_names_tex = char(M_.param_names_tex, 'crhow');
M_.param_names_long = char(M_.param_names_long, 'crhow');
M_.param_names = char(M_.param_names, 'ctrend');
M_.param_names_tex = char(M_.param_names_tex, 'ctrend');
M_.param_names_long = char(M_.param_names_long, 'ctrend');
M_.param_names = char(M_.param_names, 'cg');
M_.param_names_tex = char(M_.param_names_tex, 'cg');
M_.param_names_long = char(M_.param_names_long, 'cg');
M_.param_names = char(M_.param_names, 'sigma_a');
M_.param_names_tex = char(M_.param_names_tex, 'sigma\_a');
M_.param_names_long = char(M_.param_names_long, 'sigma_a');
M_.param_names = char(M_.param_names, 'sigma_b');
M_.param_names_tex = char(M_.param_names_tex, 'sigma\_b');
M_.param_names_long = char(M_.param_names_long, 'sigma_b');
M_.param_names = char(M_.param_names, 'sigma_g');
M_.param_names_tex = char(M_.param_names_tex, 'sigma\_g');
M_.param_names_long = char(M_.param_names_long, 'sigma_g');
M_.param_names = char(M_.param_names, 'sigma_qs');
M_.param_names_tex = char(M_.param_names_tex, 'sigma\_qs');
M_.param_names_long = char(M_.param_names_long, 'sigma_qs');
M_.param_names = char(M_.param_names, 'sigma_m');
M_.param_names_tex = char(M_.param_names_tex, 'sigma\_m');
M_.param_names_long = char(M_.param_names_long, 'sigma_m');
M_.param_names = char(M_.param_names, 'sigma_pinf');
M_.param_names_tex = char(M_.param_names_tex, 'sigma\_pinf');
M_.param_names_long = char(M_.param_names_long, 'sigma_pinf');
M_.param_names = char(M_.param_names, 'sigma_w');
M_.param_names_tex = char(M_.param_names_tex, 'sigma\_w');
M_.param_names_long = char(M_.param_names_long, 'sigma_w');
M_.param_partitions = struct();
M_.exo_det_nbr = 0;
M_.exo_nbr = 7;
M_.endo_nbr = 33;
M_.param_nbr = 43;
M_.orig_endo_nbr = 33;
M_.aux_vars = [];
M_.Sigma_e = zeros(7, 7);
M_.Correlation_matrix = eye(7, 7);
M_.H = 0;
M_.Correlation_matrix_ME = 1;
M_.sigma_e_is_diagonal = 1;
M_.det_shocks = [];
options_.linear = 1;
options_.block=0;
options_.bytecode=0;
options_.use_dll=0;
M_.hessian_eq_zero = 1;
erase_compiled_function('SW_Model_sv_static');
erase_compiled_function('SW_Model_sv_dynamic');
M_.orig_eq_nbr = 33;
M_.eq_nbr = 33;
M_.ramsey_eq_nbr = 0;
M_.set_auxiliary_variables = exist(['./' M_.fname '_set_auxiliary_variables.m'], 'file') == 2;
M_.lead_lag_incidence = [
 1 21 0;
 2 22 54;
 3 23 0;
 4 24 0;
 5 25 0;
 6 26 0;
 7 27 0;
 8 28 0;
 9 29 0;
 10 30 0;
 11 31 0;
 12 32 0;
 13 33 0;
 14 34 0;
 15 35 0;
 16 36 55;
 17 37 56;
 18 38 57;
 19 39 58;
 20 40 59;
 0 41 60;
 0 42 0;
 0 43 61;
 0 44 0;
 0 45 62;
 0 46 63;
 0 47 0;
 0 48 0;
 0 49 0;
 0 50 0;
 0 51 64;
 0 52 0;
 0 53 65;]';
M_.nstatic = 7;
M_.nfwrd   = 6;
M_.npred   = 14;
M_.nboth   = 6;
M_.nsfwrd   = 12;
M_.nspred   = 20;
M_.ndynamic   = 26;
M_.equations_tags = {
};
M_.static_and_dynamic_models_differ = 0;
M_.exo_names_orig_ord = [1:7];
M_.maximum_lag = 1;
M_.maximum_lead = 1;
M_.maximum_endo_lag = 1;
M_.maximum_endo_lead = 1;
oo_.steady_state = zeros(33, 1);
M_.maximum_exo_lag = 0;
M_.maximum_exo_lead = 0;
oo_.exo_steady_state = zeros(7, 1);
M_.params = NaN(43, 1);
M_.NNZDerivatives = [142; -1; -1];
M_.params( 12 ) = .025;
ctou = M_.params( 12 );
M_.params( 21 ) = 1.5;
clandaw = M_.params( 21 );
M_.params( 36 ) = 0.18;
cg = M_.params( 36 );
M_.params( 3 ) = 10;
curvp = M_.params( 3 );
M_.params( 1 ) = 10;
curvw = M_.params( 1 );
M_.params( 9 ) = 0.2024;
calfa = M_.params( 9 );
cbeta	     = 0.9995;
M_.params( 13 ) = 1.2679;
csigma = M_.params( 13 );
M_.params( 15 ) = 1.6670;
cfc = M_.params( 15 );
M_.params( 2 ) = 0.5881;
cgy = M_.params( 2 );
M_.params( 11 ) = 6.3144;
csadjcost = M_.params( 11 );
M_.params( 14 ) = 0.8056;
chabb = M_.params( 14 );
M_.params( 17 ) = 0.7668;
cprobw = M_.params( 17 );
M_.params( 20 ) = 2.5201;
csigl = M_.params( 20 );
M_.params( 19 ) = 0.5304;
cprobp = M_.params( 19 );
M_.params( 16 ) = 0.5345;
cindw = M_.params( 16 );
M_.params( 18 ) = 0.1779;
cindp = M_.params( 18 );
M_.params( 10 ) = 0.3597;
czcap = M_.params( 10 );
M_.params( 22 ) = 1.8685;
crpi = M_.params( 22 );
M_.params( 25 ) = 0.8739;
crr = M_.params( 25 );
M_.params( 24 ) = 0.1203;
cry = M_.params( 24 );
M_.params( 23 ) = 0.1282;
crdy = M_.params( 23 );
M_.params( 26 ) = 0.9826;
crhoa = M_.params( 26 );
M_.params( 28 ) = 0.1391;
crhob = M_.params( 28 );
M_.params( 29 ) = 0.9686;
crhog = M_.params( 29 );
M_.params( 30 ) = 0.9928;
crhols = M_.params( 30 );
M_.params( 31 ) = 0.6121;
crhoqs = M_.params( 31 );
M_.params( 27 ) = 1;
crhoas = M_.params( 27 );
M_.params( 32 ) = 0;
crhoms = M_.params( 32 );
M_.params( 33 ) = 0.9856;
crhopinf = M_.params( 33 );
M_.params( 34 ) = 0.9818;
crhow = M_.params( 34 );
M_.params( 8 ) = 0.8340;
cmap = M_.params( 8 );
M_.params( 7 ) = 0.9337;
cmaw = M_.params( 7 );
M_.params( 4 ) = 1.3263;
constelab = M_.params( 4 );
M_.params( 5 ) = 0.6365;
constepinf = M_.params( 5 );
M_.params( 6 ) = 0.1126;
constebeta = M_.params( 6 );
M_.params( 35 ) = 0.5113;
ctrend = M_.params( 35 );
M_.params( 37 ) = 0.5017;
sigma_a = M_.params( 37 );
M_.params( 38 ) = 0.3583;
sigma_b = M_.params( 38 );
M_.params( 39 ) = 0.6752;
sigma_g = M_.params( 39 );
M_.params( 40 ) = 0.5678;
sigma_qs = M_.params( 40 );
M_.params( 41 ) = 0.2290;
sigma_m = M_.params( 41 );
M_.params( 42 ) = 0.2181;
sigma_pinf = M_.params( 42 );
M_.params( 43 ) = 0.2663;
sigma_w = M_.params( 43 );
%
% SHOCKS instructions
%
M_.exo_det_length = 0;
M_.Sigma_e(1, 1) = (1)^2;
M_.Sigma_e(2, 2) = (1)^2;
M_.Sigma_e(3, 3) = (1)^2;
M_.Sigma_e(4, 4) = (1)^2;
M_.Sigma_e(5, 5) = (1)^2;
M_.Sigma_e(6, 6) = (1)^2;
M_.Sigma_e(7, 7) = (1)^2;
options_.irf = 49;
options_.nograph = 1;
options_.order = 1;
options_.periods = 1000;
options_.simul_replic = 100;
var_list_ = char();
info = stoch_simul(var_list_);

y0=oo_.dr.ys; 
dr=oo_.dr; 
iorder=1; 

sigma_(1) = 0.2290;
sigma_(2) = 0.5017;
sigma_(3) = 0.3583;
sigma_(4) = 0.6752;
sigma_(5) = 0.5678;
sigma_(6) = 0.2181;
sigma_(7) = 0.2663;

load simulated_shocks;

for i = 1: n_sims
%     seed=rng(i+100);
%     ex_ = mvnrnd(zeros(7,1),diag(sigma_),1000);
    ex_= simulated_shocks(:,:,i);
    y_=simult_(y0,dr,ex_,iorder);

    y_sim(:,i)=y_(1,2:end)';
    pie_sim(:,i)=y_(2,2:end)';
    r_sim(:,i)=y_(3,2:end)';
    ms_sim(:,i)=y_(4,2:end)';
end

% save('SW_Model_sv_results.mat', 'oo_', 'M_', 'options_');
% if exist('estim_params_', 'var') == 1
%   save('SW_Model_sv_results.mat', 'estim_params_', '-append');
% end
% if exist('bayestopt_', 'var') == 1
%   save('SW_Model_sv_results.mat', 'bayestopt_', '-append');
% end
% if exist('dataset_', 'var') == 1
%   save('SW_Model_sv_results.mat', 'dataset_', '-append');
% end
% if exist('estimation_info', 'var') == 1
%   save('SW_Model_sv_results.mat', 'estimation_info', '-append');
% end
% if exist('dataset_info', 'var') == 1
%   save('SW_Model_sv_results.mat', 'dataset_info', '-append');
% end
% if exist('oo_recursive_', 'var') == 1
%   save('SW_Model_sv_results.mat', 'oo_recursive_', '-append');
% end
% 
% 
% disp(['Total computing time : ' dynsec2hms(toc(tic0)) ]);
% if ~isempty(lastwarn)
%   disp('Note: warning(s) encountered in MATLAB/Octave code')
% end

% clearvars -except y_sim pie_sim r_sim ms_sim;

diary off
