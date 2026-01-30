# ==============================================================================
#  1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF - ACESSO À INFORMAÇÃO 
# ==============================================================================
# Script: src/scripts/00_requirements.R
# Objetivo: Restaurar o ambiente do projeto. Primeira tentativa via
# renv::restore(). Se falhar, tenta automaticamente por instalação direta. 
# Data: 2026-01
# ==============================================================================

# ------------------------- Instalação de dependências -------------------------

# Para não perguntar se pode instalar os pacotes.
options(pkgType = "binary")
options(install.packages.compile.from.source = "never")
options(ask = FALSE)
Sys.setenv(RENV_CONFIG_SANDBOX_ENABLED = "FALSE")
Sys.setenv(RENV_CONFIG_STARTUP_QUIET = "TRUE")


if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv") 
}

if (packageVersion("renv") >= "0.12.0") {
  renv::consent(provided = TRUE)
}

options(renv.consent = TRUE)

## Plano A - Instalação por meio do renv ---------------------------------------
sucesso_renv <- tryCatch({
  renv::restore(prompt = FALSE, clean = TRUE)
  TRUE 
}, error = function(e) {
  return(FALSE)
})

## Plano B - Instalação "manual" -----------------------------------------------

# Lista de pacotes utilizados na solução
pacotes_essenciais <- c(
  "dplyr",
  "jsonlite",
  "openxlsx",
  "readr",
  "rstudioapi",
  "stringi",
  "stringr",
  "tidyr",
  "tidytext",
  "tm",
  "tools"
)

if (!sucesso_renv) {
  for (pkg in pacotes_essenciais) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      tryCatch({
        install.packages(pkg) 
      }, error = function(e) {
        message(paste("Erro ao instalar", pkg, "-", e$message))
      })
    }
  }
}

# ------------------------------------------------------------------------------
#                                 Próximo passo 
# ------------------------------------------------------------------------------
# A) Para avaliação da solução:
#     src/scripts/05_classificar_textos.R
#
# B) Para reconstrução completa do projeto:
#     src/scripts/01_download_nomes_ibge.R
# ------------------------------------------------------------------------------
