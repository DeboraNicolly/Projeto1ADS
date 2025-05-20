#Chamando as bibliotecas
library(dplyr)
library(stringr)
library(tidyverse)
library (readr)

#Garante que o R interprete e exiba corretamente acentos, cedilhas e outros símbolos do português do Brasil
Sys.setlocale("LC_ALL","pt_BR.UTF-8")

#Importa os dados
estimativa_populacao <- read.csv("ibge_cnv_poptuf152625177_20_136_208.csv", header=TRUE, sep = ";")
Casos_C16_UF <- read.csv("PAINEL_ONCOLOGIABR17473335525.csv", header=TRUE, sep = ";")

#Exclui uma coluna em branco da estimativa_polulacao - o que não é desejável
estimativa_populacao <- estimativa_populacao[-29, ]

#Criando a variável total em estimativa_populacao
estimativa_populacao <- estimativa_populacao |>
  mutate(sum = rowSums(across(c("X2013", "X2014", "X2015", "X2016", "X2017", "X2018", "X2019", "X2020", "X2021"))))

#Define o nome das variáveis
variaveis = c("Unidade da Federação", as.character(2013:2021), "Total")

#Renomear o nome das variáveis
colnames(estimativa_populacao) <- variaveis
colnames(Casos_C16_UF) <- variaveis

#Retira o número da frente das UFs
estimativa_populacao <- estimativa_populacao |>
  mutate(`Unidade da Federação` = str_remove(`Unidade da Federação`, "^\\d+\\s+"))

Casos_C16_UF <- Casos_C16_UF |>
  mutate(`Unidade da Federação` = str_remove(`Unidade da Federação`, "^\\d+\\s+"))

#Deixando os dados no formato largo

#vetor por ano
anos <- as.character(2013:2021)

#Faz o join incluindo o Total de cada base
df_join <- Casos_C16_UF |>
  left_join(
    estimativa_populacao |>
      select(`Unidade da Federação`, all_of(anos), Total),
    by = "Unidade da Federação",
    suffix = c("_casos", "_pop")
  )

#Calcula as taxas por 100.000 habitantes e arredonda para 2 casas decimais
Taxa_de_C16 <- df_join |>
  transmute(
    `Unidade da Federação`,
    # anos 2013–2021
    across(
      ends_with("_casos"),
      ~ .x / get(str_replace(cur_column(), "_casos$", "_pop")) * 100000,
      .names = "{sub('_casos$', '', .col)}"), Total = Total_casos / Total_pop * 100000) |>
  mutate(across(-`Unidade da Federação`, ~ round(.x, 2)))

#Renomeando a coluna que indica a taxa do valor total
colnames(Taxa_de_C16)[colnames(Taxa_de_C16) == "Total"] <- "Taxa"

#Visualizar os dados
View(estimativa_populacao)
View(Casos_C16_UF)
View(Taxa_de_C16)
