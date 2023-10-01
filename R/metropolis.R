
metropolis_1step <- function(posterior, theta, proposal){

  theta_proposal <- proposal(theta)
  r <- posterior(theta_proposal)/posterior(theta)
  theta_new <- ifelse(runif(1) < min(1, r), theta_proposal, theta)

  return(theta_new)

}
