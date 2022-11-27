#!/usr/bin/Rscript

# install devtools
if (!require("devtools")){
  install.packages("devtools")
}

# Install and load the needed libraries
if (!require("SticsRPacks")) {
  Sys.unsetenv("GITHUB_PAT")
  install_github("SticsRPacks/SticsRPacks")
  library("SticsRPacks")
}
