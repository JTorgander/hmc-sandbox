#' Generation of mixture normal data
#'
#' Generates a data set distributed according to a normal mixture distribution
#' @param n_samples Number of samples
#' @param pi Vector of class probabilities
#' @param mu Maxtrix of cluster means
#' @param sigma Matrix of cluster standard deviationos
#' @export
get_mixture_data <- function(n_samples, pi, mu, sigma){

  dim <- ncol(mu)
  n_classes <- length(pi)
  data <- matrix(0, nrow = n_samples, ncol = dim)
  classes <- sample(1:n_classes, n_samples, replace = TRUE, prob = pi)

  for (i in 1:n_samples){
    c <- classes[i]
    data[i, ] <- mvrnorm(1, mu[c, ], diag(sigma, nrow=dim, ncol=dim))
  }

  return(list(data=as.vector(data), classes = classes))

}
