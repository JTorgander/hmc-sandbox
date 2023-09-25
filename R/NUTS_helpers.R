


leapfrog_1step <- function(stan_model, current_q, current_p, eps, m=1){

  dim <- length(current_q)

  g <- stan_model$log_density_gradient(current_q)$gradient

  p <- current_p + (eps/2)*g
  q <-  current_q + (eps * p)/m

  g <- stan_model$log_density_gradient(q)$gradient

  p <- p + (eps/2) * g



  return(list(q=q, p=p))

}




has_no_u_turn <- function(theta_pos, theta_neg, p_pos, p_neg){


  theta_diff <- theta_pos - theta_neg
  #True if angle between proposed momentum and total change in direction is
  # larger or smaller than +- 90 degrees
  cond1 <- sum(theta_diff * p_pos) >= 0
  cond2 <- sum(theta_diff * p_pos) >= 0

  return(cond1 * cond2)


}




build_tree <- function(stan_model, theta, p, u, v, j, eps, delta_max){


  if (j == 0){
    # Base case - take one leapfrog step in the direction v
    new_state <- leapfrog_1step(stan_model, theta, p, v*eps)
    theta_new <- new_state$q
    p_new <- new_state$p
    slice_cond <- exp(stan_model$log_density(theta_new) - 0.5*sum(p_new*p_new))

    accept_state <- u <= slice_cond # Slice sampler acceptance
    not_stop_1 <- u < slice_cond*exp(delta_max) #Stop if acceptance probability is too low

    return(list(theta_neg = theta_new,
                p_neg = p_new,
                theta_pos = theta_new,
                p_pos = p_new,
                theta_new = theta_new,
                n_accepted_states = accept_state,
                not_stop_1 = not_stop_1)
    )


  } else{

    # Recursion - implicitly build the left and right subtrees
    tree_1 <-  build_tree(stan_model, theta, p, u, v, j - 1, eps, delta_max)
    theta_neg <- tree_1$theta_neg
    p_neg <- tree_1$p_neg
    theta_pos <- tree_1$theta_pos
    p_pos <- tree_1$p_pos
    theta_new_1 <- tree_1$theta_new
    n_accepted_states_1 <- tree_1$n_accepted_states
    not_stop_1 <- tree_1$not_stop_1

    if (not_stop_1){

      if (v == -1) {

        tree_2 <-  build_tree(stan_model, theta_neg, p_neg, u, v, j - 1, eps, delta_max)
        theta_neg <- tree_2$theta_neg
        p_neg <- tree_2$p_neg
        theta_new_2 <- tree_2$theta_new
        n_accepted_states_2 <- tree_2$n_accepted_states
        not_stop_2 <- tree_2$not_stop_1


      } else {

        tree_2 <-  build_tree(stan_model, theta_pos, p_pos, u, v, j - 1, eps, delta_max)
        theta_pos <- tree_2$theta_pos
        p_pos <- tree_2$p_pos
        theta_new_2 <- tree_2$theta_new
        n_accepted_states_2 <- tree_2$n_accepted_states
        not_stop_2 <- tree_2$not_stop_1

      }
      accept_prob <- n_accepted_states_2 / (n_accepted_states_1 + n_accepted_states_2)

      if (runif(1) < accept_prob){
        theta_new_1 <- theta_new_2
      }
      not_stop_1 <- not_stop_2*has_no_u_turn(theta_pos, theta_neg, p_pos, p_neg)
      n_accepted_states_1 <- n_accepted_states_1 + n_accepted_states_2

    }

    return(list(theta_neg = theta_neg,
                p_neg = p_neg,
                theta_pos = theta_pos,
                p_pos = p_pos,
                theta_new = theta_new_1,
                n_accepted_states = n_accepted_states_1,
                not_stop_1 = not_stop_1
    )
    )

  }
}
