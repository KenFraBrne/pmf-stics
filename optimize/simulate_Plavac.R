#!/usr/bin/Rscript

# library
library("SticsOnR")
library("SticsRFiles")
library("CroptimizR")
library("CroPlotR")

# paths
pwd <- Sys.getenv("PWD")
javastics_path <- paste(pwd, '/../simulate', sep="")
workspace_path <- "grasevina"

# usms
usms <- c("Blato_1971_2000_CLMcom_CNRM_Historijski",
          "Blato_2041_2070_CLMcom_CNRM_Projekcije_rcp45",
          "Blato_2041_2070_rcp85_CLMcom_CNRM_Projekcije_rcp85",
          "Blato_2071_2100_CLMcom_CNRM_Projekcije_rcp45",
          "Blato_2071_2100_rcp85_CLMcom_CNRM_Projekcije_rcp85",
          "Hvar_1971_2000_CLMcom_CNRM_Historijski",
          "Hvar_2041_2070_CLMcom_CNRM_Projekcije_rcp45",
          "Hvar_2041_2070_rcp85_CLMcom_CNRM_Projekcije_rcp85",
          "Hvar_2071_2100_CLMcom_CNRM_Projekcije_rcp45",
          "Hvar_2071_2100_rcp85_CLMcom_CNRM_Projekcije_rcp85",
          "Lastovo_1971_2000_CLMcom_CNRM_Historijski",
          "Lastovo_2041_2070_CLMcom_CNRM_Projekcije_rcp45",
          "Lastovo_2041_2070_rcp85_CLMcom_CNRM_Projekcije_rcp85",
          "Lastovo_2071_2100_CLMcom_CNRM_Projekcije_rcp45",
          "Lastovo_2071_2100_rcp85_CLMcom_CNRM_Projekcije_rcp85")

# gen_usms
gen_usms_xml2txt(javastics_path,
                 workspace = workspace_path,
                 usm = usms,
                 out_dir = workspace_path,
                 verbose = TRUE)

# model
model_options <- stics_wrapper_options(
  javastics = javastics_path,
  workspace = file.path(javastics_path, workspace_path),
  cores = as.numeric(Sys.getenv('NSLOTS')),
  parallel = TRUE,
  time_display = TRUE,
)

# load optimized values
load("optimized/grasevina/optim_results.Rdata")

# simulate
var_name <- c("ilevs", "iflos", "ilaxs", "irecs", "H2Orec_percent")
stics_wrapper(param_values = res$MAP,
              model_options = model_options,
              situation = usms,
              var = var_name)
