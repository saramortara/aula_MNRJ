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
dwc <- dwca_read(url)

names(dwc)

# 1.2. Informações básicas: ----
## Caminho onde estão os arquivos
file_path <- dirname(dwc$data[1])
## Data de atualização da base de dados
last_update <- dwc$emlmeta$additionalMetadata$metadata$gbif$dateStamp
## Citação
cite <- dwc$emlmeta$additionalMetadata$metadata$gbif$citation$citation

# 1.3. Carregando os dados para o R ----
taxon <- read_delim(dwc$data[[1]], "\t", escape_double = FALSE, trim_ws = TRUE)
typeandspecimen <- read_delim(dwc$data[[2]], "\t", escape_double = FALSE, trim_ws = TRUE)
distribution <- read_delim(dwc$data[[3]], "\t", escape_double = FALSE, trim_ws = TRUE)
description <- read_delim(dwc$data[[4]], "\t", escape_double = FALSE, trim_ws = TRUE)
speciesprofile <- read_delim(dwc$data[[5]],  "\t", escape_double = FALSE, trim_ws = TRUE)

# 2. Inspeção dos dados --------------------------------------------------------

# 2.1. Taxon ----
glimpse(taxon)
View(taxon)

# Classes
taxon %>%
  group_by(class) %>%
  summarise(N = n())

# Ordens
taxon %>%
  group_by(order) %>%
  summarise(N = n())

# Para ordenar pelo N em cada ordem
taxon %>%
  group_by(order) %>%
  summarise(N = n()) %>%
  arrange(N)

# Checagem da ordem incertae sedis
taxon %>%
  filter(order == "incertae sedis") %>%
  select(family, scientificName)

# Quantas espécies
taxon %>%
  select(scientificName) %>%
  distinct() %>%
  nrow()

dim(taxon)

# 2.2. Outras tabelas ----

# Referências das espécies e espécimes
View(typeandspecimen)

# Distribuição
View(distribution)
## coluna establishmentMeans
unique(distribution$establishmentMeans)

# Descrição
View(description)

sort(unique(description$description))
unique(description$type)

# Perfil da espécie
View(speciesprofile)
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
  select(id, order, family, genus, scientificName)

# 3.2. Juntando toda a tabela de taxon ----
taxon_distr <- left_join(taxon_new, endemic, by = "id")
head(taxon_distr)

# 3.3. Juntando apenas espécies endêmicas ----
taxon_end <- left_join(endemic, taxon_new, by = "id")

dim(taxon_distr)
dim(taxon_end)
