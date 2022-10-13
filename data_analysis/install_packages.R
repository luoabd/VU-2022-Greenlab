#! /usr/bin/Rscript

# Clear environment
rm(list = ls())

r = getOption("repos")
r["CRAN"] = "https://cloud.r-project.org/"
options(repos = r)

install.packages("tidyverse")
install.packages("qqplotr")
install.packages("effsize")
install.packages("bestNormalize")
