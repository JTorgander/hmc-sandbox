source('./R/NUTS_helpers.R')

# TODO: implement Dual averaging/adaptive step size

#' NUTS/bridgestan sampler
#'
#' Sampling from an input bridgestan model, using the NUTS sampler
#' @param model Input bridgestan and cmdstan model object
#' @param n_samples Number of post warmup samples generated
#' @param warm_up Sampler burn-in-period
#' @param initialize_model TRUE if stan's initialization of mass matrix and step size should be used
#' @param return_hessian TRUE if the full hessian should be genererated at each leapfrog iteration
#' @param initial_params Optional list containing initial custom parameters "step_size", "mass_matrix" and "theta_0".
#' Used when initialize_model == FALSE
#' @import MASS
#' @export
NUTS <- function(model_object, n_samples, warm_up = floor(n_samples/2), initialize_model = TRUE, return_hessian = TRUE, initial_params = NULL){
   # Initializing model parameters and mass matrix
    if (initialize_model || is.null(initial_params)){
      message("Initializing model..\n\nInitialization messages:")
      init <- initialize_model(model_object, warm_up)
      message("\n\nModel initialized!\n")
    } else {
      init <- initial_params
    }
    eps <- init$step_size
    inv_mass_matrix <- init$mass_matrix
    theta_0 <- init$theta_0
    model <- model_object$model$bs_model
    delta_max = 2000
    dim_constr <- length(theta_0)
    theta_prev <- model$param_unconstrain(theta_0)
    dim_unconstr <- length(theta_prev)
    param_names <- model$param_names()
    param_unc_names <- model$param_unc_names()
    mass_matrix <- solve(inv_mass_matrix)
    trajectories <- list()

    # Initializing output sample matrix
    samples <- matrix(0, n_samples, dim_constr, dimnames = list(iteration = c(),
                                                                parameters = param_names))
    message("Generating samples..")
    for (m in 1:(n_samples + warm_up)){
      sample_trajectory <- list()
      # Sampling momentum variable
      #p0 <- rnorm(dim_unconstr, 0, sqrt(1/inv_mass_matrix))
      p0 <- MASS::mvrnorm(1, rep(0, dim_unconstr), mass_matrix)
      # Formulating slice sampler condition
      slice_cond <- exp(model$log_density(theta_prev) - 0.5*t(p0)%*%inv_mass_matrix%*%p0)
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
      # Continue as long as No-U-Turn condition holds
      while (not_stop){
        # Choose a direction
        v <- sample(c(-1, 1), 1)
        # Building either the forward or backwards binary leapfrog tree
        if (v == -1){
          tree <-  build_tree(model, theta_neg, p_neg, u, v, j, eps, delta_max, inv_mass_matrix, return_hessian)
          theta_neg <- tree$theta_neg
          p_neg <- tree$p_neg
        } else{
          tree <-  build_tree(model, theta_pos, p_pos, u, v, j, eps, delta_max, inv_mass_matrix, return_hessian)
          theta_pos <- tree$theta_pos
          p_pos <- tree$p_pos
        }

        theta_proposal <- tree$theta_new
        n_accepted_states_new <- tree$n_accepted_states
        not_stop_1 <- tree$not_stop_1

        if(not_stop_1){
          # Continuous sampling from NUTS-trajectory
          accept_prob <- min(1, n_accepted_states_new/ n_accepted_states)
          if (runif(1) < accept_prob){
            theta_new <- theta_proposal
          }
        }
        # Updating acceptance probability
        n_accepted_states <- n_accepted_states + n_accepted_states_new
        # Checking if No-U-Turn condition is violated
        no_u_turn <-  has_no_u_turn(theta_pos, theta_neg, p_pos, p_neg)
        # Assuring that last momentum update has not exploded
        if (is.na(no_u_turn)){
          not_stop <- FALSE
          div_transition <- TRUE
        } else {
          not_stop <- not_stop_1*no_u_turn
          div_transition <- FALSE
        }
        sample_trajectory[[j+1]] <- tree$sub_trajectories
        j <- j + 1
      }
      # Saving samples if burn-in phase is completed
      if (m > warm_up){
        idx <- m - warm_up
        if (idx %% ceiling(n_samples/10) == 0){
          message(paste0(idx, " out of ", n_samples, " samples generated"))
        }
        samples[idx, ] <- model$param_constrain(theta_new)
        trajectories[[idx]] <- sample_trajectory
      }
      # Updating parameters
      theta_prev <- theta_new
    }
    message("Sampling completed!")
    return(list(samples=samples,
                dim_unconstr=dim_unconstr,
                param_names=param_names,
                param_unc_names=param_unc_names,
                trajectories=trajectories)
           )
  }

