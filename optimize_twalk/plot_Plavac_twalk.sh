#!/bin/bash

export NSLOTS=10
export PATH="../jdk8u332-b09-jre/bin":$PATH
rm ../simulate/Plavac/*/mod_rapport.sti
Rscript plot_Plavac_twalk.R
for file in $( ls ../simulate/Plavac/*/mod_rapport.sti );
do
  cp $file ${file//mod_rapport/mod_rapport_MAP}
done
