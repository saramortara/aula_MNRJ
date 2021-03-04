# Script para limpeza taxonomica usando dados de colecao
## Dados da Ictiologia MNRJ baixado em: https://ala-hub.sibbr.gov.br/ala-hub/occurrences/search?q=collection_uid:co101

# Carregando pacotes necessários
library(dplyr)
library(ggplot2)

# 1. Lendo os dados ------------------------------------------------------------
dados <- read.csv("data/raw/ictio_MNRJ/ictio_MNRJ.csv")

# Checando as dimensões (linhas, colunas)
dim(dados)

# quantas especies?
dados %>%
  filter(Taxon.Rank == "species") %>%
  distinct(Scientific.Name) %>%
  nrow()

# quantos generos?
dados %>%
  distinct(Genus) %>%
  nrow()

# quantas familias?
length(unique(dados$Family))

# quantos registros ao longo do tempo?
records <- dados %>%
  group_by(Year) %>% # agrupa por ano
  summarise(N = n()) %>%  # conta quantos registros por ano
  filter(!is.na(Year)) %>% # remove NA
  mutate(Year = as.Date(ISOdate(Year, 1, 1))) # formata o ano como data

# Gráfico de N de registros ao longo do tempo
ggplot(data = records, aes(x = Year, y = N)) +
  geom_point() +
  geom_line() +
  labs(x = "Ano", y = "Número de registros",
       title = "Registros da coleção de Ictiologia do MNRJ") +
  theme_minimal()

ggsave("figs/03-registros_ictio_MNRJ.png")

# 2. Selecionando apenas um grupo ----------------------------------------------
# gênero Astyanax
grupo <- dados %>%
  filter(Genus == "Astyanax")

# quantas especies?
length(unique(grupo$Scientific.Name))

write.csv(grupo, "data/processed/03-Astyanax_MNRJ.csv", row.names = FALSE)
