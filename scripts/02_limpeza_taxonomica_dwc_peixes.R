# Script para checagem taxonomica dos dados dos peixes endêmicos da Colômbia
## a partir dos dados processados gerados no script 01

# Carregando pacotes
library(dplyr)
library(rgbif)

# Lendo os dados
data <- read.csv("data/processed/01-endemic_fishes.csv")

head(data)

# 1. Checagem taxonomica usando gbif -------------------------------------------
spp <- data$scientificName

# Rodando a função de checagem taxonômica para cada nome (demora....)
#spp_check_1sp <- name_backbone(spp[1])

# Fazendo um loop para rodar todas as espécies
# Cria uma lista vazia para guardar os resultados do loop
spp_check <- list()

for (i in 1:length(spp)) {
  print(paste0("Species ", i, ": ", spp[i]))
  spp_check[[i]] <- name_backbone(spp[i])
}

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

#View(spp_problems)

# 3. Adicionando coluna com status dos nomes -----------------------------------
check_cols <- spp_df %>%
  select(search_spp, status) %>%
  rename(scientificName = search_spp)

data_flag <- left_join(data, check_cols, by = "scientificName")

write.csv(data_flag, "data/processed/02-endemic_fishes_species_flags.csv")
