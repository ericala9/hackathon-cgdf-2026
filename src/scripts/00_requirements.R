# ==============================================================================
#  1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF - ACESSO À INFORMAÇÃO 
# ==============================================================================
# Script: src/scripts/00_requirements.R
# Objetivo: Restaurar o ambiente do projeto, carregando os pacotes necessários
# conforme o arquivo renv.lock
# Data: 2026-01
# ==============================================================================

# ------------------------- Instalação de dependências -------------------------

if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}

renv::restore(prompt = FALSE)

# ------------------------------------------------------------------------------
#                                 Próximo passo 
# ------------------------------------------------------------------------------
# A) Para avaliação da solução:
#     src/scripts/05_classificar_textos.R
#
# B) Para reconstrução completa do projeto:
#     src/scripts/01_download_nomes_ibge.R
# ------------------------------------------------------------------------------