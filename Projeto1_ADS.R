#Chamando as bibliotecas
library(ggthemes)
library(dplyr)
library(stringr)
library(tidyverse)
library (readr)

#-------------------------------Pré-processamento-------------------------------

#Importa os dados
estimativa_populacao <- read.csv("ibge_cnv_pop.csv", header=TRUE, sep = ";")
Casos_C16_UF <- read.csv("PAINEL_ONCOLOGIABR16.csv", header=TRUE, sep = ";")
Obitos_C16 <- read.csv("obito_C16_2013_2021.csv", header=TRUE, sep = ";")

#Exclui uma linha em branco da estimativa_polulacao - o que não é desejável
estimativa_populacao <- estimativa_populacao |>
  filter(!if_any(1, is.na))

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

#----------------------Deixando os dados no formato longo-----------------------

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

# 3) Mapear cada Unidade Federativa na região pertecente, calcular as taxas selecionar as colunas
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

#Converter 'ano' para numérico
Taxa_de_C16 <- Taxa_de_C16 |>
  mutate(ano = as.numeric(ano))

# Visualizar o resultado
summary(Taxa_de_C16)
View(Taxa_de_C16)

#------------------------Criando e analisando os gráficos-----------------------

# Sumário estatístico por variável
Taxa_de_C16 |>
  summarize(
    min_diag = min(taxa_diagnosticos),
    median_diag = median(taxa_diagnosticos),
    mean_diag = mean(taxa_diagnosticos),
    max_diag = max(taxa_diagnosticos),
    min_obito = min(taxa_obitos),
    median_obito = median(taxa_obitos),
    mean_obito = mean(taxa_obitos),
    max_obito = max(taxa_obitos)
  )

#-------------------------------------------------------------------------------
#Evolução da Taxa de Diagnóstico no Brasil
rn_data <- Taxa_de_C16 |> 
  filter(`Unidade da Federação` == "Total")

ggplot(rn_data, aes(x = ano, y = taxa_diagnosticos)) +
  geom_line(color = "darkgreen") +
  geom_point(color = "darkgreen") +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(title = "Taxa de Diagnósticos de C16 - Brasil (2013-2021)",
       x = "Ano", y = "Taxa de Diagnóstico (por 100.000 hab.)") +
  scale_x_continuous(breaks = seq(min(rn_data$ano, na.rm = TRUE), max(rn_data$ano, na.rm = TRUE), by = 1)) +
  theme_minimal()
#-------------------------------------------------------------------------------
#Evolução da Taxa de óbito no Brasil
dados_brasil_obitos <- Taxa_de_C16 |>
  filter(`Unidade da Federação` == "Total")

# Gráfico da evolução temporal da taxa de óbitos para o Brasil
ggplot(dados_brasil_obitos, aes(x = ano, y = taxa_obitos)) +
  geom_line(color = "firebrick", linewidth = 1) + 
  geom_point(color = "firebrick", size = 2.5, shape=21, fill="white", stroke=1.5) +
  geom_smooth(method = "lm", se = FALSE, color = "dodgerblue", linetype = "dashed") +
  scale_x_continuous(breaks = seq(min(dados_brasil_obitos$ano, na.rm = TRUE),
                                  max(dados_brasil_obitos$ano, na.rm = TRUE), by = 1)) + 
  labs(title = "Evolução da Taxa de Óbitos por C16 no Brasil",
       subtitle = "Neoplasia maligna do estômago (2013-2021)",
       x = "Ano",
       y = "Taxa de Óbitos (por 100.000 habitantes)") +
  theme_minimal(base_size = 14) +
  theme(plot.title = element_text(hjust = 0.5), 
        plot.subtitle = element_text(hjust = 0.5))

#-------------------------------------------------------------------------------
# Cálculo da média por UF
top10_diag <- Taxa_de_C16 |>
  group_by(`Unidade da Federação`) |>
  summarize(média_diag = mean(taxa_diagnosticos)) |>
  arrange(desc(média_diag)) |>
  slice_head(n = 10)

# Gráfico de barras
ggplot(top10_diag, aes(x = reorder(`Unidade da Federação`, média_diag), y = média_diag)) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Top 10 UFs por Média da Taxa de Diagnóstico (2013–2021)",
    x = "UF",
    y = "Média de casos por 100.000"
  ) +
  theme_minimal()
#-------------------------------------------------------------------------------
# Heatmap da Taxa Média de Diagnóstico por Região e Ano
serie_regiao <- Taxa_de_C16 |>
  filter(!is.na(regiao) & regiao != "Brasil") |>
  group_by(regiao, ano) |>
  summarise(taxa_media = mean(taxa_diagnosticos), .groups = "drop")

ggplot(serie_regiao, aes(x = factor(ano), y = regiao, fill = taxa_media)) +
  geom_tile(color = "white") +
  geom_text(aes(label = round(taxa_media, 1)), size = 3) +
  scale_fill_viridis_c(option = "C") +
  labs(
    title    = "Heatmap da Taxa Média de Diagnóstico por Região e Ano",
    subtitle = "Neoplasia maligna do estômago (2013–2021)",
    x        = "Ano",
    y        = "Região",
    fill     = "Taxa média\n(diagnósticos)"
  ) +
  theme_minimal(base_size = 14)

#-------------------------------------------------------------------------------
# Heatmap da Taxa Média de Óbitos por Região e Ano
serie_obitos_regiao <- Taxa_de_C16 |>
  filter(!is.na(regiao) & regiao != "Brasil") |>
  group_by(regiao, ano) |>
  summarise(taxa_media = mean(taxa_obitos), .groups = "drop")

