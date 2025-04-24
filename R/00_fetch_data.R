# Header ----------------------------------------------------------------
# Project: shiny
# File name: 00_fetch_data.R
# Last updated: 2025-04-19
# Author: Lewis A. Jones
# Email: LewisA.Jones@outlook.com
# Repository: https://github.com/LewisAJones/shiny

# Load libraries and options --------------------------------------------
library(RCurl)
library(httr)
library(palaeoverse)
library(dplyr)
source("./R/options.R")

# Data downloading from PBDB --------------------------------------------
if (params$download || !file.exists(paste0("data/raw/", params$file_name, ".RDS"))) {
  # Use for fresh downloads
  RCurl::curlSetOpt(3000)
  # Read data 
  url <- httr::modify_url(url = params$base_url, query = params$query)
  occdf <- RCurl::getURL(url = url, ssl.verifypeer = FALSE)
  occdf <- read.csv(textConnection(occdf))
  # Save raw data
  saveRDS(occdf, paste0("data/raw/", params$file_name, ".RDS"))
} else {
  # Read data
  occdf <- readRDS(paste0("data/raw/", params$file_name, ".RDS"))
}

# Get time bins --------------------------------------------------------
bins <- time_bins(interval = "Phanerozoic",
                  rank = params$rank,
                  scale = params$GTS)
# Filter to Cenozoic
bins <- bins %>% 
  filter(min_ma < 66)
# Collapse Holocene equivalent bins
vec <- which(bins$interval_name == "Greenlandian")
bins$interval_name[vec] <- "Holocene"
bins$abbr[vec] <- "H"
# Update min_ma
bins$min_ma[vec] <- 0.0000
# Update mid_ma
bins$mid_ma[vec] <- (bins$min_ma[vec] + bins$max_ma[vec]) / 2
# Update duration
bins$duration_myr[vec] <- (bins$max_ma[vec] - bins$min_ma[vec])
# Drop rows
bins <- bins[-which(bins$interval_name %in% c("Meghalayan", "Northgrippian")), ]
# Collapse Pleistocene equivalent bins
# Drop bins
pleis <- c("Late Pleistocene", "Chibanian", "Calabrian")
bins <- bins[-which(bins$interval_name %in% pleis), ]
# update Gelasian to be all of the Pleistocene
vec <- which(bins$interval_name == "Gelasian")
bins$interval_name[vec] <- "Pleistocene"
# Update min_ma
bins$min_ma[vec] <- bins[which(bins$interval_name == "Holocene"), "max_ma"]
# Update mid_ma
bins$mid_ma[vec] <- (bins$min_ma[vec] + bins$max_ma[vec]) / 2
# Update duration
bins$duration_myr[vec] <- (bins$max_ma[vec] - bins$min_ma[vec])
# Update bin numbers
bins$bin <- 1:nrow(bins)
row.names(bins) <- 1:nrow(bins)
# Save time bins
saveRDS(object = bins, file = "data/stages.RDS")

