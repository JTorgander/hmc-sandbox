
BS_PATH <- "~/Documents/bridgestan" #Replace with path to bridgestan directory

#' Stan Model getter
#'
#' Fetches (compiled) bridgestan and regular stan model and returns the corresponding
#' StanModel objects
#' @param bridgestan_path Path to compiled bridgestan models and data
#' @param model_name Name of bridgestan model to be imported
#' @param data Boolean indicating if the corresponding data.json file should be included.
#' @export
get_model <- function(model_name, model_seed, data = TRUE,  bridgestan_path = BS_PATH){

  # Generating paths to models and data
  model_path <- paste0(bridgestan_path, "/test_models/", model_name)
  bs_stan_model_path <- paste0(model_path, "/", model_name, "_model.so")
  stan_model_path <- paste0(model_path, "/", model_name, ".stan")
  data_path <-  ifelse(data, paste0(model_path, "/", model_name, ".data.json"), "")
  data <- jsonlite::fromJSON(data_path)
  # Generating stan model
  #stan_model <- stan_model(stan_model_path)
  stan_model <- cmdstanr::cmdstan_model(stan_model_path)
  # Generating Bridgestan-model
  message("Loading Bridgestan model")
  BS_model <-  bridgestan::StanModel$new(bs_stan_model_path, data_path, model_seed)
  param_names <- BS_model$param_names()
  message("Models loaded!")

  return(list(BS_model = BS_model,
              stan_model = stan_model,
              data = data,
              param_names = param_names)
          )
}

#' Write R data to bridgestan data JSON file
#'
#' Converting a list of data into a JSON file recognized by the bridgestan compiler
#' @param data List of data to be converted
#' @param bridge_stan_path Path to Bridgestan dir
#' @param model_name Name of the Bridgestan model corresponding tothe data
#' @export
write_json_data <- function(data, model_name, bridgestan_path = BS_PATH){
  # Converting data from list to JSON-format
  data_json <- jsonlite::toJSON(data, auto_unbox = TRUE)
  # Writing JSON file to disk
  data_path <- paste0(bridgestan_path, "/test_models/", model_name, "/", model_name, ".data.json")
  message(paste0("Writing data to ", data_path))
  write(data_json, file = data_path)
  message("Writing completed!")

}

compile_bs <- function(model_name, bridgestan_path = BS_PATH){
  # Saving current wd
  cur_dir <- getwd()
  # Changing to bridgestan directory and compiling model
  setwd(BS_PATH)
  compile_path <- paste0("./test_models/", model_name, "/", model_name, "_model.so")
  try(system(paste0("make ", compile_path)))
  # Reseting wd
  setwd(cur_dir)
}
