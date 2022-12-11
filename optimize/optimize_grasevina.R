#!/usr/bin/Rscript

# sources:
# - https://sticsrpacks.github.io/CroptimizR/articles/Parameter_estimation_simple_case.html

# library
library("SticsOnR")
library("SticsRFiles")
library("CroptimizR")

# paths
pwd <- Sys.getenv("PWD")
javastics_path <- paste(pwd, '/../simulate', sep="")
workspace_path <- "grasevina"

# txt inputs
res <- gen_usms_xml2txt(
  javastics_path,
  workspace = workspace_path,
  out_dir = workspace_path,
  verbose = TRUE,
)

model_options <- stics_wrapper_options(
  javastics = javastics_path,
  workspace = file.path(javastics_path, workspace_path),
  cores = as.numeric(Sys.getenv('NSLOTS')),
  parallel = TRUE,
  time_display = TRUE,
)

# observations
sit_name <- c("Daruvar", "Ilok", "Kutjevo", "Krizevci")
var_name <- c("ilevs", "iflos", "irecs", "H2Orec_percent")
obs_list <- get_obs(file.path(javastics_path, workspace_path), usm = sit_name)
obs_list <- filter_obs(obs_list, var=var_name, include=TRUE)

# parameters
param_info <- list(
  lb = c(
    stdordebour = 5000,
    stdrpnou = 45,
    stamflax = 500,
    stlevdrp = 100,
    stflodrp = 10,
    stdrpdes = 40,
    jvc = 50,
    afruitpot = 1,
    dureefruit = 500,
    h2ograinmax = 0.5,
    deshydbase = 0.0005
  ),
  ub = c(
    stdordebour = 15000,
    stdrpnou = 200,
    stamflax = 2000,
    stlevdrp = 700,
    stflodrp = 100,
    stdrpdes = 200,
    jvc = 200,
    afruitpot = 5,
    dureefruit = 3000,
    h2ograinmax = 1.0,
    deshydbase = 0.0030
  )
)

# optimization
optim_options <- list()
optim_options$iterations <- 5
optim_options$start_value <- 3
optim_options$xtol_rel <- 1e-03
optim_options$out_dir <- file.path(javastics_path, workspace_path, "optimized")
optim_options$ranseed <- 1234
res <- estim_param(
  obs_list = obs_list,
  crit_function = likelihood_log_ciidn,
  model_function = stics_wrapper,
  model_options = model_options,
  optim_options = optim_options,
  optim_method = "BayesianTools.dreamzs",
  param_info = param_info,
)
warnings()
