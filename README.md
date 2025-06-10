# 📊 Análise Exploratória de Dados — Neoplasia Maligna do Estômago (C16)

Este repositório apresenta uma análise exploratória da taxa de diagnósticos e óbitos por **neoplasia maligna do estômago (CID-10: C16)** no Brasil, entre os anos de **2013 a 2021**, por Unidade Federativa (UF) e região.

---

## 🧾 Contextualização

A neoplasia maligna do estômago é um tipo de câncer que se desenvolve de forma silenciosa e gradual, sendo frequentemente diagnosticada tardiamente. Apesar de ser mais comum em homens acima de 60 anos, nos últimos anos **houve um aumento expressivo de casos em adultos jovens**, tornando o tema cada vez mais relevante do ponto de vista da saúde pública.

Além disso, esse tipo de câncer possui relação com fatores ambientais, alimentares, bacterianos e genéticos, o que motiva sua investigação estatística em diferentes regiões do país.

---

## 🗂️ Fonte dos Dados

- 🏥 **Casos e óbitos** por UF (2013–2021): obtidos do [DataSUS](http://www2.datasus.gov.br/)
- 👥 **Estimativas populacionais** por UF no mesmo período: retiradas do site do [IBGE](https://www.ibge.gov.br)

---

## 🎯 Objetivos da Análise

- Calcular a **taxa de diagnósticos e óbitos por 100.000 habitantes**.
- Comparar os resultados entre **regiões e estados brasileiros**.
- Verificar se houve crescimento ou redução no tempo.
- Investigar **disparidades regionais**.
- Gerar hipóteses e reflexões para estudos futuros.

---

## ❓ Perguntas Exploradas

- Qual região apresentou a **maior taxa de diagnósticos**? E a **maior taxa de óbitos**?
- Qual **UF** teve os maiores índices de diagnósticos e/ou óbitos?
- Houve aumento significativo ao longo dos anos?
- Por que **Alagoas** teve um aumento tão expressivo em 2021?
- Os estados com mais diagnósticos são os que mais registram mortes?
- A mortalidade diminuiu com o tempo, mesmo com o aumento dos diagnósticos?

---

## 🧱 Estrutura do Dataset

Após o pré-processamento:

- **Linhas:** 252
- **Colunas:** 5
  - `Unidade da Federação`
  - `taxa_diagnosticos` (por 100 mil hab.)
  - `taxa_obitos` (por 100 mil hab.)
  - `ano`
  - `regiao`
- **Unidade de Medida:** taxas por 100.000 habitantes
- **Período:** 2013–2021
- **Dados faltantes:** Nenhum

---

## 📈 Principais Resultados

### 🔍 Análises Univariadas

- A **região Sul** lidera em **taxas de diagnósticos** (8.5).
- A **região Norte** tem as **menores taxas de diagnósticos**, mas **taxas de óbitos elevadas** em comparação.
- **Média geral de diagnósticos:** 4.84 / 100 mil
- **Média geral de óbitos:** 6.33 / 100 mil

### 🔄 Análises Temporais

- Houve um **aumento progressivo** das taxas de diagnóstico ao longo dos anos.
- A taxa de óbitos **se manteve estável ou decresceu levemente** no período analisado.

### 🧮 Top UFs

- 📌 **UFs com maiores taxas de diagnóstico:** Rio Grande do Sul, Alagoas (2021), Mato Grosso do Sul, Goiás.
- 📌 **UFs com maiores taxas de óbito:** estados do Sul e Sudeste.
- Destaque para **Alagoas**, com **crescimento acima de 100% em 2021**.

---

## 🔬 Interpretações e Hipóteses

- O aumento das taxas pode estar associado a **melhorias na detecção precoce**, mas também a **maior incidência real da doença**.
- A disparidade entre diagnósticos e óbitos em algumas regiões sugere **diferenças de acesso ao diagnóstico** ou **qualidade do tratamento**.
- O fato de algumas regiões com menos diagnósticos terem taxas de óbito mais altas pode indicar **subnotificação**, **diagnóstico tardio** ou **baixa estrutura hospitalar**.

---

## 🦠 Sobre o Câncer Gástrico

### 🔍 Fatores de Risco

- Infecção por *Helicobacter pylori*
- Dietas com alimentos industrializados, enlatados, embutidos, peixe cru
- Consumo elevado de corantes artificiais
- Histórico familiar (câncer gástrico hereditário)
- Más condições de higiene alimentar

### ⚠️ Sintomas

- Indigestão
- Náuseas
- Azia persistente
- Perda de peso
- Dificuldade de engolir
- Fezes escuras (sangue oculto)

---

## 💡 Hipóteses e Recomendações Futuras

- A análise sugere investigar **condições socioeconômicas regionais**, **políticas públicas de saúde**, e **disponibilidade de exames como endoscopia**.
- Dados complementares, como faixa etária e sexo, podem aprofundar os insights.
- Recomendável mapear a presença da bactéria *H. pylori* e campanhas de prevenção.

---

## 📊 Gráficos Criados

- Média da taxa de diagnóstico por **região**
- Média da taxa de óbito por **região**
- **Top 10 UFs** por diagnóstico e óbito
- **Série temporal** para Brasil
- **Heatmaps** por ano e região (diagnóstico e óbitos)

---

## 📚 Referências

- [Datasus – Ministério da Saúde](http://www2.datasus.gov.br/)
- [IBGE – Instituto Brasileiro de Geografia e Estatística](https://www.ibge.gov.br)
- Instituto Vencer o Câncer – Artigos sobre Câncer Gástrico
- Portal Dráuzio Varella – Câncer de Estômago

---

> *Análise realizada por Débora Nicolly (UFRN), como parte de um projeto de exploração estatística em saúde pública.*
