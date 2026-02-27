function ldens=dhalfcauchy(x,phi)
% evaluate half-cauchy (log) density with scale parameter phi
% translated from R toolbox "LaplacesDemon"

if phi<=0
    error('the scale parameter must be positive')
end;

ldens =log(2*phi)-log(pi*(x.^2+phi^2));

