#!/usr/bin/Rscript

# sources:
# - https://github.com/SticsRPacks/SticsOnR#running-the-model-using-javastics-command-line-interface
# - https://github.com/SticsRPacks/SticsOnR#advanced-simulations-parameterization

# library
library("SticsRPacks")

# paths
pwd <- Sys.getenv("PWD")
java_path <- paste(pwd, '/../jdk8u332-b09-jre/bin/java', sep="")
javastics_path <- paste(pwd, '/../simulate', sep="")
workspace_path <- "Porec_merlot"

# run
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
  parallel = TRUE,
  cores = 2,
  verbose = TRUE,
  time_display = TRUE,
)

stics_wrapper(
  model_options = model_options,
  situation = "simulate",
)
