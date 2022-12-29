#!/usr/bin/Rscript

# sources:
# - https://sticsrpacks.github.io/CroptimizR/articles/Parameter_estimation_simple_case.html

# library
library("SticsOnR")
library("SticsRFiles")
library("CroptimizR")
library("CroPlotR")
library(BayesianTools)

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
var_name <- c("ilevs", "iflos", "ilaxs", "H2Orec_percent")
obs_list <- get_obs(file.path(javastics_path, workspace_path), usm = sit_name)
obs_list <- filter_obs(obs_list, var=var_name, include=TRUE)

obs_list$Daruvar <- obs_list$Daruvar[5,]

# parameters
param_info <- list(
  lb = c(
    tdmin = 5,
    tdmax = 32,
    stlevamf = 15,
    stamflax = 800,
    stlevdrp = 250,
    stflodrp = 30,
    stdordebour = 6000,
    tdmindeb = 0,
    tdmaxdeb = 20,
    q10 = 1,
    idebdorm = 150,
    jvc = 80,
    stdrpdes = 80,
    deshydbase = 0.001,
    h2ograinmax = 0.5
  ),
  ub = c(
    tdmin = 15,
    tdmax = 42,
    stlevamf = 30,
    stamflax = 1300,
    stlevdrp = 450,
    stflodrp = 70,
    stdordebour = 10000,
    tdmindeb = 10,
    tdmaxdeb = 30,
    q10 = 3,
    idebdorm = 250,
    jvc = 120,
    stdrpdes = 110,
    deshydbase = 0.002,
    h2ograinmax = 1.0
  )
)

# optimization
optim_options <- list()
optim_options$iterations <- 100000
optim_options$startValue <- 1
optim_options$nrChains <- 10
optim_options$out_dir <- file.path(pwd, "optimized", workspace_path)
optim_options$method <- 'AM'
optim_options$optimize <- F
optim_results <- estim_param(
  obs_list = obs_list,
  crit_function = likelihood_log_ciidn,
  model_function = stics_wrapper,
  model_options = model_options,
  optim_options = optim_options,
  optim_method = "dreamzs",
  param_info = param_info,
)
summary(optim_results$out)
