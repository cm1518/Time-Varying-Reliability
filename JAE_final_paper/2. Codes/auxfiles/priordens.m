function lpriordens=priordens(x,options_)

switch options_.prior
    
    case 'inv-gamma' % inverse gamma (scaled-inverse-chi2 specification)
       % a=options_.df/2;
       % b=options_.scale*a;
        lpriordens=linv_gam_pdf (x, options_.nu/2,options_.scale^2*options_.nu/2);
    case 'half-cauchy'
        % no moments exist
        lpriordens=dhalfcauchy(x,options_.nu);
    case 'half-t'
        lpriordens=dhalft(x,options_.scale^2,options_.nu);
    case 'uniform'
        n=length(x);
        lpriordens=-log(options_.upper_bound-options_.lower_bound)*n;
        
end;