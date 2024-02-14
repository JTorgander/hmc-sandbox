#' Stan Model getter
#'
#' Fetches (compiled) bridgestan and regular stan model and returns the corresponding
#' StanModel objects
#' @param bridgestan_path Path to compiled bridgestan models and data
#' @param model_seed Seed value for the sampler
#' @param model_name Name of bridgestan model to be imported
#' @param sampler_type Which type of HMC framework which should be used
#' @param data Boolean indicating if the corresponding data.json file should be included.
#' @import jsonlite
#' @import cmdstanr
#' @import bridgestan
#' @export
get_model <- function(model_name, model_seed, sampler_type = "bridgestan", data = TRUE,  bridgestan_path = BS_PATH){

  # Generating paths to models and data
  model_dir <- paste0(bridgestan_path, "/test_models/", model_name)
  # Loading CMDstan model
  model_path_cmd <- paste0(model_dir, "/", model_name, ".stan")
  cmdstan_model <-  cmdstanr::cmdstan_model(model_path_cmd)

  if (sampler_type == "bridgestan"){

    model_path <-  paste0(model_dir, "/", model_name, "_model.so")

    if (data){
      data_path <- paste0(model_dir, "/", model_name, ".data.json")
      data <- jsonlite::fromJSON(data_path)
    } else {
      data_path <- ""
      data <- NA
    }
    message("Loading Bridgestan model")
    bs_model <-  bridgestan::StanModel$new(model_path, data_path, model_seed)
    model <- list(bs_model = bs_model, cmdstan_model = cmdstan_model)
    param_names <- bs_model$param_names()

  } else{
    model <- cmdstan_model
    param_names <- NA
  }

  message("Models loaded!")

  return(list(model = model,
              param_names = param_names,
              sampler_type = sampler_type,
              data = data
              )
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

#' Write R data to bridgestan data JSON file
#'
#' Compiling a stan model into a bridgestan binary shared object (.so) file
#' @param model_name Name of the bridgestan folder containing the .stan file to be compiled
#' @param bridge_stan_path Path to Bridgestan dir
#' @export
compile_bs <- function(model_name, bridgestan_path){
  # Saving current wd
  cur_dir <- getwd()
  # Changing to bridgestan directory and compiling model
  setwd(bridgestan_path)
  compile_path <- paste0("./test_models/", model_name, "/", model_name, "_model.so")
  try(system(paste0("make ", compile_path)))
  # Reseting wd
  setwd(cur_dir)
}
