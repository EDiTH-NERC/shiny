# Header ----------------------------------------------------------------
# Project: dash
# File name: 01_data_wrangling.R
# Last updated: 2025-02-04
# Author: Lewis A. Jones
# Email: LewisA.Jones@outlook.com
# Repository: https://github.com/LewisAJones/dash

# Load libraries and options --------------------------------------------
library(palaeoverse)
library(dplyr)
library(stringr)
source("./R/options.R")

# Load data -------------------------------------------------------------
occdf <- readRDS(paste0("data/raw/", params$file_name, ".RDS"))
bins <- readRDS("./data/stages.RDS")

# Geographic filtering --------------------------------------------------
occdf <- occdf %>% 
  filter(lng > params$xlim[1] & lng < params$xlim[2]) %>%
  filter(lat > params$ylim[1] & lat < params$ylim[2])

# Data cleaning ---------------------------------------------------------
occdf$genus <- sub(pattern = " .*", replacement = "", occdf$genus)

# Temporal binning ------------------------------------------------------
# Use the majority method
occdf <- bin_time(occdf = occdf, bins = bins, method = params$method)
# Remove data which do not hit the majority threshold (params$threshold)
occdf <- occdf %>%
  filter(occdf$overlap_percentage > params$threshold)

# Taxonomy -------------------------------------------------------------
# Extract genus (genus column contains instances of NO_GENUS_SPECIFIED)
occdf$genus <- word(occdf$accepted_name, 1)
occdf$accepted_rank[which(occdf$accepted_rank == "subgenus")] <- "genus"
# Drop subspecies IDs
# Remove subgenus in brackets
occdf$species <- occdf$accepted_name
occdf$species <- gsub("\\s*\\([^\\)]+\\)", "",
                      as.character(occdf$species))
# Extract species names (in case of subspecies)
occdf$species <- word(occdf$species, start = 2, end = 2)
occdf$accepted_rank[which(occdf$accepted_rank == "subspecies")] <- "species"
# Join genus and species name
occdf$binomial <- paste(occdf$genus, occdf$species)
# Set non-species level IDs to NA
occdf$binomial[which(is.na(occdf$species))] <- NA
# Replace species column
occdf$species <- occdf$binomial
# Drop binomial column
occdf <- occdf %>%
  select(-binomial)
# Standardise missing data
occdf$phylum[which(occdf$phylum == "NO_PHYLUM_SPECIFIED")] <- NA
occdf$class[which(occdf$class == "NO_CLASS_SPECIFIED")] <- NA
occdf$order[which(occdf$order == "NO_ORDER_SPECIFIED")] <- NA
occdf$family[which(occdf$family == "NO_FAMILY_SPECIFIED")] <- NA
occdf$genus[which(occdf$genus == "NO_GENUS_SPECIFIED")] <- NA

# Palaeorotate occurrences ----------------------------------------------
occdf <- palaeorotate(occdf = occdf,
                      lng = params$lng,
                      lat = params$lat,
                      age = params$age,
                      model = params$GPM,
                      method = "point",
                      uncertainty = FALSE,
                      round = NULL)
# Exclude occurrences which palaeocoordinates could not be estimated for
occdf <- occdf %>%
  filter(!is.na(occdf$p_lat) & !is.na(occdf$p_lng))

# Format data -----------------------------------------------------------
# Join age information
occdf <- occdf %>%
  select(-c(max_ma, min_ma)) %>%
  inner_join(x = ., y = bins, by = c("bin_assignment" = "bin"))
# Filter to desired columns
occdf <- occdf %>%
  select(collection_no, cc, lng, lat, formation, interval_name, max_ma, min_ma, 
         occurrence_no, family, genus, species, accepted_rank,
         abbr, colour, font) %>%
  arrange(desc(max_ma))
# Summarise per collection
colldf <- occdf %>%
  group_by(collection_no) %>%
  summarise(cc = unique(cc),
            lng = unique(lng),
            lat = unique(lat),
            formation = unique(formation),
            interval_name = unique(interval_name),
            max_ma = unique(max_ma),
            min_ma = unique(min_ma),
            genera = toString(sort(unique(genus))),
            abbr = unique(abbr),
            colour = unique(colour),
            font = unique(font)) %>%
  arrange(desc(max_ma))
# Save occurrence data
occdf$region <- "Caribbean"
occdf$mid_ma <- (occdf$max_ma + occdf$min_ma) /2
occdf$cc[which(occdf$cc == "")] <- "NOT_SPECIFIED"
saveRDS(object = occdf, file = paste0("data/PBDB.RDS"))
