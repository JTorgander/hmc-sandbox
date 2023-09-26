source('./R/NUTS_helpers.R')




#' NUTS/bridgestan sampler
#'
#' Sampling from an input bridgestan model, using the NUTS sampler
#' @param stan_model Input bridgestan model
#' @param theta_0 Initial parameter value
#' @param eps Step size
#' @param n_samples Number of post warmup samples generated
#' @export
NUTS <- function(stan_model, theta_0, eps, n_samples){
    delta_max = 100
    dim <- length(theta_0)

    theta_prev <- stan_model$param_unconstrain(theta_0)

    samples <- matrix(0, n_samples, dim)
    for (m in 1:n_samples){


      p0 <- rnorm(dim, 0, 1)

      slice_cond <- exp(stan_model$log_density(theta_prev) - 0.5*sum(p0*p0))


      u <- runif(1, min = 0, max = slice_cond)

      # Initializing state variables
      theta_neg <- theta_prev
      theta_pos <- theta_prev
      p_neg <- p0
      p_pos <- p0
      j <- 0
      theta_new <- theta_prev
      n_accepted_states <- 1
      not_stop <- TRUE


      while (not_stop){

        # Choose a direction
        v <- sample(c(-1, 1), 1)
        v <- 1
        if (v == -1){

          tree <-  build_tree(stan_model, theta_neg, p_neg, u, v, j, eps, delta_max)
          theta_neg <- tree$theta_neg
          p_neg <- tree$p_neg
          theta_proposal <- tree$theta_new
          n_accepted_states_new <- tree$n_accepted_states
          not_stop_1 <- tree$not_stop_1


        } else{

          tree <-  build_tree(stan_model, theta_pos, p_pos, u, v, j, eps, delta_max)
          theta_pos <- tree$theta_pos
          p_pos <- tree$p_pos
          theta_proposal <- tree$theta_new
          n_accepted_states_new <- tree$n_accepted_states
          not_stop_1 <- tree$not_stop_1


        }

        if(not_stop_1){

          accept_prob <- min(1, n_accepted_states_new/ n_accepted_states)

          if (runif(1) < accept_prob){
          theta_new <- theta_proposal
          }
        }

        n_accepted_states <- n_accepted_states + n_accepted_states_new

        not_stop <- not_stop_1*has_no_u_turn(theta_pos, theta_neg, p_pos, p_neg)
        j <- j + 1


      }

      samples[m, ] <- stan_model$param_constrain(theta_new)
      theta_prev <- theta_new

    }

    return(samples)

  }

