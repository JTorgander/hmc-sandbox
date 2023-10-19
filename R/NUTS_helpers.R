#' One-step integration with leapfrog algorithm
#'
#' Conducting one step of the leapfrog integrator. Return updated variables together with the gradient
#' corresponding to the second momentum update.
#' @param model Underlying bridgestan model object
#' @param current_q Vector with current parameter variable values
#' @param model_name Vector with current momentum variable values
#' @param eps Step size
#' @param inv_mass_matrix Diagonal of inverse mass matrix
#' @export
leapfrog_1step <- function(model, current_q, current_p, eps, inv_mass_matrix){
  # First momentum update
  g <- model$log_density_gradient(current_q)$gradient
  p <- current_p + (eps/2)*g
  # Parameter update
  q <-  current_q + eps * inv_mass_matrix %*% p
  # Second momentum update
  g <- model$log_density_gradient(q)$gradient
  p <- p + (eps/2) * g
  return(list(q=q, p=p, g=g))

}

has_no_u_turn <- function(theta_pos, theta_neg, p_pos, p_neg){
  # Taking in vectors with parameter and momentum values corresponding to
  # the first and last NUTS state respectively. Returns true if angle between
  # proposed momentum and total change in direction is larger or smaller than +- 90 degrees
  theta_diff <- theta_pos - theta_neg
  cond1 <- sum(theta_diff * p_pos) >= 0
  cond2 <- sum(theta_diff * p_neg) >= 0
  return(cond1 * cond2)
}

build_tree <- function(stan_model, theta, p, u, v, j, eps, delta_max, inv_mass_matrix){
  if (j == 0){
    # Base case - take one leapfrog step in the direction v
    new_state <- leapfrog_1step(stan_model, theta, p, v*eps, inv_mass_matrix)
    theta_new <- new_state$q
    p_new <- new_state$p
    #slice_cond <- exp(stan_model$log_density(theta_new) - 0.5*sum(p_new*p_new))
    log_slice_cond <- stan_model$log_density(theta_new) - 0.5*t(p_new)%*% inv_mass_matrix %*% p_new
    #accept_state <- u <= slice_cond # Slice sampler acceptance
    accept_state <- log(u) <= log_slice_cond
    #not_stop_1 <- u < slice_cond*exp(delta_max) #Stop if acceptance probability is too low
    not_stop_1 <- log(u) < log_slice_cond + delta_max
    # Rejecting if gradient over/underflows 
    if (is.na(not_stop_1) || is.na(accept_state) || any(is.na(p_new))){
      not_stop_1 <- FALSE
      accept_state <- FALSE
    }

    return(list(theta_neg = theta_new,
                p_neg = p_new,
                theta_pos = theta_new,
                p_pos = p_new,
                theta_new = theta_new,
                n_accepted_states = accept_state,
                not_stop_1 = not_stop_1)
    )
  } else{
    # Recursively build the left and right subtrees
    tree_1 <-  build_tree(stan_model, theta, p, u, v, j - 1, eps, delta_max, inv_mass_matrix)
    theta_neg <- tree_1$theta_neg
    p_neg <- tree_1$p_neg
    theta_pos <- tree_1$theta_pos
    p_pos <- tree_1$p_pos
    theta_new_1 <- tree_1$theta_new
    n_accepted_states_1 <- tree_1$n_accepted_states
    not_stop_1 <- tree_1$not_stop_1
    if (not_stop_1){
      if (v == -1) {
        tree_2 <-  build_tree(stan_model, theta_neg, p_neg, u, v, j - 1, eps, delta_max, inv_mass_matrix)
        theta_neg <- tree_2$theta_neg
        p_neg <- tree_2$p_neg
        theta_new_2 <- tree_2$theta_new
        n_accepted_states_2 <- tree_2$n_accepted_states
        not_stop_2 <- tree_2$not_stop_1
      } else {
        tree_2 <-  build_tree(stan_model, theta_pos, p_pos, u, v, j - 1, eps, delta_max, inv_mass_matrix)
        theta_pos <- tree_2$theta_pos
        p_pos <- tree_2$p_pos
        theta_new_2 <- tree_2$theta_new
        n_accepted_states_2 <- tree_2$n_accepted_states
        not_stop_2 <- tree_2$not_stop_1
      }
      accept_prob <- ifelse(max(n_accepted_states_1, n_accepted_states_2) == 0,
                            0,
                            n_accepted_states_2 / (n_accepted_states_1 + n_accepted_states_2)
                            )
      if (runif(1) < accept_prob){
        theta_new_1 <- theta_new_2
      }
      no_u_turn <-  has_no_u_turn(theta_pos, theta_neg, p_pos, p_neg)
      # Rejecting if last momentum update over/underflows
      if (is.na(no_u_turn)){
        not_stop_1 <- FALSE
      } else {
      not_stop_1 <- not_stop_2*no_u_turn
      }
      n_accepted_states_1 <- n_accepted_states_1 + n_accepted_states_2
    }
    return(list(theta_neg = theta_neg,
                p_neg = p_neg,
                theta_pos = theta_pos,
                p_pos = p_pos,
                theta_new = theta_new_1,
                n_accepted_states = n_accepted_states_1,
                not_stop_1 = not_stop_1)
          )
  }
}

find_reasonable_eps <- function(stan_model, theta){
  dim <- length(theta)
  eps <- 1
  p <- rnorm(dim, 0 ,1)
  new_state <- leapfrog_1step(stan_model, theta, p, eps)
  theta_new <- new_state$q
  p_new <- new_state$p

  a <- 2

}
