cond_normal_lh <- function(data, mu, sigma){
  # Evaluating conditional-normal likelihood function for input data
  N <- length(data)
  lh <- 1
  for (i in 1:N){
    x <- data[i]
    lh <- lh + log(dnorm(x, mean = mu, sd = sigma))
  }
  return(lh)
}


gibbs_class_prob <- function(data, mu, sigma, prior_z){
  # Computing conditional class probabilities
  K <- length(mu)
  probs <- seq_len(K)
  for (i in 1:K){
    probs[i] <-  prior_z * cond_normal_lh(data, mu[i], sigma)
  }
  # Normalizing
  probs <- probs/sum(probs)
  return(probs)
}

sample_cond_z <- function(data, mu, sigma){
  # Sampling class assignments conditional on the mean and
  # variance of the Gaussian mixture distributions
  K <- length(mu)
  N <- nrow(data)
  cond_prob_z <- seq_len(K)
  samples <- seq_len(N)
  # Computing sampling probabilites and sampling
  for (i in 1:N){

    for (j in 1:K){

      cond_prob_z[j] <- (1/K)*dnorm(data[i], mean = mu[j], sd = sigma)



    }

    samples[i] <- sample(1:K, 1, TRUE,  prob = cond_prob_z/sum(cond_prob_z))

  }




  return(samples)
}


sample_cond_mu <- function(data, dim, z, sigma, lambda){

  mu_new <- seq_len(dim)
  for (i in 1:dim){
    z_equal_k <- z == i
    n_k <- sum(z_equal_k)
    x_mean <- sum(z_equal_k*data)/n_k
    mu_hat <-((n_k/sigma^2)/( (n_k/sigma^2) + (1/lambda^2))) * x_mean

    lambda_hat <- 1/((n_k/sigma^2) + (1/lambda^2))
    mu_new[i] <- rnorm(1, mu_hat, sqrt(lambda_hat))
  }
  return(mu_new)
}
