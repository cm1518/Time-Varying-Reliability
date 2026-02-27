function [residual, g1, g2, g3] = SW_Model_static(y, x, params)
%
% Status : Computes static model for Dynare
%
% Inputs : 
%   y         [M_.endo_nbr by 1] double    vector of endogenous variables in declaration order
%   x         [M_.exo_nbr by 1] double     vector of exogenous variables in declaration order
%   params    [M_.param_nbr by 1] double   vector of parameter values in declaration order
%
% Outputs:
%   residual  [M_.endo_nbr by 1] double    vector of residuals of the static model equations 
%                                          in order of declaration of the equations.
%                                          Dynare may prepend or append auxiliary equations, see M_.aux_vars
%   g1        [M_.endo_nbr by M_.endo_nbr] double    Jacobian matrix of the static model equations;
%                                                       columns: variables in declaration order
%                                                       rows: equations in order of declaration
%   g2        [M_.endo_nbr by (M_.endo_nbr)^2] double   Hessian matrix of the static model equations;
%                                                       columns: variables in declaration order
%                                                       rows: equations in order of declaration
%   g3        [M_.endo_nbr by (M_.endo_nbr)^3] double   Third derivatives matrix of the static model equations;
%                                                       columns: variables in declaration order
%                                                       rows: equations in order of declaration
%
%
% Warning : this file is generated automatically by Dynare
%           from model file (.mod)

residual = zeros( 33, 1);

