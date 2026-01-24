# ==============================================================================
#  1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF - ACESSO À INFORMAÇÃO
# ==============================================================================
# Script: src/scripts/04_analise_exploratoria_FalaBR.R
# Objetivo: Varredura da ocorrência de nomes e sobrenomes nas solicitações do
# FalaBR para identificar gatilhos de nomes e nomes que podem levar a falsos
# positivos.
# Data: 2026-01
# Nota: Este script não retorna nenhum objeto que seja utilizado na solução,
# apenas insights que foram incorporados na construção da mesma.
# ==============================================================================

# ---------------------------- Configuração inicial ---------------------------- 

library(dplyr)
library(readr)
library(stringi)
library(stringr)
library(tidyr)
library(tidytext)

# ----------------------------- Leitura dos dados ------------------------------ 

## 1. Lista de nomes e sobrenomes do Brasil (top 600) --------------------------

# Estes nomes vêm do Censo IBGE, e foram coletados com o script
# src/scripts/01_download_nomes_ibge.R

nomes_br <- read_csv2("dados/bruto/nomes_comuns_ibge_brasil_censo_2022.csv")
sobrenomes_br <- read_csv2("dados/bruto/sobrenomes_comuns_ibge_brasil_censo_2022.csv")

## 2. Textos de solicitação da LAI do FalaBR -----------------------------------

# Solicitações de 2025 em formato CSV
# Arquivo disponível em: https://buscalai.cgu.gov.br/DownloadDados/DownloadDados
# Acessado em 12 de janeiro de 2026.

nome_arquivo <- "dados/bruto/Arquivos_csv_2025.zip"
link_arquivo <- "https://dadosabertos-download.cgu.gov.br/FalaBR/Arquivos_FalaBR_Filtrado/Arquivos_csv_2025.zip"

# Verifica se o arquivo existe. Se não, baixa automaticamente.
if (!file.exists(nome_arquivo)) {
  tryCatch({
    download.file(link_arquivo, 
                  destfile = nome_arquivo, mode = "wb")
    message(paste0("Download concluído com sucesso! Arquivo: '", nome_arquivo, "'"))
  }, error = function(e) {
    stop("Erro ao baixar o arquivo do Portal da Transparência. Verifique a conexão ou o link.")
  })
} else {
  message(paste0("Download não realizado, pois o arquivo de interesse já existe: '", nome_arquivo, "'"))
}

# No site consta: "12. Posso fazer o download dos dados? Sim. Com o objetivo de
# facilitar a consulta das informações disponíveis na Busca de Pedidos e
# Respostas e oferecer ao usuário uma forma rápida e prática de obter e
# armazenar os dados, a Controladoria-Geral da União disponibiliza a base de
# dados dos pedidos e respostas realizados no Poder Executivo Federal, por meio
# do Fala.BR, em formatos CSV e XML. O usuário deverá entrar na seção Download
# de Dados e selecionar o ano desejado e o formato. Dessa forma o usuário poderá
# baixar as informações constantes no site para fazer todos os cruzamentos e
# análises que desejar e realizar estudos e pesquisas a partir desses dados."

fala_br <- read_csv2(unz("dados/bruto/Arquivos_csv_2025.zip", 
                         grep("_Pedidos_csv_2025\\.csv$", 
                              unzip("dados/bruto/Arquivos_csv_2025.zip", list = TRUE)$Name, 
                              value = TRUE)),
                     locale = locale(encoding = "UTF-16LE"))

# ---------------------------- Tratamento de dados ----------------------------- 

## 1. Lista de nomes -----------------------------------------------------------

# Junção das listas de nome e sobrenome. Edição parq que a primeira letra seja
# maiúscula.

nomes_br <- nomes_br |> 
  select(nome) |> 
  bind_rows(
    sobrenomes_br |> 
      select(nome)
  ) |> 
  distinct() |> 
  arrange(nome)
rm(sobrenomes_br)

nomes_br <- nomes_br |> 
  mutate(nome = str_to_title(nome))

## 2. Textos FalaBR ------------------------------------------------------------

# Tirar acentos e cedilha. Aproveito para deixar apenas a coluna com a
# solicitação e retiro as que estão duplicadas.

fala_br <- fala_br |> 
  mutate(
    texto = stri_trans_general(str = DetalhamentoSolicitacao, 
                               id = "Latin-ASCII"),
    .keep = "used"
  ) |> 
  distinct()

# Fluxos separados porque a base é muito pesada. Fazendo junto estava demorando
# muito.
fala_br <- fala_br |> 
  mutate(
    texto = str_squish(texto), 
    .keep = "used"
  ) |> 
  distinct() |> 
  mutate(id = row_number())

# ---------------------------- Análise exploratória ---------------------------- 

# "Explodir" o texto em palavras, com uma palavra por linha.
fala_br_token <- fala_br |> 
  unnest_tokens(word, texto, to_lower = FALSE) |> 
  distinct()

# Junção do texto constante no FalaBR com a lista de nomes, para identificar os
# textos com nome, e a posterior identificação dos gatihos.
fala_br_token_ibge <- fala_br_token |> 
  inner_join(nomes_br, by = c("word" = "nome"))

# Retirada dos IDs onde foi identificado apenas um nome. Em inspeção visual, a
# maior parte dele é "Brasil".
fala_br_token_ibge <- fala_br_token_ibge  |> 
  add_count(id) |>
  filter(n > 1) |>
  select(-n)  

# Retirada dos IDs cujos termos identificados não são dados pessoais.
fala_br_token_ibge <- fala_br_token_ibge |> 
  group_by(id) |> 
  filter(!paste(sort(word), collapse = " ") %in% c(
    "Catarina Santa",  # "Santa Catarina" ordenado alfabeticamente
    "Brasil Sa",       # "Sa Brasil", geralmente está falando Estácio de Sá e algo sobre Brasil
    "Espirito Santo"   # "Espirito Santo"
  )) |> 
  ungroup()

fala_br <- fala_br |> 
  mutate(tem_nome = ifelse(id %in% fala_br_token_ibge$id, 1, 0))

# Análise exploratória do objeto a seguir. Trecho comentado para não abrir outra
# janela apenas quando necessário.
# fala_br |> 
#   filter(tem_nome == 1) |> 
#   View()

# Ao explorar as solicitações com nome de forma completamente aleatória, achei
# uma de uma pessoa que conheço. Nem sabia onde a pessoa trabalhava, agora,
# através da solicitação encontrada, eu sei.



# ---------------------------------- Outputs -----------------------------------
#
# Os insights provenientes dessa análise de nomes e gatilhos estão presentes nos
# scripts:
# - src/scripts/02_criar_base_nomes_ibge.R
# - src/scripts/03_criar_base_nomes_transparencia_df.R
# - src/utils/detectar_nomes.R
# 
# ------------------------------------------------------------------------------
#                                 Próximo passo 
# ------------------------------------------------------------------------------
# A) Para avaliação da solução:
#     src/scripts/05_classificar_textos.R
#
# B) Para reconstrução completa do projeto:
#     src/scripts/05_classificar_textos.R
# ------------------------------------------------------------------------------
