%function [lb,ub]=prior_bounds(options_global,options_kappa)
function [lb,ub]=prior_bounds(options_)
% determine endogenously the lower and upperbound of the prior density for
% given parameterization. modelled after the dynare function "prior_bounds"
%prior_trunc = options_global.prior_trunc;
prior_trunc = sqrt(eps);
options_global.hard_lb =1e-5;

switch options_.prior
    
    case 'fixed'
        lb=NaN;
        ub=NaN;
    
    case 'inv-gamma' % inverse gamma (scaled-inverse-chi2 specification)
        a=options_.nu/2;
        b=options_.scale^2*options_.nu/2;
        lb=1e-5;
        ub=1/gaminv(1-(1-prior_trunc),a,b);
        %ub=b/(a+1)*500;
    case 'half-cauchy'
        lb=options_global.hard_lb;
        ub=qhalfcauchy(1-prior_trunc,options_kappa.scale);
    case 'half-t' 
        % using half-cauchy specification due to the difficulty 
        % of evaluating half-t quantile function
        lb=options_global.hard_lb;
        ub=qhalfcauchy(1-prior_trunc,options_kappa.scale);
    case 'uniform'
        lb=options_kappa.lower_bound;
        ub=options_kappa.upper_bound;
        
end;