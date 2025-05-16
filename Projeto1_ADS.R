library(tidyverse)
library (readr)

Sys.setlocale("LC_ALL","pt_BR.UTF-8")

estimativa_populacao <- read.csv("ibge_cnv_poptuf152625177_20_136_208.csv", header=TRUE, sep = ";")
Casos_C16_UF <- read.csv("PAINEL_ONCOLOGIABR17473335525.csv", header=TRUE, sep = ";")

#Excluindo colunas da estimativa_polulacao - uma em branco e uma com o total por ano, o que não é desejável
estimativa_populacao <- estimativa_populacao[-c(28, 29), ]

# ESTÁ DANDO ERRO
#Criando a variável total em estimativa_populacao
estimativa_populacao["Total"]<- estimativa_populacao |>
  mutate(sum = rowSums(across(c("X2013", "X2014", "X2015", "X2016", "X2017", "X2018", "X2019", "X2020", "X2021"))))

variaveis = c("Unidade da Federação", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020", "2021", "Total")

#Renomear o nome das variáveis
colnames(estimativa_populacao) <- variaveis
colnames(Casos_C16_UF) <- variaveis

View(estimativa_populacao)
View(Casos_C16_UF)