%
% Model equations
%

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
T87 = 1/(params(10)/(1-params(10)));
T102 = 1/(1+cgamma__*cbetabar__);
T105 = cgamma__^2;
T107 = T105*params(11);
T120 = params(14)/cgamma__;
T124 = (1-T120)/(params(13)*(1+T120));
T132 = (1-params(12))/(1-params(12)+crk__);
T249 = 1/(1+cgamma__*cbetabar__*params(18));
T263 = (1-params(19))*(1-cgamma__*cbetabar__*params(19))/params(19)/(1+(params(15)-1)*params(3));
T271 = cgamma__*cbetabar__/(1+cgamma__*cbetabar__);
T297 = (1-params(17))*(1-cgamma__*cbetabar__*params(17))/((1+cgamma__*cbetabar__)*params(17))*1/(1+(params(21)-1)*params(1));
lhs =y(8);
rhs =params(9)*y(23)+(1-params(9))*y(27);
residual(1)= lhs-rhs;
lhs =y(22);
rhs =y(23)*T87;
residual(2)= lhs-rhs;
lhs =y(23);
rhs =y(27)+y(26)-y(24);
residual(3)= lhs-rhs;
lhs =y(24);
rhs =y(22)+y(14);
residual(4)= lhs-rhs;
lhs =y(17);
rhs =T102*(y(17)+y(17)*cgamma__*cbetabar__+1/T107*y(25))+y(11);
residual(5)= lhs-rhs;
lhs =y(25);
rhs =(-y(28))+y(9)*1/T124+y(23)*crk__/(1-params(12)+crk__)+y(25)*T132;
residual(6)= lhs-rhs;
lhs =y(16);
rhs =y(9)+y(16)*T120/(1+T120)+y(16)*1/(1+T120)-y(28)*T124;
residual(7)= lhs-rhs;
lhs =y(7);
rhs =ccy__*y(16)+y(17)*ciy__+y(10)+y(22)*crkky__;
residual(8)= lhs-rhs;
lhs =y(7);
rhs =params(15)*(y(8)+params(9)*y(24)+(1-params(9))*y(26));
residual(9)= lhs-rhs;
lhs =y(27);
rhs =y(26)*params(20)+y(16)*1/(1-T120)-y(16)*T120/(1-T120);
residual(10)= lhs-rhs;
lhs =y(14);
rhs =y(14)*(1-cikbar__)+y(17)*cikbar__+y(11)*T107*cikbar__;
residual(11)= lhs-rhs;
lhs =y(29);
rhs =params(9)*y(31)+(1-params(9))*y(20)-y(8);
residual(12)= lhs-rhs;
lhs =y(30);
rhs =T87*y(31);
residual(13)= lhs-rhs;
lhs =y(31);
rhs =y(20)+y(21)-y(32);
residual(14)= lhs-rhs;
lhs =y(32);
rhs =y(30)+y(15);
residual(15)= lhs-rhs;
lhs =y(19);
rhs =y(11)+T102*(y(19)+cgamma__*cbetabar__*y(19)+1/T107*y(33));
residual(16)= lhs-rhs;
lhs =y(33);
rhs =y(9)*1/T124+(-y(3))+y(2)+crk__/(1-params(12)+crk__)*y(31)+T132*y(33);
residual(17)= lhs-rhs;
lhs =y(18);
rhs =y(9)+T120/(1+T120)*y(18)+1/(1+T120)*y(18)-T124*(y(3)-y(2));
residual(18)= lhs-rhs;
lhs =y(1);
rhs =y(10)+ccy__*y(18)+ciy__*y(19)+crkky__*y(30);
residual(19)= lhs-rhs;
lhs =y(1);
rhs =params(15)*(y(8)+params(9)*y(32)+(1-params(9))*y(21));
residual(20)= lhs-rhs;
lhs =y(2);
rhs =T249*(cgamma__*cbetabar__*y(2)+y(2)*params(18)+y(29)*T263)+y(12);
residual(21)= lhs-rhs;
lhs =y(20);
rhs =T102*y(20)+y(20)*T271+y(2)*params(16)/(1+cgamma__*cbetabar__)-y(2)*(1+cgamma__*cbetabar__*params(16))/(1+cgamma__*cbetabar__)+y(2)*T271+T297*(params(20)*y(21)+1/(1-T120)*y(18)-T120/(1-T120)*y(18)-y(20))+y(13);
residual(22)= lhs-rhs;
lhs =y(3);
rhs =y(2)*params(22)*(1-params(25))+(1-params(25))*params(24)*(y(1)-y(7))+params(23)*(y(7)+y(1)-y(7)-y(1))+y(3)*params(25)+y(4);
residual(23)= lhs-rhs;
lhs =y(8);
rhs =y(8)*params(26)+params(37)*x(2);
residual(24)= lhs-rhs;
lhs =y(9);
rhs =y(9)*params(28)+params(38)*x(3);
residual(25)= lhs-rhs;
lhs =y(10);
rhs =y(10)*params(29)+params(39)*x(4)+x(2)*params(37)*params(2);
residual(26)= lhs-rhs;
lhs =y(11);
rhs =y(11)*params(31)+params(40)*x(5);
residual(27)= lhs-rhs;
lhs =y(4);
rhs =y(4)*params(32)+params(41)*x(1);
residual(28)= lhs-rhs;
lhs =y(12);
rhs =y(12)*params(33)+y(6)-y(6)*params(8);
residual(29)= lhs-rhs;
lhs =y(6);
rhs =params(42)*x(6);
residual(30)= lhs-rhs;
lhs =y(13);
rhs =y(13)*params(34)+y(5)-y(5)*params(7);
residual(31)= lhs-rhs;
lhs =y(5);
rhs =params(43)*x(7);
residual(32)= lhs-rhs;
lhs =y(15);
rhs =(1-cikbar__)*y(15)+cikbar__*y(19)+y(11)*params(11)*T105*cikbar__;
residual(33)= lhs-rhs;
if ~isreal(residual)
  residual = real(residual)+imag(residual).^2;
end
if nargout >= 2,
  g1 = zeros(33, 33);

  %
  % Jacobian matrix
  %

