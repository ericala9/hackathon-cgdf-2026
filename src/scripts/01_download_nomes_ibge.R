# ==============================================================================
#  1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF - ACESSO À INFORMAÇÃO 
# ==============================================================================
# Script: src/scripts/01_download_nomes_ibge.R
# Objetivo: Baixar bases de nomes e sobrenomes mais comuns no Brasil e no DF a
# partir dos dados do Censo 2022.
# Data: 2026-01
# ==============================================================================

# ---------------------------- Configuração inicial ---------------------------- 

library(readr)

# Garantindo que a pasta de dados exista
if (!dir.exists("dados")) dir.create("dados/bruto", recursive = TRUE)

# Se os arquivos finais desse script já existirem, o script não é executado.

arquivos_esperados <- c(
  "dados/bruto/nomes_comuns_ibge_df_censo_2022.csv",
  "dados/bruto/sobrenomes_comuns_ibge_df_censo_2022.csv",
  "dados/bruto/nomes_comuns_ibge_brasil_censo_2022.csv",
  "dados/bruto/sobrenomes_comuns_ibge_brasil_censo_2022.csv"
)

# ------------------- Download dos dados de nome e sobrenome ------------------- 

if (!all(file.exists(arquivos_esperados))) {
  
  # Se os arquivos não existirem: ------------------------------------------------
  
  ## 1. Leitura da função baixar_nomes_ibge() ----------------------------------
  
  source("src/utils/baixar_nomes_ibge.R")
  
  ## 2. Download dos dados -----------------------------------------------------
  
  # Em pesquisa explotatória vi quais são as últimas páginas com informações
  # de nome e sobrenome no Distrito Federal.
  nomes_comuns_ibge_df_censo_2022 <- baixar_nomes_ibge("nome", "DF", 263)
  sobrenomes_comuns_ibge_df_censo_2022 <- baixar_nomes_ibge("sobrenome", "DF", 262)
  
  # Determinei baixar as 20 primeiras páginas de nomes e sobrenomes mais comuns
  # do Brasil, para complementar as informações do Distrito Federal.
  nomes_comuns_ibge_brasil_censo_2022 <- baixar_nomes_ibge("nome", "Brasil", 20)
  sobrenomes_comuns_ibge_brasil_censo_2022 <- baixar_nomes_ibge("sobrenome", "Brasil", 20)
  
  ## 3. Salvando os dados ------------------------------------------------------
  
  write_csv2(nomes_comuns_ibge_df_censo_2022, "dados/bruto/nomes_comuns_ibge_df_censo_2022.csv")
  write_csv2(sobrenomes_comuns_ibge_df_censo_2022, "dados/bruto/sobrenomes_comuns_ibge_df_censo_2022.csv")
  write_csv2(nomes_comuns_ibge_brasil_censo_2022, "dados/bruto/nomes_comuns_ibge_brasil_censo_2022.csv")
  write_csv2(sobrenomes_comuns_ibge_brasil_censo_2022, "dados/bruto/sobrenomes_comuns_ibge_brasil_censo_2022.csv")
  
  rm(nomes_comuns_ibge_df_censo_2022, 
     sobrenomes_comuns_ibge_df_censo_2022,
     nomes_comuns_ibge_brasil_censo_2022,
     sobrenomes_comuns_ibge_brasil_censo_2022)
} else {
  message("Os arquivos de nomes e sobrenomes do IBGE já existem na pasta 'dados/bruto'. Download ignorado.")
}

# Se os arquivos existirem, fazer nada. ----------------------------------------

# ---------------------------------- Outputs -----------------------------------
#
# Arquivos criados:
#                    dados/bruto/nomes_comuns_ibge_brasil_censo_2022.csv
#                    dados/bruto/nomes_comuns_ibge_df_censo_2022.csv
#                    dados/bruto/sobrenomes_comuns_ibge_brasil_censo_2022.csv
#                    dados/bruto/sobrenomes_comuns_ibge_df_censo_2022.csv
#
# ------------------------------------------------------------------------------
#                                 Próximo passo 
# ------------------------------------------------------------------------------
# A) Para avaliação da solução:
#     src/scripts/05_classificar_textos.R
#
# B) Para reconstrução completa do projeto:
#     src/scripts/02_criar_base_nomes_ibge.R
# ------------------------------------------------------------------------------