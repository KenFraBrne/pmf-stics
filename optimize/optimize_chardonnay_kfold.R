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

# model
model_options <- stics_wrapper_options(javastics = javastics_path,
                                       workspace = file.path(javastics_path, workspace_path),
                                       cores = as.numeric(Sys.getenv('NSLOTS')),
                                       parallel = TRUE,
                                       time_display = TRUE)

# txt inputs
gen_usms_xml2txt(javastics_path,
                 workspace = workspace_path,
                 verbose = TRUE)

# folds
for (fold in 0:4){

  # strings
  train_string <- sprintf("_train_%d", fold)
  test_string <- sprintf("_test_%d", fold)

  # observations
  var <- c("ilevs", "iflos", "ilaxs", "H2Orec_percent")
  usm <- c("Belje", "Daruvar", "Ilok", "Kutjevo", "Porec")
  usm_train <- paste0(usm, train_string)
  usm_test <- paste0(usm, test_string)
  obs_train <- get_obs(file.path(javastics_path, workspace_path), usm = usm_train)
  obs_test <- get_obs(file.path(javastics_path, workspace_path), usm = usm_test)
  obs_train <- filter_obs(obs_train, var=var, include=TRUE)
  obs_test <- filter_obs(obs_test, var=var, include=TRUE)

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

  # train
  optim_options <- list()
  optim_options$nb_rep <- 10
  optim_options$maxeval <- 200
  optim_options$xtol_rel <- 1e-3
  optim_options$out_dir <- file.path(pwd, 
                                     "optimized",
                                     paste(workspace_path,
                                           train_string,
                                           sep=""))
  optim_results <- estim_param(obs_list = obs_train,
                               model_function = stics_wrapper,
                               model_options = model_options,
                               optim_options = optim_options,
                               param_info = param_info)
  write.table(optim_results$final_values,
             file = sprintf('chardonnay_params_%d.out', fold))

  # test - evaluate
  sim_after_optim <- stics_wrapper(param_values = optim_results$final_values,
                                   model_options = model_options)
  errors <- summary(sim_after_optim$sim_list,
                    obs = get_obs(workspace = file.path(javastics_path, workspace_path)),
                    all_situations = FALSE)
  write.table(errors,
              file = sprintf('chardonnay_errors_%d.out', fold))
}
