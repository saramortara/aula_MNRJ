# Script para checagem taxonomica

# Carregando pacotes
library(dplyr)
library(rgbif)

# Lendo os dados
data <- read.csv("data/processed/01-endemic_fishes.csv")

head(data)

# 1. Checagem taxonomica usando gbif -------------------------------------------
spp <- data$scientificName

# Rodando a função de checagem taxonômica para cada nome (demora....)
spp_check <- lapply(spp, name_backbone)

# Juntando os elementos da lista em um data frame
spp_df <- bind_rows(spp_check) %>%
  mutate(search_spp = spp)

head(spp_df)

# Qual o status dos nomes?
table(spp_df$status)

# 2. Selecionando apenas especies com problemas --------------------------------

spp_problems <- spp_df %>%
  filter(status %in% c("SYNONYM", "DOUBTFUL")) %>%
  select(search_spp, canonicalName, rank, status) %>%
  as.data.frame()

dim(spp_problems)

View(spp_problems)

# 3. Adicionando coluna com status dos nomes -----------------------------------
