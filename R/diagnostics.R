#' Sample trajectory summary generator
#'
#' Extracting and summarizing parameter, momentum, gradient and hessian
#'trajectories for a given NUTS-simulation
#' @param sim Input NUTS simulation
#' @export
get_trajectory_stats <- function(sim){
  traj <- sim$trajectories
  df <- data.frame()
  for (i in 1:length(traj)){
    # Extracting trajectory for one NUTS sample
    sample_trajectory <- traj[[i]]
    for (j in 1:length(sample_trajectory)){
      # Iterating over each leapfrog step
      leapfrog_steps <- sample_trajectory[[j]]
      for(k in 1:length(leapfrog_steps)){
        # For each leap frog step extracting parameter, momentum and gradient values
        lf <- leapfrog_steps[[k]]
        grads <- lf$gradients
        g1 <- grads$g1
        g2 <- grads$g2
        g1_l2 <- norm(g1, "2")
        g2_l2 <- norm(g2, "2")
        momentum <- lf$momentum
        theta <- lf$theta
        h1 <- lf$hessians$h1
        h1_diag <- diag(h1)
        h1_tri <- h1[lower.tri(h1)]
        h2 <- lf$hessians$h2
        h2_diag <- diag(h2)
        h2_tri <- h1[lower.tri(h2)]

        row <- c(i,j,k,
                 lf$tree_direction,
                 t(theta),
                 momentum$p1,
                 momentum$p2,
                 grads$g1,
                 grads$g2,
                 h1_diag,
                 h2_diag,
                 h1_tri,
                 h2_tri,
                 g1_l2,
                 g2_l2)
        df <- rbind(df, row)
      }
    }
  }
  # Setting column names for output data frame
  variables <- paste0(c("theta", "p1", "p2", "g1", "g2",  "h1_diag", "h2_diag" ), "_")
  var_names <- t(outer(variables, sim$param_unc_names, FUN = paste0 )) %>% as.vector()
  var_names_cross <- outer(paste0(sim$param_unc_names, "_"), sim$param_unc_names, FUN=paste0)
  var_names_cross <- var_names_cross[upper.tri(var_names_cross)]
  hessian_tri_names <- t(outer(c("h1_", "h2_"), var_names_cross, FUN = paste0 )) %>% as.vector()
  names(df) <- c("sample", "subtree", "leapfrog_iter", "tree_dir", var_names, hessian_tri_names, "g1_l2", "g2_l2")

  return(df)
}
