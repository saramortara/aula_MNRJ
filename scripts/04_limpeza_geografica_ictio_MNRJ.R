# Script para limpeza de coordenadas dos registros de Astyanax - Ictiologia MNRJ
## dados processados no script 03

# Carregando os pacotes necessários
library(dplyr)
library(CoordinateCleaner)

# Pacotes para mapa - Instalar se quiser rodar a parte 4 do script
library(ggplot2)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)

# Lendo os dados
dados <- read.csv("data/processed/03-Astyanax_MNRJ.csv")

# 1. Selecionando as coordenadas -----------------------------------------------
occs <- dados %>%
  mutate(occ_id = paste0("occ_", sprintf("%03d", 1:nrow(.)))) %>%
  relocate(occ_id)

# 2. Fazendo a checagem com CoordinateCleaner ----------------------------------
occs_check <- clean_coordinates(occs,
                                species = "Scientific.Name",
                                lon = "Longitude",
                                lat = "Latitude")

# Função retorna mensagem de erro, precisa limpar as coordenadas primeiro
summary(occs$Latitude)
summary(occs$Longitude)

occs$valid_coord <- cc_val(occs,
                           lon = "Longitude",
                           lat = "Latitude",
                           value = "flagged")


# Vamos remover as coordenadas invalidas e então executar a função de limpeza
occs_pre_check <- occs %>%
  filter(valid_coord)

occs_check <- clean_coordinates(occs_pre_check,
                                species = "Scientific.Name",
                                lon = "Longitude",
                                lat = "Latitude")

# 3. Juntando novamente os dados checados com a tabela original ----------------

# Criando uma tabela apenas com as colunas de checagem e o ID
check_cols <- occs_check %>%
  select(occ_id, starts_with("."))

# Juntando às flags à tabela original
dados_flag <- left_join(occs, check_cols, by = "occ_id")
dim(occs)
dim(check_cols)
dim(dados_flag)

unique(dados_flag$.summary)

# Exportando os dados
write.csv(dados_flag, "data/processed/04-Astyanax_MNRJ_coordinates_flags.csv", row.names = FALSE)

# 4. Mapa bônus ----------------------------------------------------------------
world <- ne_countries(scale = "medium", returnclass = "sf")

# 4.1. Mapa pré limpeza --------------------------------------------------------
mapa1 <- ggplot() +
  # Adiciona limite do mapa
  geom_sf(data = world) +
  # Adiciona os pontos das especies
  geom_point(data = occs_pre_check, aes(x = Longitude, y = Latitude),
             size = 1) +
  # Rotulos dos eixos
  xlab("") + ylab("") +
  theme_minimal()

mapa1
ggsave("figs/04-Astyanax_coordinates.png")


# 4.2. Mapa com flags ----------------------------------------------------------
occs_ok <- occs_check %>%
  filter(.summary)

occs_flag <- occs_check %>%
  filter(!.summary)

mapa2 <-  ggplot() +
  # Adiciona limite do mapa
  geom_sf(data = world) +
  # Adiciona os pontos das especies
  geom_point(data = occs_ok, aes(x = Longitude, y = Latitude),
             size = 1) +
  geom_point(data = occs_flag, aes(x = Longitude, y = Latitude),
             size = 1,  color = "red") +
  # Rotulos dos eixos
  xlab("") + ylab("") +
  theme_minimal()

mapa2
ggsave("figs/04-Astyanax_coordinates_red_flags.png")
