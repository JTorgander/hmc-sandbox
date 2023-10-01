cond_normal_lh <- function(data, mu, sigma){
  N <- length(data)

  lh <- 0
  for (i in 1:N){
    x <- data[i]
    lh <- lh + log(dnorm(x, mean = mu, sd = sigma))

  }

  return(lh)
}

cond_class_prob <- function(z, mu, sigma, data, prior_z){


  return(prior_z * cond_normal_lh(data, mu[z], sigma))


}

gibbs_class_prob <- function(data, mu, sigma, prior_z){


  K <- length(mu)
  probs <- seq_len(K)
  for (i in 1:K){

    probs[i] <- cond_class_prob(i, mu, sigma, data, prior_z)

  }

  probs <- probs/sum(probs)
  return(probs)
}

sample_cond_z <- function(data, mu, sigma){

  K <- length(mu)
  N <- nrow(data)
  cond_prob_z <- gibbs_class_prob(data, mu, sigma ,1/K)

  z <- sample(1:K,N,TRUE, prob = cond_prob_z)


  return(z)
}


sample_cond_mu <- function(data, sigma, lambda, z){

  K <- length(mu)

  mu_new <- seq_len(K)

  for (i in 1:K){
    z_equal_k <- z == i
    n_k <- sum(z_equal_k)
    print(n_k)
    x_mean <- sum(z_equal_k*data)/n_k
    lambda_hat <- 1/((n_k/sigma^2) + (1/lambda^2))

    mu_hat <-((n_k/sigma^2)/( (n_k/sigma^2) + (1/lambda^2))) * x_mean
    mu_new[i] <- rnorm(1, mu_hat, lambda_hat)


  }

  return(mu_new)

}
