source('./R/mixture_gibbs_helpers.R')

mixture_gibbs <- function(data, n_samples, mu_0, z_0, sigma, lambda){

  z <- z_0
  mu <- mu_0
  dim_mu <- length(mu)
  dim_z <- n_samples
  samples <- matrix(0, n_samples, dim_mu + dim_z)
  for (i in 1:n_samples){


    z <- sample_cond_z(data, mu, sigma)
    mu <- sample_cond_mu(data, z, sigma, lambda)
    print(mu)
    sample <- rbind(mu, z)

    samples[i, ] <- sample

  }


 return(samples)

}
