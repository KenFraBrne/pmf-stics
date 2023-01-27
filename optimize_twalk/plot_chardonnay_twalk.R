#!/usr/bin/Rscript

# library
library("SticsOnR")
library("SticsRFiles")
library("CroptimizR")
library("CroPlotR")

# paths
pwd <- Sys.getenv("PWD")
javastics_path <- paste(pwd, '/../simulate', sep="")
workspace_path <- "chardonnay"

# create files
gen_usms_xml2txt(
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
sit_name <- c("Belje", "Daruvar", "Ilok", "Kutjevo", "Porec")
var_name <- c("ilevs", "iflos", "ilaxs", "irecs", "H2Orec_percent")
obs_list <- get_obs(file.path(javastics_path, workspace_path), usm = sit_name)
obs_list <- filter_obs(obs_list, var=var_name, include=TRUE)

# load optimized values
load("optimized/chardonnay_twalk/optim_results.Rdata")

# simulate
sim_after_optim <- stics_wrapper(
  param_values = res$MAP,
  model_options = model_options,
  var = var_name
)

# plot
pdf("chardonnay_twalk-scatter.pdf")
plot(
  sim_after_optim$sim_list,
  obs = obs_list,
  type="scatter",
  all_situations=TRUE,
  shape_sit="symbol"
)
