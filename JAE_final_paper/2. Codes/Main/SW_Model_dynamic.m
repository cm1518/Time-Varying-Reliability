function [residual, g1, g2, g3] = SW_Model_dynamic(y, x, params, steady_state, it_)
%
% Status : Computes dynamic model for Dynare
%
% Inputs :
%   y         [#dynamic variables by 1] double    vector of endogenous variables in the order stored
%                                                 in M_.lead_lag_incidence; see the Manual
%   x         [nperiods by M_.exo_nbr] double     matrix of exogenous variables (in declaration order)
%                                                 for all simulation periods
%   steady_state  [M_.endo_nbr by 1] double       vector of steady state values
%   params    [M_.param_nbr by 1] double          vector of parameter values in declaration order
%   it_       scalar double                       time period for exogenous variables for which to evaluate the model
%
% Outputs:
%   residual  [M_.endo_nbr by 1] double    vector of residuals of the dynamic model equations in order of 
%                                          declaration of the equations.
%                                          Dynare may prepend auxiliary equations, see M_.aux_vars
%   g1        [M_.endo_nbr by #dynamic variables] double    Jacobian matrix of the dynamic model equations;
%                                                           rows: equations in order of declaration
%                                                           columns: variables in order stored in M_.lead_lag_incidence followed by the ones in M_.exo_names
%   g2        [M_.endo_nbr by (#dynamic variables)^2] double   Hessian matrix of the dynamic model equations;
%                                                              rows: equations in order of declaration
%                                                              columns: variables in order stored in M_.lead_lag_incidence followed by the ones in M_.exo_names
%   g3        [M_.endo_nbr by (#dynamic variables)^3] double   Third order derivative matrix of the dynamic model equations;
%                                                              rows: equations in order of declaration
%                                                              columns: variables in order stored in M_.lead_lag_incidence followed by the ones in M_.exo_names
%
%
% Warning : this file is generated automatically by Dynare
%           from model file (.mod)

%
% Model equations
%

residual = zeros(33, 1);
cgamma__ = 1+params(35)/100;
cbeta__ = 1/(1+params(6)/100);
clandap__ = params(15);
cbetabar__ = cbeta__*cgamma__^(-params(13));
crk__ = cbeta__^(-1)*cgamma__^params(13)-(1-params(12));
cw__ = (params(9)^params(9)*(1-params(9))^(1-params(9))/(clandap__*crk__^params(9)))^(1/(1-params(9)));
cikbar__ = 1-(1-params(12))/cgamma__;
cik__ = cgamma__*(1-(1-params(12))/cgamma__);
clk__ = (1-params(9))/params(9)*crk__/cw__;
cky__ = params(15)*clk__^(params(9)-1);
ciy__ = cik__*cky__;
ccy__ = 1-params(36)-cik__*cky__;
crkky__ = crk__*cky__;
cwhlc__ = cky__*crk__*(1-params(9))*1/params(21)/params(9)/ccy__;
T87 = 1/(params(10)/(1-params(10)));
T102 = 1/(1+cgamma__*cbetabar__);
T107 = cgamma__^2;
T109 = T107*params(11);
T122 = params(14)/cgamma__;
T126 = (1-T122)/(params(13)*(1+T122));
T135 = (1-params(12))/(1-params(12)+crk__);
T151 = (params(13)-1)*cwhlc__/(params(13)*(1+T122));
T179 = 1/(1-T122);
T182 = T122/(1-T122);
T271 = 1/(1+cgamma__*cbetabar__*params(18));
T286 = (1-params(19))*(1-cgamma__*cbetabar__*params(19))/params(19)/(1+(params(15)-1)*params(3));
T295 = cgamma__*cbetabar__/(1+cgamma__*cbetabar__);
T322 = (1-params(17))*(1-cgamma__*cbetabar__*params(17))/((1+cgamma__*cbetabar__)*params(17))*1/(1+(params(21)-1)*params(1));
lhs =y(28);
rhs =params(9)*y(43)+(1-params(9))*y(47);
residual(1)= lhs-rhs;
lhs =y(42);
rhs =y(43)*T87;
residual(2)= lhs-rhs;
lhs =y(43);
rhs =y(47)+y(46)-y(44);
residual(3)= lhs-rhs;
lhs =y(44);
rhs =y(42)+y(14);
residual(4)= lhs-rhs;
lhs =y(37);
rhs =T102*(y(17)+cgamma__*cbetabar__*y(56)+1/T109*y(45))+y(31);
residual(5)= lhs-rhs;
lhs =y(45);
rhs =(-y(48))+y(29)*1/T126+crk__/(1-params(12)+crk__)*y(61)+T135*y(62);
residual(6)= lhs-rhs;
lhs =y(36);
rhs =y(29)+T122/(1+T122)*y(16)+1/(1+T122)*y(55)+T151*(y(46)-y(63))-y(48)*T126;
residual(7)= lhs-rhs;
lhs =y(27);
rhs =ccy__*y(36)+y(37)*ciy__+y(30)+y(42)*crkky__;
residual(8)= lhs-rhs;
lhs =y(27);
rhs =params(15)*(y(28)+params(9)*y(44)+(1-params(9))*y(46));
residual(9)= lhs-rhs;
lhs =y(47);
rhs =y(46)*params(20)+y(36)*T179-y(16)*T182;
residual(10)= lhs-rhs;
lhs =y(34);
rhs =y(14)*(1-cikbar__)+y(37)*cikbar__+y(31)*T109*cikbar__;
residual(11)= lhs-rhs;
lhs =y(49);
rhs =params(9)*y(51)+(1-params(9))*y(40)-y(28);
residual(12)= lhs-rhs;
lhs =y(50);
rhs =T87*y(51);
residual(13)= lhs-rhs;
lhs =y(51);
rhs =y(40)+y(41)-y(52);
residual(14)= lhs-rhs;
lhs =y(52);
rhs =y(50)+y(15);
residual(15)= lhs-rhs;
lhs =y(39);
rhs =y(31)+T102*(y(19)+cgamma__*cbetabar__*y(58)+1/T109*y(53));
residual(16)= lhs-rhs;
lhs =y(53);
rhs =y(29)*1/T126+(-y(23))+y(54)+crk__/(1-params(12)+crk__)*y(64)+T135*y(65);
residual(17)= lhs-rhs;
lhs =y(38);
rhs =y(29)+T122/(1+T122)*y(18)+1/(1+T122)*y(57)+T151*(y(41)-y(60))-T126*(y(23)-y(54));
residual(18)= lhs-rhs;
lhs =y(21);
rhs =y(30)+ccy__*y(38)+ciy__*y(39)+crkky__*y(50);
residual(19)= lhs-rhs;
lhs =y(21);
rhs =params(15)*(y(28)+params(9)*y(52)+(1-params(9))*y(41));
residual(20)= lhs-rhs;
lhs =y(22);
rhs =T271*(cgamma__*cbetabar__*y(54)+params(18)*y(2)+y(49)*T286)+y(32);
residual(21)= lhs-rhs;
lhs =y(40);
rhs =T102*y(20)+T295*y(59)+y(2)*params(16)/(1+cgamma__*cbetabar__)-y(22)*(1+cgamma__*cbetabar__*params(16))/(1+cgamma__*cbetabar__)+y(54)*T295+T322*(params(20)*y(41)+T179*y(38)-T182*y(18)-y(40))+y(33);
residual(22)= lhs-rhs;
lhs =y(23);
rhs =y(22)*params(22)*(1-params(25))+(1-params(25))*params(24)*(y(21)-y(27))+params(23)*(y(21)-y(27)-y(1)+y(7))+params(25)*y(3)+y(24);
residual(23)= lhs-rhs;
lhs =y(28);
rhs =params(26)*y(8)+params(37)*x(it_, 2);
residual(24)= lhs-rhs;
lhs =y(29);
rhs =params(28)*y(9)+params(38)*x(it_, 3);
residual(25)= lhs-rhs;
lhs =y(30);
rhs =params(29)*y(10)+params(39)*x(it_, 4)+x(it_, 2)*params(37)*params(2);
residual(26)= lhs-rhs;
lhs =y(31);
rhs =params(31)*y(11)+params(40)*x(it_, 5);
residual(27)= lhs-rhs;
lhs =y(24);
rhs =params(32)*y(4)+params(41)*x(it_, 1);
residual(28)= lhs-rhs;
lhs =y(32);
rhs =params(33)*y(12)+y(26)-params(8)*y(6);
residual(29)= lhs-rhs;
lhs =y(26);
rhs =params(42)*x(it_, 6);
residual(30)= lhs-rhs;
lhs =y(33);
rhs =params(34)*y(13)+y(25)-params(7)*y(5);
residual(31)= lhs-rhs;
lhs =y(25);
rhs =params(43)*x(it_, 7);
residual(32)= lhs-rhs;
lhs =y(35);
rhs =(1-cikbar__)*y(15)+cikbar__*y(39)+y(31)*params(11)*T107*cikbar__;
residual(33)= lhs-rhs;
if nargout >= 2,
  g1 = zeros(33, 72);

  %
  % Jacobian matrix
  %

  g1(1,28)=1;
  g1(1,43)=(-params(9));
  g1(1,47)=(-(1-params(9)));
  g1(2,42)=1;
  g1(2,43)=(-T87);
  g1(3,43)=1;
  g1(3,44)=1;
  g1(3,46)=(-1);
  g1(3,47)=(-1);
  g1(4,14)=(-1);
  g1(4,42)=(-1);
  g1(4,44)=1;
  g1(5,31)=(-1);
  g1(5,17)=(-T102);
  g1(5,37)=1;
  g1(5,56)=(-(cgamma__*cbetabar__*T102));
  g1(5,45)=(-(T102*1/T109));
  g1(6,29)=(-(1/T126));
  g1(6,61)=(-(crk__/(1-params(12)+crk__)));
  g1(6,45)=1;
  g1(6,62)=(-T135);
  g1(6,48)=1;
  g1(7,29)=(-1);
  g1(7,16)=(-(T122/(1+T122)));
  g1(7,36)=1;
  g1(7,55)=(-(1/(1+T122)));
  g1(7,46)=(-T151);
  g1(7,63)=T151;
  g1(7,48)=T126;
  g1(8,27)=1;
  g1(8,30)=(-1);
  g1(8,36)=(-ccy__);
  g1(8,37)=(-ciy__);
  g1(8,42)=(-crkky__);
  g1(9,27)=1;
  g1(9,28)=(-params(15));
  g1(9,44)=(-(params(15)*params(9)));
  g1(9,46)=(-(params(15)*(1-params(9))));
  g1(10,16)=T182;
  g1(10,36)=(-T179);
  g1(10,46)=(-params(20));
  g1(10,47)=1;
  g1(11,31)=(-(T109*cikbar__));
  g1(11,14)=(-(1-cikbar__));
  g1(11,34)=1;
  g1(11,37)=(-cikbar__);
  g1(12,28)=1;
  g1(12,40)=(-(1-params(9)));
  g1(12,49)=1;
  g1(12,51)=(-params(9));
  g1(13,50)=1;
  g1(13,51)=(-T87);
  g1(14,40)=(-1);
  g1(14,41)=(-1);
  g1(14,51)=1;
  g1(14,52)=1;
  g1(15,15)=(-1);
  g1(15,50)=(-1);
  g1(15,52)=1;
  g1(16,31)=(-1);
  g1(16,19)=(-T102);
  g1(16,39)=1;
  g1(16,58)=(-(cgamma__*cbetabar__*T102));
  g1(16,53)=(-(T102*1/T109));
  g1(17,54)=(-1);
  g1(17,23)=1;
  g1(17,29)=(-(1/T126));
  g1(17,64)=(-(crk__/(1-params(12)+crk__)));
  g1(17,53)=1;
  g1(17,65)=(-T135);
  g1(18,54)=(-T126);
  g1(18,23)=T126;
  g1(18,29)=(-1);
  g1(18,18)=(-(T122/(1+T122)));
  g1(18,38)=1;
  g1(18,57)=(-(1/(1+T122)));
  g1(18,41)=(-T151);
  g1(18,60)=T151;
  g1(19,21)=1;
  g1(19,30)=(-1);
  g1(19,38)=(-ccy__);
  g1(19,39)=(-ciy__);
  g1(19,50)=(-crkky__);
  g1(20,21)=1;
  g1(20,28)=(-params(15));
  g1(20,41)=(-(params(15)*(1-params(9))));
  g1(20,52)=(-(params(15)*params(9)));
  g1(21,2)=(-(params(18)*T271));
  g1(21,22)=1;
  g1(21,54)=(-(cgamma__*cbetabar__*T271));
  g1(21,32)=(-1);
  g1(21,49)=(-(T271*T286));
  g1(22,2)=(-(params(16)/(1+cgamma__*cbetabar__)));
  g1(22,22)=(1+cgamma__*cbetabar__*params(16))/(1+cgamma__*cbetabar__);
  g1(22,54)=(-T295);
  g1(22,33)=(-1);
  g1(22,18)=(-(T322*(-T182)));
  g1(22,38)=(-(T179*T322));
  g1(22,20)=(-T102);
  g1(22,40)=1-(-T322);
  g1(22,59)=(-T295);
  g1(22,41)=(-(params(20)*T322));
  g1(23,1)=params(23);
  g1(23,21)=(-((1-params(25))*params(24)+params(23)));
  g1(23,22)=(-(params(22)*(1-params(25))));
  g1(23,3)=(-params(25));
  g1(23,23)=1;
  g1(23,24)=(-1);
  g1(23,7)=(-params(23));
  g1(23,27)=(-((-((1-params(25))*params(24)))-params(23)));
  g1(24,8)=(-params(26));
  g1(24,28)=1;
  g1(24,67)=(-params(37));
  g1(25,9)=(-params(28));
  g1(25,29)=1;
  g1(25,68)=(-params(38));
  g1(26,10)=(-params(29));
  g1(26,30)=1;
  g1(26,67)=(-(params(37)*params(2)));
  g1(26,69)=(-params(39));
  g1(27,11)=(-params(31));
  g1(27,31)=1;
  g1(27,70)=(-params(40));
  g1(28,4)=(-params(32));
  g1(28,24)=1;
  g1(28,66)=(-params(41));
  g1(29,6)=params(8);
  g1(29,26)=(-1);
  g1(29,12)=(-params(33));
  g1(29,32)=1;
  g1(30,26)=1;
  g1(30,71)=(-params(42));
  g1(31,5)=params(7);
  g1(31,25)=(-1);
  g1(31,13)=(-params(34));
  g1(31,33)=1;
  g1(32,25)=1;
  g1(32,72)=(-params(43));
  g1(33,31)=(-(params(11)*T107*cikbar__));
  g1(33,15)=(-(1-cikbar__));
  g1(33,35)=1;
  g1(33,39)=(-cikbar__);

if nargout >= 3,
  %
  % Hessian matrix
  %

  g2 = sparse([],[],[],33,5184);
if nargout >= 4,
  %
  % Third order derivatives
  %

  g3 = sparse([],[],[],33,373248);
end
end
end
end
