#!/usr/bin/Rscript

# library
library("SticsOnR")
library("SticsRFiles")
library("CroptimizR")
library("CroPlotR")
library(dplyr)

# paths
pwd <- Sys.getenv("PWD")
javastics_path <- paste(pwd, '/../simulate', sep="")
workspace_path <- "merlot"

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
sit_name <- c("Agrolaguna", "Belje", "Blato", "Kutjevo", "Porec", "Zadar")
var_name <- c("ilevs", "iflos", "ilaxs", "irecs", "H2Orec_percent")
obs_list <- get_obs(file.path(javastics_path, workspace_path), usm = sit_name)
obs_list <- filter_obs(obs_list, var=var_name, include=TRUE)
obs_list$Kutjevo <- obs_list$Kutjevo[9:23,]

# load optimized values
load("optimized/merlot/optim_results.Rdata")

# simulate
sim_after_optim <- stics_wrapper(
  param_values = res$MAP,
  model_options = model_options,
  var = var_name
)

# plot
pdf("merlot-scatter.pdf")
plot(
  sim_after_optim$sim_list,
  obs = obs_list,
  type="scatter",
  all_situations=TRUE,
  shape_sit="symbol"
)
