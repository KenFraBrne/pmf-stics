#!/bin/bash

export NSLOTS=10
export PATH="../jdk8u332-b09-jre/bin":$PATH
rm ../simulate/merlot/*/mod_rapport.sti
Rscript plot_merlot_twalk.R
for file in $( ls ../simulate/merlot/*/mod_rapport.sti );
do
  cp $file ${file//mod_rapport/mod_rapport_MAP}
done
