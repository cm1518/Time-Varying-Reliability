function x = rhalfcauchy(n,phi)
% generate n random draws from hallf-cauchy distribution with scale parameter phi
% translated from R toolbox "LaplacesDemon"

if phi<=0
    error('the scale parameter must be positive')
end;


p = rand(n,1);
x = phi*tan(pi*p/2);

