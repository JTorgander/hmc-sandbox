% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bridgestan_helpers.R
\name{get_model}
\alias{get_model}
\title{Stan Model getter}
\usage{
get_model(model_name, model_seed, data = TRUE, bridgestan_path = BS_PATH)
}
\arguments{
\item{model_name}{Name of bridgestan model to be imported}

\item{data}{Boolean indicating if the corresponding data.json file should be included.}

\item{bridgestan_path}{Path to compiled bridgestan models and data}
}
\description{
Fetches (compiled) bridgestan and regular stan model and returns the corresponding
StanModel objects
}
