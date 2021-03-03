# Script para limpeza geográfica

library(dplyr)
library(CoordinateCleaner)

# 1. Lendo os dados ------------------------------------------------------------
occ_raw <- read.csv("data/raw/harpia/00_Harpia_harpyja.csv")

# 2. Removendo coordenadas com NA ----------------------------------------------
occ <- occ_raw %>%
  filter(!is.na(decimalLongitude), !is.na(decimalLatitude))

# 3. Checagem de coordenadas ---------------------------------------------------
occ_clean <- clean_coordinates(occ,
                               lon = "decimalLongitude",
                               lat = "decimalLatitude",
                               species = "scientificName")


occ_clean %>% filter(.summary)
