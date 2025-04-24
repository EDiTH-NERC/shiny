# Header ----------------------------------------------------------------
# Project: dash
# File name: options.R
# Last updated: 2025-02-04
# Author: Lewis A. Jones
# Email: LewisA.Jones@outlook.com
# Repository: https://github.com/LewisAJones/dash

# Define options --------------------------------------------------------
params <- list(
  # Download updated dataset
  download = TRUE,
  # Occurrence file name
  file_name = paste0("PBDB_", Sys.Date()),
  # PBDB base url
  base_url = "https://paleobiodb.org/data1.2/occs/list.csv",
  # PBDB Download options
  query = list(
    base_name = "Scleractinia",
    taxon_reso = "genus",
    ident = "latest",
    taxon_status = "valid",
    idqual = "genus_certain",
    pres = "regular",
    interval = "Danian,Holocene",
    envtype = "marine",
    show = "genus,pres,strat,coll,coords,loc,class"),
  # The geographic extent of study
  xlim = c(-100, -58), 
  ylim = c(6, 35),
  # The geological rank for conducting analyses
  rank = "stage",
  # The Geological Time Scale to be used
  GTS = "international ages",
  # Naming convention for temporal bin midpoint
  age = "bin_midpoint",
  # How should occurrences be temporally binned?
  method = "majority",
  # Threshold for majority binning rule
  threshold = 50,
  # Naming convention for longitude
  lng = "lng",
  # Naming convention for latitude
  lat = "lat",
  # Which GPM should be used for palaeorotations?
  GPM = "MERDITH2021",
  # Download data
  download = TRUE
)
