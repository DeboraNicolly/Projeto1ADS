#Chamando as bibliotecas
library(dplyr)
library(stringr)
library(tidyverse)
library (readr)

#Importa os dados
estimativa_populacao <- read.csv("ibge_cnv_poptuf152625177_20_136_208.csv", header=TRUE, sep = ";")
Casos_C16_UF <- read.csv("PAINEL_ONCOLOGIABR17473335525.csv", header=TRUE, sep = ";")
Obitos_C16 <- read.csv("obito_C16_2013_2021.csv", header=TRUE, sep = ";")

#Exclui uma linha em branco da estimativa_polulacao - o que não é desejável
estimativa_populacao <- estimativa_populacao[-29, ]

#Exclui a coluna de Total por estado de Obitos_C16 e Casos_C16_UF, o que não será utilizado na análise
Obitos_C16 <- Obitos_C16 |> select(-"Total")
Casos_C16_UF <- Casos_C16_UF |> select(-"X.Total")

#Define o nome das variáveis
variaveis = c("Unidade da Federação", as.character(2013:2021))

#Renomear o nome das variáveis
colnames(estimativa_populacao) <- variaveis
colnames(Casos_C16_UF) <- variaveis
colnames(Obitos_C16)<- variaveis

#Retira o número da frente das UFs
estimativa_populacao <- estimativa_populacao |>
  mutate(`Unidade da Federação` = str_remove(`Unidade da Federação`, "^\\d+\\s+"))

Casos_C16_UF <- Casos_C16_UF |>
  mutate(`Unidade da Federação` = str_remove(`Unidade da Federação`, "^\\d+\\s+"))

Obitos_C16 <- Obitos_C16 |>
  mutate(`Unidade da Federação` = str_remove(`Unidade da Federação`, "^\\d+\\s+"))

#Deixando os dados no formato longo

#vetor por ano
anos <- as.character(2013:2021)


#Pivota cada base para long
pop_long <- estimativa_populacao |>
  pivot_longer(all_of(anos), names_to = "ano", values_to = "pop")

casos_long <- Casos_C16_UF |>
  pivot_longer(all_of(anos), names_to = "ano", values_to = "casos")

obitos_long <- Obitos_C16 |>
  pivot_longer(all_of(anos), names_to = "ano", values_to = "obitos")

# 2) Unir as três bases long
Taxa_de_C16 <- casos_long |>
  left_join(obitos_long, by = c("Unidade da Federação", "ano")) |>
  left_join(pop_long,   by = c("Unidade da Federação", "ano"))

# 3) Mapear estado → região, calcular taxas e selecionar colunas finais
Taxa_de_C16 <- Taxa_de_C16 |>
  mutate(
    regiao = case_when(
      `Unidade da Federação` %in% c("Acre", "Amapa", "Amazonas", "Para", "Rondonia", "Roraima", "Tocantins") ~ "Norte",
      `Unidade da Federação` %in% c("Alagoas", "Bahia", "Ceara", "Maranhao", "Paraiba", "Pernambuco", "Piaui", "Rio Grande do Norte", "Sergipe") ~ "Nordeste",
      `Unidade da Federação` %in% c("Distrito Federal", "Goias", "Mato Grosso", "Mato Grosso do Sul") ~ "Centro-Oeste",
      `Unidade da Federação` %in% c("Espirito Santo", "Minas Gerais", "Rio de Janeiro", "Sao Paulo") ~ "Sudeste",
      `Unidade da Federação` %in% c("Parana", "Rio Grande do Sul", "Santa Catarina") ~ "Sul",
      `Unidade da Federação` %in% ("Total") ~ "Brasil",
      TRUE ~ NA_character_
    ),
    taxa_diagnosticos = round(casos  / pop * 100000, 2),
    taxa_obitos       = round(obitos / pop * 100000, 2)
  ) |>
  select(`Unidade da Federação`, taxa_diagnosticos, taxa_obitos, ano, regiao)

# Visualizar o resultado
View(Taxa_de_C16)
