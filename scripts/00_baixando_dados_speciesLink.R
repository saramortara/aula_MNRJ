# Script para download de dados do speciesLink

#remotes::install_github("Rocc")
library(Rocc)

# 1. Download a partir do speciesLink ------------------------------------------

species <- "Harpia harpyja"

occ_splink <-  rspeciesLink(species = species, save = FALSE)

write.csv(occ_splink, "data/raw/harpia/00_Harpia_harpyja.csv")
