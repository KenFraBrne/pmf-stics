#!/usr/bin/Rscript

# sources:
# - https://sticsrpacks.github.io/CroptimizR/articles/Parameter_estimation_simple_case.html

# library
library("SticsRPacks")

# paths
pwd <- Sys.getenv("PWD")
java_path <- paste(pwd, '/../jdk8u332-b09-jre/bin/java', sep="")
javastics_path <- paste(pwd, '/../simulate', sep="")
workspace_path <- "Kutjevo"

# txt inputs
res <- gen_usms_xml2txt(
  javastics_path,
  workspace = workspace_path,
  out_dir = workspace_path,
  verbose = TRUE,
  java_cmd = java_path,
)

model_options <- stics_wrapper_options(
  javastics = javastics_path,
  workspace = file.path(javastics_path, workspace_path),
  parallel = FALSE,
  time_display = TRUE,
)

# observations
sit_name <- "graševina"
var_name <- c("ilevs", "iflos", "irecs")
obs_list <- get_obs(file.path(javastics_path, workspace_path), usm = sit_name)
obs_list <- filter_obs(obs_list, var=var_name, include=TRUE)

# parameters
param_info <- list(
  lb = c(
    stdordebour = 1000,
    stdrpnou = 10,
    deshydbase = 0.0005,
    stamflax = 100,
    stlevdrp = 100,
    stflodrp = 10,
    stdrpdes = 10,
    jvc = 10,
    afruitpot = 0.5,
    dureefruit = 100
  ),
  ub = c(
    stdordebour = 15000,
    stdrpnou = 200,
    deshydbase = 0.005,
    stamflax = 3000,
    stlevdrp = 500,
    stflodrp = 200,
    stdrpdes = 200,
    jvc = 300,
    afruitpot = 5,
    dureefruit = 3000
  )
)

# optimization
optim_options <- list()
optim_options$nb_rep <- 1
optim_options$maxeval <- 1
optim_options$xtol_rel <- 1e-03
optim_options$out_dir <- file.path(javastics_path, workspace_path, sit_name, "optimized")
optim_options$ranseed <- 1234
res <- estim_param(
  obs_list = obs_list,
  model_function = stics_wrapper,
  model_options = model_options,
  optim_options = optim_options,
  param_info = param_info,
)
