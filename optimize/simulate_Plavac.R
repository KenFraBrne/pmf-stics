#!/usr/bin/Rscript

# library
library("SticsOnR")
library("SticsRFiles")
library("CroptimizR")
library("CroPlotR")

# paths
pwd <- Sys.getenv("PWD")
javastics_path <- paste(pwd, '/../simulate', sep="")
workspace_path <- "Plavac"

# usms
usms <- get_usms_list(file.path(javastics_path, workspace_path, "usms.xml"))
usms <- usms[ sapply("_", grepl, usms) ]

# gen_usms
gen_usms_xml2txt(javastics_path,
                 workspace = workspace_path,
                 usm = usms,
                 out_dir = workspace_path,
                 verbose = TRUE)

# model
model_options <- stics_wrapper_options(javastics = javastics_path,
                                       workspace = file.path(javastics_path, workspace_path),
                                       cores = as.numeric(Sys.getenv('NSLOTS')),
                                       parallel = TRUE,
                                       verbose = TRUE,
                                       time_display = TRUE)

# load optimized values
load("optimized/Plavac/optim_results.Rdata")

# simulate
for ( row in 99000:100000 ){
  stics_wrapper(param_values = res$MAP,
                model_options = model_options,
                situation = usms)
}
