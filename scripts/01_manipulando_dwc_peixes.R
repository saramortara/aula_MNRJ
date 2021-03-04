# Script para download automatizado do checklist de espécies de peixes da Colômbia
# artigo: https://zookeys.pensoft.net/article/13897/
# dados: https://ipt.biodiversidad.co/sib/resource?r=ictiofauna_colombiana_dulceacuicola
# formato DwC: https://dwc.tdwg.org/terms/

# Carregando pacotes necessários
library(finch)
library(dplyr)

# 1. Baixando os dados ---------------------------------------------------------

# Endereço do arquivo
url <- "https://ipt.biodiversidad.co/sib/archive.do?r=ictiofauna_colombiana_dulceacuicola&v=2.12"

# 1.1. Lendo o arquivo a partir do endereço ----
dwc <- dwca_read(url, read = TRUE)

names(dwc)

# 1.2. Informações básicas: ----
## Caminho onde estão os arquivos
file_path <- dirname(dwc$files$data_paths[1])
## Metadados
dwc$highmeta
## Data de atualização da base de dados
last_update <- dwc$emlmeta$additionalMetadata$metadata$gbif$dateStamp
## Citação
cite <- dwc$emlmeta$additionalMetadata$metadata$gbif$citation$citation

# 2. Inspeção dos dados --------------------------------------------------------

# Guardando dados em objetos
taxon <- dwc$data$taxon.txt
typeandspecimen <- dwc$data$typesandspecimen.txt
distribution <- dwc$data$distribution.txt
description <- dwc$data$description.txt
speciesprofile <- dwc$data$speciesprofile.txt

# 2.1. Taxon ----
glimpse(taxon)
#View(taxon)

table(taxon$taxonRank)

# Classes
taxon %>%
  filter(taxonRank == "Especie") %>%
  group_by(class) %>%
  summarise(N = n())

# Ordens
taxon %>%
  filter(taxonRank == "Especie") %>%
  group_by(order) %>%
  summarise(N = n())

# Para ordenar pelo N em cada ordem
taxon %>%
  filter(taxonRank == "Especie") %>%
  group_by(order) %>%
  summarise(N = n()) %>%
  arrange(N)

# Checagem da ordem incertae sedis
taxon %>%
  filter(taxonRank == "Especie") %>%
  filter(order == "incertae sedis") %>%
  select(family, scientificName)

# Quantas espécies
taxon %>%
  filter(taxonRank == "Especie") %>%
  select(scientificName) %>%
  distinct() %>%
  nrow()

dim(taxon)

# 2.2. Outras tabelas ----

# Referências das espécies e espécimes
#View(typeandspecimen)

# Distribuição
#View(distribution)
## coluna establishmentMeans
unique(distribution$establishmentMeans)

# Descrição
#View(description)

sort(unique(description$description))
unique(description$type)

# Perfil da espécie
#View(speciesprofile)
table(speciesprofile$isFreshwater)

# 3. Juntando duas tabelas de dados --------------------------------------------

# 3.1. Selecionando espécies endêmicas e ameaçadas
# Identificador comum: coluna id

# Lista de espécies endêmicas
endemic <- distribution %>%
  filter(establishmentMeans %in% "Endémico para: Colombia") %>%
  select(id, establishmentMeans)

dim(endemic)

# Lista de espécies ameaçadas
threatened <- distribution %>%
  filter(!is.na(distribution$threatStatus))

dim(threatened)

taxon_new <- taxon %>%
  select(id, order, family, genus, scientificName, taxonRank) %>%
  filter(taxonRank == "Especie")

# 3.2. Juntando toda a tabela de taxon ----
taxon_distr <- left_join(taxon_new, endemic, by = "id")

head(taxon_distr)
dim(taxon_distr)

# 3.3. Juntando apenas espécies endêmicas ----
taxon_end <- left_join(endemic, taxon_new, by = "id")
dim(taxon_distr)
dim(taxon_end)

# mesma tarefa, de uma outra forma:
#taxon_end2 <- right_join(taxon_new, endemic, by = "id")

# 4. Exportando tabelas modificadas para proximos passos
if (!dir.exists("data/processed"))  {dir.create("data/processed", recursive = TRUE)}
write.csv(taxon_end, "data/processed/01-endemic_fishes.csv", row.names = FALSE)

