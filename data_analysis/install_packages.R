#! /usr/bin/Rscript

# Clear environment
rm(list = ls())

# Automatically choose the best mirror
r = getOption("repos")
r["CRAN"] = "https://cloud.r-project.org/"
options(repos = r)

# Install required packages
install.packages("tidyverse")
install.packages("qqplotr")
install.packages("effsize")
install.packages("showtext")
install.packages("bestNormalize")
