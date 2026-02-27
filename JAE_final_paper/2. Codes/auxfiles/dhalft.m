function ldens=dhalft(x,scale,nu);
% evaluate half-t (log) density with scale parameter and degree of freedom
% nu
% translated from R toolbox "LaplacesDemon"

ldens = (-(nu+1)/2).*log(1 + (1/nu).*(x./scale).*(x./scale));

