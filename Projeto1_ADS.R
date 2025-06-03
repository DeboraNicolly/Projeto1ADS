#Chamando as bibliotecas
library(ggthemes)
library(dplyr)
library(stringr)
library(tidyverse)
library (readr)

#Importa os dados
estimativa_populacao <- read.csv("ibge_cnv_poptuf152625177_20_136_208.csv", header=TRUE, sep = ";")
Casos_C16_UF <- read.csv("PAINEL_ONCOLOGIABR17473335525.csv", header=TRUE, sep = ";")
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

#Converter 'ano' para numérico (faça isso após o pivot_longer)
Taxa_de_C16 <- Taxa_de_C16 |>
  mutate(ano = as.numeric(ano))

# Visualizar o resultado
summary(Taxa_de_C16)
View(Taxa_de_C16)


# Opção B: Gráficos separados (facetas) para cada região
ggplot(Taxa_de_C16 |> filter(regiao != "Brasil" & !is.na(regiao)), 
       aes(x = ano, y = taxa_diagnosticos)) +
  geom_line(color = "steelblue") +
  geom_smooth(method = "lm", se = FALSE, color = "orangered") +
  facet_wrap(~regiao, scales = "free_y") + # 'free_y' permite que cada gráfico tenha sua própria escala y
  labs(
    title = "Taxa de Diagnósticos de Neoplasia Maligna do Estômago por Região",
    subtitle = "Tendência ao longo dos anos (2013-2021)",
    x = "Ano",
    y = "Taxa de Diagnóstico (por 100.000 habitantes)"
  ) +
  scale_x_continuous(breaks = seq(min(Taxa_de_C16$ano, na.rm = TRUE), max(Taxa_de_C16$ano, na.rm = TRUE), by = 2)) +
  theme_light(base_size = 12)

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

# Para UFs, substitua group_by(regiao) por group_by(`Unidade da Federação`)
# e ajuste o filtro para não excluir UFs específicas se não desejar.
media_uf_diagnosticos <- Taxa_de_C16 |>
  filter(regiao != "Brasil" & !is.na(regiao)) |> # Opcional: filtrar UFs que não são "Total"
  group_by(`Unidade da Federação`, regiao) |> # Adicionar regiao aqui pode ser útil para colorir ou facetar
  summarise(
    media_taxa_diagnosticos = mean(taxa_diagnosticos, na.rm = TRUE),
    media_taxa_obitos = mean(taxa_obitos, na.rm = TRUE)
  ) |>
  arrange(desc(media_taxa_diagnosticos)) |>
  ungroup() # desagrupar para visualizações ou próximas manipulações

# Top 10 UFs
top_10_uf <- media_uf_diagnosticos |> slice_max(order_by = media_taxa_diagnosticos, n = 10)
print(top_10_uf)

ggplot(top_10_uf, aes(x = reorder(`Unidade da Federação`, -media_taxa_diagnosticos), y = media_taxa_diagnosticos, fill = regiao)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = round(media_taxa_diagnosticos, 1)), vjust = -0.5, size = 3) +
  labs(title = "Top 10 UFs por Média da Taxa de Diagnósticos de C16 (2013-2021)",
       x = "Unidade da Federação", y = "Taxa Média de Diagnóstico (por 100.000 hab.)", fill="Região") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) # Rotacionar texto do eixo X


#__________________________

Taxa_de_C16 |>
  filter(regiao == "Brasil") |> # Ou outra região/UF
  arrange(desc(taxa_diagnosticos)) |>
  select(ano, taxa_diagnosticos) |>
  head(1) # Ano com maior taxa para o Brasil

#______________________________
# Exemplo para Rio Grande do Norte
rn_data <- Taxa_de_C16 |> 
  filter(`Unidade da Federação` == "Rio Grande do Norte")

ggplot(rn_data, aes(x = ano, y = taxa_diagnosticos)) +
  geom_line(color = "darkgreen") +
  geom_point(color = "darkgreen") +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(title = "Taxa de Diagnósticos de C16 - Rio Grande do Norte (2013-2021)",
       x = "Ano", y = "Taxa de Diagnóstico (por 100.000 hab.)") +
  scale_x_continuous(breaks = seq(min(rn_data$ano, na.rm = TRUE), max(rn_data$ano, na.rm = TRUE), by = 1)) +
  theme_minimal()

#_________________________
