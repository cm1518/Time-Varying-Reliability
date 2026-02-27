function [posterior_mean, posterior_covariance] = bayesian_linear_regression_posterior(X, y, prior_mean, prior_covariance, sigma2)

    % X is the design matrix of predictors with size n-by-p (n samples, p predictors)

    % y is the response vector with size n-by-1

    % prior_mean is the mean vector of the prior distribution with size p-by-1

    % prior_covariance is the covariance matrix of the prior distribution with size p-by-p

    % sigma2 is the variance of the Gaussian likelihood (assumed known)



    % Check if the prior is non-informative (zero mean and infinite variance)

    if all(prior_mean == 0) && all(all(prior_covariance == Inf))

        % Use non-informative prior

        posterior_covariance = inv(X' * X / sigma2);

        posterior_mean = posterior_covariance * (X' * y / sigma2);

    else

        % Use informative prior

        posterior_covariance = inv(inv(prior_covariance) + (X' * X) / sigma2);

        posterior_mean = posterior_covariance * (inv(prior_covariance) * prior_mean + (X' * y) / sigma2);

    end

end