ggplot(serie_obitos_regiao, aes(x = factor(ano), y = regiao, fill = taxa_media)) +
  geom_tile(color = "white") +
  geom_text(aes(label = round(taxa_media, 1)), size = 3) +
  scale_fill_viridis_c(option = "C") +
  labs(
    title    = "Heatmap da Taxa Média de Óbitos por Região e Ano",
    subtitle = "Neoplasia maligna do estômago (2013–2021)",
    x        = "Ano",
    y        = "Região",
    fill     = "Taxa média\n(óbitos)"
  ) +
  theme_minimal(base_size = 14)

#-------------------------------------------------------------------------------
# Taxa média de diagnósticos por região (2013-2021)
media_regiao_diagnosticos <- Taxa_de_C16 |>
  filter(regiao != "Brasil" & !is.na(regiao)) |>
  group_by(regiao) |>
  summarise(
    media_taxa_diagnosticos = mean(taxa_diagnosticos, na.rm = TRUE),
    media_taxa_obitos = mean(taxa_obitos, na.rm = TRUE)
  ) |>
  arrange(desc(media_taxa_diagnosticos))
print(media_regiao_diagnosticos)

# Gráfico de barras para comparar regiões
ggplot(media_regiao_diagnosticos, aes(x = reorder(regiao, -media_taxa_diagnosticos), y = media_taxa_diagnosticos)) +
  geom_bar(stat = "identity", fill = "skyblue") +
  geom_text(aes(label = round(media_taxa_diagnosticos, 1)), vjust = -0.5) +
  labs(title = "Média da Taxa de Diagnósticos de C16 por Região (2013-2021)",
       x = "Região", y = "Taxa Média de Diagnóstico (por 100.000 hab.)") +
  theme_classic()

media_uf_diagnosticos <- Taxa_de_C16 |>
  filter(regiao != "Brasil" & !is.na(regiao)) |>
  group_by(`Unidade da Federação`, regiao) |>
  summarise(
    media_taxa_diagnosticos = mean(taxa_diagnosticos, na.rm = TRUE),
    media_taxa_obitos = mean(taxa_obitos, na.rm = TRUE)
  ) |>
  arrange(desc(media_taxa_diagnosticos)) |>
  ungroup()

top_10_uf <- media_uf_diagnosticos |> 
  slice_max(order_by = media_taxa_diagnosticos, n = 10)

top_10_uf_obitos <- media_uf_diagnosticos |> 
  slice_max(order_by = media_taxa_obitos, n = 10)


#-------------------------------------------
media_regiao_obitos_corrigido <- Taxa_de_C16 |>
  filter(regiao != "Brasil" & !is.na(regiao)) |>
  group_by(regiao) |>
  summarise(
    media_taxa_diagnosticos = mean(taxa_diagnosticos, na.rm = TRUE),
    media_taxa_obitos = mean(taxa_obitos, na.rm = TRUE)
  ) |>
  arrange(desc(media_taxa_obitos))

print(media_regiao_obitos_corrigido)

# Gráfico de barras para comparar a média da taxa de óbitos por região
ggplot(media_regiao_obitos_corrigido, aes(x = reorder(regiao, -media_taxa_obitos), y = media_taxa_obitos)) +
  geom_bar(stat = "identity", fill = "tomato3", color = "black") +
  geom_text(aes(label = round(media_taxa_obitos, 2)), vjust = -0.5, size = 3.5) +
  labs(title = "Média da Taxa de Óbitos por C16 por Região (2013-2021)",
       x = "Região",
       y = "Taxa Média de Óbitos (por 100.000 habitantes)") +
  theme_minimal(base_size = 12) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
#-------------------------------------------------------------------------------

cores_regioes <- c(
  "Norte"        = "#E69F00",
  "Nordeste"     = "#009E73",
  "Centro-Oeste" = "#56B4E9",
  "Sudeste"      = "#F0E442",
  "Sul"          = "#D55E00"
)

# Top 10 UFs por diagnóstico
ggplot(top_10_uf, aes(x = reorder(`Unidade da Federação`, -media_taxa_diagnosticos), 
                      y = media_taxa_diagnosticos, 
                      fill = regiao)) +
  geom_bar(stat = "identity", color = "black") +
  geom_text(aes(label = round(media_taxa_diagnosticos, 2)), 
            vjust = -0.5, size = 3.5) +
  scale_fill_manual(values = cores_regioes) +
  labs(
    title    = "Top 10 UFs por Média da Taxa de Diagnósticos de C16 (2013–2021)",
    subtitle = "Neoplasia maligna do estômago",
    x        = "Unidade da Federação",
    y        = "Taxa Média de Diagnóstico (por 100.000 hab.)",
    fill     = "Região"
  ) +
  theme_classic(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))



#-------------------------------------------------------------------------------
# top 10 UFS por óbito
ggplot(top_10_uf_obitos, aes(x = reorder(`Unidade da Federação`, -media_taxa_obitos), 
                             y = media_taxa_obitos, 
                             fill = regiao)) +
  geom_bar(stat = "identity", color = "black") +
  geom_text(aes(label = round(media_taxa_obitos, 2)), 
            vjust = -0.5, size = 3.5) +
  scale_fill_manual(values = cores_regioes) +
  labs(
    title    = "Top 10 UFs por Média da Taxa de Óbitos por C16 (2013–2021)",
    subtitle = "Neoplasia maligna do estômago",
    x        = "Unidade da Federação",
    y        = "Taxa Média de Óbitos (por 100.000 hab.)",
    fill     = "Região"
  ) +
  theme_classic(base_size = 14) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))


