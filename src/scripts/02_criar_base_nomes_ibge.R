# ==============================================================================
#  1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF - ACESSO À INFORMAÇÃO
# ==============================================================================
# Script: src/scripts/02_criar_base_nomes_ibge.R
# Objetivo: Lê os CSVs gerados pelo script src/scripts/01_download_nomes_ibge.R,
# unifica em uma base única e salva em formato otimizado (.rds) para consulta
# rápida.
# Data: 2026-01
# ==============================================================================

# ---------------------------- Configuração inicial ---------------------------- 

library(dplyr)
library(readr)
library(stringr)
library(tm)

# ---------------------------- Leitura dos arquivos ---------------------------- 

nomes_br <- read_delim(
  "dados/bruto/nomes_comuns_ibge_brasil_censo_2022.csv",
  delim = ";", locale = locale(decimal_mark = ",", grouping_mark = "."), show_col_types = FALSE)
nomes_df <- read_delim(
  "dados/bruto/nomes_comuns_ibge_df_censo_2022.csv",
  delim = ";", locale = locale(decimal_mark = ",", grouping_mark = "."), show_col_types = FALSE)

sobrenomes_br <- read_delim(
  "dados/bruto/sobrenomes_comuns_ibge_brasil_censo_2022.csv",
  delim = ";", locale = locale(decimal_mark = ",", grouping_mark = "."), show_col_types = FALSE)
sobrenomes_df <- read_delim(
  "dados/bruto/sobrenomes_comuns_ibge_df_censo_2022.csv",
  delim = ";", locale = locale(decimal_mark = ",", grouping_mark = "."), show_col_types = FALSE)

# ---------------------------- Tratamento de dados ----------------------------- 

# Unificação dos arquivos em uma base única, classificando os registros entre
# "nome" e "sobrenome". O motivo de não serem realizadas correções ortográficas,
# ou a exclusão destes casos, é que como o Censo inclui apenas nomes com no
# mínimo 15 ocorrências, assume-se que variações atípicas (que podem ser erros
# de digitação ou nomes raros) podem aparecer em textos de pedidos de acesso à
# informação ou podem ser recorrentes na população. O tratamento final
# restringe-se à seleção de colunas, remoção de duplicatas e ordenação.

# Retirada dos nomes e sobrenomes do DF com menos de 100 registros de
# frequência, para evitar erros como "Piloto", "Juvenil", "Criança" e "Moreno".
# Os nomes e sobrenomes raros serão compensados com a utilização de informações
# provenientes do Portal da Transparência.

nomes_ibge <- nomes_br |> 
  select(nome) |> 
  mutate(tipo = "nome") |> 
  bind_rows(
    nomes_df |> 
      filter(frequencia >= 100) |> 
      select(nome) |> 
      mutate(tipo = "nome")
  ) |> 
  bind_rows(
    sobrenomes_br |> 
      select(nome) |> 
      mutate(tipo = "sobrenome")
  ) |> 
  bind_rows(
    sobrenomes_df |> 
      filter(frequencia >= 100) |> 
      select(nome) |> 
      mutate(tipo = "sobrenome")
  ) |> 
  distinct() |> 
  arrange(tipo, nome)

rm(nomes_br, nomes_df, sobrenomes_br, sobrenomes_df)

# Retirada de nomes que podem levar a falsos positivos. Estes foram
# identificados após análises exploratórias para identificação de nomes
# utilizando as solicitações do FalaBR.


nomes_ibge <- nomes_ibge |> 
  # Remove stopwords da própria lista do IBGE (limpeza preventiva)
  filter(!nome %in% stopwords("pt")) |> 
  # Adiciona blacklist manual de coisas que o IBGE jura que é nome
  filter(nchar(nome) > 2) |> 
  filter(!nome %in% c("aba", "abad", "abade", "boa", "dia", "tarde", "para", 
                      "pelo", "solicito", "piloto", "interno","juvenil",
                      "informado", "nao", "adulto", "informar", "senhor", "bom", 
                      "nova")) |>  
  mutate(nome = str_to_title(nome)) |> 
  filter(!nome %in% c("Sao", "Brasil", "Brasilia", "Saude", "Responsavel", 
                      "Rio", "Grande", "Durante", "Tempo", "Cidade", "Datas", 
                      "Pais", "Areas")) |> 
  distinct()

# ---------------------------- Exportação dos dados ---------------------------- 

# Criação da pasta de output se ela ainda não existir.
if (!dir.exists("dados/processado")) {
  dir.create("dados/processado")
}

saveRDS(nomes_ibge, "dados/processado/nomes_ibge_2022.rds")

# ---------------------------------- Outputs -----------------------------------
#
# Arquivo criado:
#                 dados/processado/nomes_ibge_2022.rds
#
# ------------------------------------------------------------------------------
#                                 Próximo passo 
# ------------------------------------------------------------------------------
# A) Para avaliação da solução:
#     src/scripts/05_classificar_textos.R
#
# B) Para reconstrução completa do projeto:
#     src/scripts/03_criar_base_nomes_transparencia_df.R
# ------------------------------------------------------------------------------