T426 = 1-(T120/(1+T120)+1/(1+T120));
T428 = 1/(1-T120)-T120/(1-T120);
  g1(1,8)=1;
  g1(1,23)=(-params(9));
  g1(1,27)=(-(1-params(9)));
  g1(2,22)=1;
  g1(2,23)=(-T87);
  g1(3,23)=1;
  g1(3,24)=1;
  g1(3,26)=(-1);
  g1(3,27)=(-1);
  g1(4,14)=(-1);
  g1(4,22)=(-1);
  g1(4,24)=1;
  g1(5,11)=(-1);
  g1(5,17)=1-(1+cgamma__*cbetabar__)*T102;
  g1(5,25)=(-(T102*1/T107));
  g1(6,9)=(-(1/T124));
  g1(6,23)=(-(crk__/(1-params(12)+crk__)));
  g1(6,25)=1-T132;
  g1(6,28)=1;
  g1(7,9)=(-1);
  g1(7,16)=T426;
  g1(7,28)=T124;
  g1(8,7)=1;
  g1(8,10)=(-1);
  g1(8,16)=(-ccy__);
  g1(8,17)=(-ciy__);
  g1(8,22)=(-crkky__);
  g1(9,7)=1;
  g1(9,8)=(-params(15));
  g1(9,24)=(-(params(15)*params(9)));
  g1(9,26)=(-(params(15)*(1-params(9))));
  g1(10,16)=(-T428);
  g1(10,26)=(-params(20));
  g1(10,27)=1;
  g1(11,11)=(-(T107*cikbar__));
  g1(11,14)=1-(1-cikbar__);
  g1(11,17)=(-cikbar__);
  g1(12,8)=1;
  g1(12,20)=(-(1-params(9)));
  g1(12,29)=1;
  g1(12,31)=(-params(9));
  g1(13,30)=1;
  g1(13,31)=(-T87);
  g1(14,20)=(-1);
  g1(14,21)=(-1);
  g1(14,31)=1;
  g1(14,32)=1;
  g1(15,15)=(-1);
  g1(15,30)=(-1);
  g1(15,32)=1;
  g1(16,11)=(-1);
  g1(16,19)=1-(1+cgamma__*cbetabar__)*T102;
  g1(16,33)=(-(T102*1/T107));
  g1(17,2)=(-1);
  g1(17,3)=1;
  g1(17,9)=(-(1/T124));
  g1(17,31)=(-(crk__/(1-params(12)+crk__)));
  g1(17,33)=1-T132;
  g1(18,2)=(-T124);
  g1(18,3)=T124;
  g1(18,9)=(-1);
  g1(18,18)=T426;
  g1(19,1)=1;
  g1(19,10)=(-1);
  g1(19,18)=(-ccy__);
  g1(19,19)=(-ciy__);
  g1(19,30)=(-crkky__);
  g1(20,1)=1;
  g1(20,8)=(-params(15));
  g1(20,21)=(-(params(15)*(1-params(9))));
  g1(20,32)=(-(params(15)*params(9)));
  g1(21,2)=1-T249*(cgamma__*cbetabar__+params(18));
  g1(21,12)=(-1);
  g1(21,29)=(-(T249*T263));
  g1(22,2)=(-(T271+params(16)/(1+cgamma__*cbetabar__)-(1+cgamma__*cbetabar__*params(16))/(1+cgamma__*cbetabar__)));
  g1(22,13)=(-1);
  g1(22,18)=(-(T297*T428));
  g1(22,20)=1-(T102+T271-T297);
  g1(22,21)=(-(params(20)*T297));
  g1(23,1)=(-((1-params(25))*params(24)));
  g1(23,2)=(-(params(22)*(1-params(25))));
  g1(23,3)=1-params(25);
  g1(23,4)=(-1);
  g1(23,7)=(1-params(25))*params(24);
  g1(24,8)=1-params(26);
  g1(25,9)=1-params(28);
  g1(26,10)=1-params(29);
  g1(27,11)=1-params(31);
  g1(28,4)=1-params(32);
  g1(29,6)=(-(1-params(8)));
  g1(29,12)=1-params(33);
  g1(30,6)=1;
  g1(31,5)=(-(1-params(7)));
  g1(31,13)=1-params(34);
  g1(32,5)=1;
  g1(33,11)=(-(params(11)*T105*cikbar__));
  g1(33,15)=1-(1-cikbar__);
  g1(33,19)=(-cikbar__);
  if ~isreal(g1)
    g1 = real(g1)+2*imag(g1);
  end
if nargout >= 3,
  %
  % Hessian matrix
  %

  g2 = sparse([],[],[],33,1089);
if nargout >= 4,
  %
  % Third order derivatives
  %

  g3 = sparse([],[],[],33,35937);
end
end
end
end
