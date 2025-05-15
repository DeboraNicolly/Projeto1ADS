library (readr)

Sys.setlocale("LC_ALL","pt_BR.UTF-8")

estimativa_populacao <- read.csv("ibge_cnv_poptuf152625177_20_136_208.csv", header=TRUE, sep = ";")
Casos_C16_UF <- read.csv("PAINEL_ONCOLOGIABR17473335525.csv", header=TRUE, sep = ";")

View(estimativa_populacao)
View(Casos_C16_UF)
