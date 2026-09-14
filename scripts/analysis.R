#!/usr/bin/env Rscript

# Sourced by energy-actors-trust.qmd.
# Loads data and builds the tables/figures/objects referenced by the
# manuscript's code chunks and inline R.

library(dplyr)
library(tidyr)
library(ggplot2)

energy_actors_data <- read.csv("data/energyActorsDataWeighted.csv")
