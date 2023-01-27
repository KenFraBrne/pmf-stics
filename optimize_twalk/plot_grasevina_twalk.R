#!/usr/bin/Rscript

# library
library("SticsOnR")
library("SticsRFiles")
library("CroptimizR")
library("CroPlotR")

# paths
pwd <- Sys.getenv("PWD")
javastics_path <- paste(pwd, '/../simulate', sep="")
workspace <- "grasevina"

# create files
gen_usms_xml2txt(
  javastics_path,
  workspace = workspace,
  out_dir = workspace,
  verbose = TRUE,
)
model_options <- stics_wrapper_options(
  javastics = javastics_path,
  workspace = file.path(javastics_path, workspace),
  cores = as.numeric(Sys.getenv('NSLOTS')),
  parallel = TRUE,
  time_display = TRUE,
)

# observations
sit_name <- c("Daruvar", "Ilok", "Kutjevo", "Krizevci")
var_name <- c("ilevs", "iflos", "ilaxs", "irecs", "H2Orec_percent")
obs_list <- get_obs(file.path(javastics_path, workspace), usm = sit_name)
obs_list <- filter_obs(obs_list, var=var_name, include=TRUE)

# load optimized values
load("optimized/grasevina_twalk/optim_results.Rdata")

# simulate
sim_after_optim <- stics_wrapper(
  param_values = res$MAP,
  model_options = model_options,
  var = var_name
)

# plot
pdf("grasevina_twalk-scatter.pdf")
plot(
  sim_after_optim$sim_list,
  obs = obs_list,
  type="scatter",
  all_situations=TRUE,
  shape_sit="symbol"
)
