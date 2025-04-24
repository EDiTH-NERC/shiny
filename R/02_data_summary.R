# Header ----------------------------------------------------------------
# Project: dash
# File name: 02_data_summary.R
# Last updated: 2025-02-04
# Author: Lewis A. Jones
# Email: LewisA.Jones@outlook.com
# Repository: https://github.com/LewisAJones/dash

# Load libraries and options --------------------------------------------
library(dplyr)
library(tidyr)
library(vegan)
source("./R/options.R")

# Load data -------------------------------------------------------------
occdf <- readRDS("data/PBDB.RDS")

# Sampling --------------------------------------------------------------
sampling <- occdf %>%
  mutate(Age = (max_ma + min_ma) / 2) %>%
  group_by(interval_name, Age) %>%
  summarise(Collections = length(unique(collection_no)),
            Formations = length(unique(formation)),
            Countries = length(unique(cc))) %>%
  arrange(desc(Age)) %>%
  mutate(Age = round(x = Age, digits = 3)) %>%
  pivot_longer(cols = Collections:Countries, 
               names_to = "Field", values_to = "Count") %>%
  mutate(`Age (Ma)` = Age)

# Save sampling data
saveRDS(object = sampling, file = paste0("data/stats/sampling.RDS"))

# Collector's curve -----------------------------------------------------
m <- occdf %>%
  group_by(collection_no, genus) %>%
  summarise(n = n()) %>%
  pivot_wider(names_from = genus, values_from = n, values_fill = 0)
m <- data.frame(m[-1])
specaccum(comm = m)

# Diversity -------------------------------------------------------------


# Diversification -------------------------------------------------------


