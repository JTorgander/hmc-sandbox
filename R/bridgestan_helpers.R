
library(bridgestan)

#' Bridgestan model getter
#'
#' Fetches (compiled) bridgestan model and returns the corresponding
#' StanModel object
#' @param bridgestan_path Path to compiled bridgestan models and data
#' @param model_name Name of bridgestan model to be imported
#' @param data Boolean indicating if the corresponding data.json file should be included.
#' @export
get_model <- function(bridgestan_path, model_name, data = TRUE){

  model_path <- paste0(bridgestan_path, "/test_models/", model_name)
  stan_model_path <- paste0(model_path, "/", model_name, "_model.so")

  data_path <-  ifelse(data, paste0(model_path, "/", model_name, ".data.json"), "")

  model_seed <- 1234


  model <-  StanModel$new(stan_model_path, data_path, model_seed)

  return(model)
}
