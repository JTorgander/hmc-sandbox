
library(bridgestan)
library(jsonlite)
library(rstan)
library(MASS)

BS_PATH <- "~/Documents/bridgestan"

#' Stan Model getter
#'
#' Fetches (compiled) bridgestan and regular stan model and returns the corresponding
#' StanModel objects
#' @param bridgestan_path Path to compiled bridgestan models and data
#' @param model_name Name of bridgestan model to be imported
#' @param data Boolean indicating if the corresponding data.json file should be included.
#' @export
get_model <- function(model_name, model_seed, return_stan = FALSE, data = TRUE,  bridgestan_path = BS_PATH){

  model_path <- paste0(bridgestan_path, "/test_models/", model_name)
  bs_stan_model_path <- paste0(model_path, "/", model_name, "_model.so")
  stan_model_path <- paste0(model_path, "/", model_name, ".stan")

  data_path <-  ifelse(data, paste0(model_path, "/", model_name, ".data.json"), "")

  if (return_stan){
    print("hej")
  data <- fromJSON(data_path)
  model_seed <- 1234

  stan_model <- stan_model(stan_model_path)
  } else {

    data <- list()
    stan_model <- list()
  }
  BS_model <-  StanModel$new(bs_stan_model_path, data_path, model_seed)

  return(list(BS_model = BS_model,
              stan_model = stan_model,
              data = data
             )
        )
}

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


#' Write R data to bridgestan data JSON file
#'
#' Converting a list of data into a JSON file recognized by the bridgestan compiler
#' @param data List of data to be converted
#' @param bridge_stan_path Path to Bridgestan dir
#' @param model_name Name of the Bridgestan model corresponding tothe data
#' @export
write_json_data <- function(data, model_name, bridgestan_path = BS_PATH){

  data_path <- paste0(bridgestan_path, "/test_models/", model_name, "/", model_name, ".data.json")
  message(paste0("Writing data to ", data_path))
  data_json <- toJSON(data, auto_unbox = TRUE)
  print(data_path)
  write(data_json, file = data_path)
  message("Writing completed!")
}

compile_bs <- function(model_name, bridgestan_path = BS_PATH){

  cur_dir <- getwd() # Saving current wd

  setwd(BS_PATH)
  compile_path <- paste0("./test_models/", model_name, "/", model_name, "_model.so")

  try(system(paste0("make ", compile_path)))
  setwd(cur_dir) # Reseting wd


}
