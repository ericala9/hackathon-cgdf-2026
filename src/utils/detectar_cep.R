# ==============================================================================
#  1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF - ACESSO À INFORMAÇÃO 
# ==============================================================================
# Script: src/utils/detectar_cep.R
# Objetivo: Definição da função 'detectar_cep()', que detecta CEPs em textos.
# Data: 2026-01
# ==============================================================================

# -------------------------- Configuração do ambiente --------------------------

library(stringr)

# ------------------------------- detectar_cep() ------------------------------- 

#' Detecta a presença de CEPs (Códigos de Endereçamento Postal)
#'
#' @description Esta função utiliza expressões regulares para varrer um vetor de
#'   textos e identificar padrões que correspondem ao formato de CEP brasileiro
#'   (ex: 70.000-000 ou 70000-000).
#'
#' @param textos Vetor de caracteres. Os textos onde se deseja buscar por CEPs.
#'
#' @return Um vetor lógico (`TRUE` ou `FALSE`) com o mesmo comprimento do vetor
#'   de entrada, indicando se algum padrão de CEP foi encontrado em cada texto.
#' @export
#'
#' @examples
#' \dontrun{
#'  meus_textos <- c(
#'    "Moro na Asa Norte, CEP 70.000-000, Brasília.",
#'    "Não informarei meu endereço.",
#'    "O código é 12345-678."
#'  )
#'
#'  detectar_cep(meus_textos)
#'  # Retorno esperado: TRUE, FALSE, TRUE
#' }
detectar_cep <- function(textos) {
  
  # regex_cep
  # \b          -> Começo da expressão
  # \d{2}       -> 2 dígitos
  # \.?\s*      -> Ponto opcional + espaços opcionais 
  # \d{3}       -> 3 dígitos
  # \s*-\s*     -> Traço obrigatório, opcionalmente cercado por espaços
  # \d{3}       -> 3 dígitos finais
  # \b          -> Fim da expressão
  regex_cep <- "\\b\\d{2}\\.?\\s*\\d{3}\\s*-\\s*\\d{3}\\b"
  
  return(str_detect(textos, regex_cep))
}

# ------------------------------------------------------------------------------
#                                 Próximo passo 
# ------------------------------------------------------------------------------
# Função utilizada dentro de src/scripts/05_classificar_textos.R
# ------------------------------------------------------------------------------