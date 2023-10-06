source('./R/mixture_gibbs_helpers.R')

mixture_gibbs <- function(data, n_samples, mu_0, z_0, sigma, lambda, burn_in = floor(n_samples/2)){

  z <- z_0
  mu <- mu_0
  dim_mu <- length(mu)
  dim_z <- nrow(data)

  names_mu <- paste0("mu[", 1:dim_mu, "]")
  names_z <-  paste0("y[", 1:dim_z, "]")




  samples <- matrix(0, nrow=n_samples, ncol=dim_mu + dim_z, dimnames = list(iteration = c(),
                                                                         parameters = c(names_mu, names_z)))

  for (i in 1:(n_samples + burn_in)){


    z <- sample_cond_z(data, mu, sigma)


    mu <- sample_cond_mu(data, dim_mu, z, sigma, lambda)

    sample <- c(mu,z)

    if (i > burn_in)

    samples[i - burn_in, ] <- sample

  }


 return(samples)

}
