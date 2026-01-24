# ==============================================================================
#  1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF - ACESSO À INFORMAÇÃO 
# ==============================================================================
# Script: src/utils/detectar_data_nascimento.R
# Objetivo: Definição da função 'detectar_data_nascimento()', que detecta datas
# de nascimento em textos.
# Data: 2026-01
# ==============================================================================

# -------------------------- Configuração do ambiente --------------------------

library(stringr)

# ------------------------- detectar_data_nascimento() ------------------------- 

#'Detecta datas de nascimento com Validação de Contexto e Formato
#'
#'@description Esta função analisa um vetor de textos em busca de datas que estejam
#'  semanticamente vinculadas a nascimento. A função utiliza uma abordagem de
#'  "Gatilho + Janela + Validação" para minimizar falsos positivos (ex: datas de
#'  protocolo ou leis).
#'
#'@details A função aplica uma expressão regular rigorosa ("blindada") que
#'verifica:
#' \itemize{
#'   \item \strong{Gatilhos de Contexto:} A data deve ser precedida por termos como
#'   "nasc" (nascido, nascimento), "d.n." ou "aniversário".
#'   \item \strong{Janela de Proximidade:} O gatilho deve estar a no máximo 20 caracteres
#'   de distância da data
#'   \item \strong{Validação de Calendário:} Dias restritos a 01-31 e meses a 01-12.
#'   Não aceita datas inválidas.
#'   \item \strong{Consistência de Separadores:} Se começar com ponto, deve terminar com ponto
#'   (ex: 10.10.1990 é válido; 10/10.1990 é inválido). Aceita `/`, `.` ou `-`.
#'   \item \strong{Intervalo de Anos:} Restrito ao período de 1900 a 2026 (ou formato de 2 dígitos).
#'   Ignora datas do século 19 e anterior ou do futuro distante.
#' }
#'
#'@param textos Vetor de caracteres. Os textos onde se deseja buscar por datas de nascimento.
#'
#'@return Um vetor lógico (`TRUE` ou `FALSE`) do mesmo tamanho da
#'  entrada, indicando se uma data de nascimento válida foi encontrada.
#'
#'@export
#'
#' @examples
#' \dontrun{
#' meus_textos <- c(
#'  "Nasci numa sexta 52/87/1992",  # FALSE (dia 52, mês 87)
#'  "Nasci numa sexta 01.09.1992",  # TRUE
#'  "Nasci numa sexta 01.09.2045",  # FALSE (ainda vai nascer)
#'  "Aniversario em 15-12-19",      # TRUE
#'  "Data de nascimento: 10/05/85", # TRUE
#'  "nascida em 31-12-2000",        # TRUE
#'  "nascido em 10/12.2000",        # FALSE (separador misturado)
#'  "previsão de nascimento 2024"   # FALSE (sem dia e mês)
#')
#'
#'  detectar_data_nascimento(meus_textos)
#'  # Retorno esperado: FALSE  TRUE FALSE  TRUE  TRUE  TRUE FALSE FALSE
#' }
detectar_data_nascimento <- function(textos) {
  
  # regex_data_nascimento
  # (?i)                               -> Ignora se é maiúscula ou minúscula
  # (nasc|d\\.n\\.|anivers[áa]ri)      -> Gatilhos: nascido, nascimento, d.n., aniversário
  # \\D{0,20}                          -> Janela de contexto
  # \\b                                -> Início do data
  # (0?[1-9]|[12][0-9]|3[01])          -> Dia: 1-9, 01-09, 10-29 ou 30-31
  # ([./-])                            -> Separador, capturado de maneira a garantir a consistência de separadores na data
  # (0?[1-9]|1[0-2])                   -> Mês: 1-9, 01-09, 10-12
  # \\3                                -> Separador igual ao anterior
  # (                                  -> Marcador do ano
  # \\d{2}                             -> Aceita 2 dígitos, como 85, 90 ou 23
  # |                                  -> OU
  # 19\\d{2}                           -> Aceita 1900 a 1999
  # |                                  -> OU
  # 20[0-1]\\d                         -> Aceita 2000 a 2019
  # |                                  -> OU
  # 202[0-6]                           -> Aceita 2020 a 2026
  # )                                  -> Marcador do ano
  # \\b                                -> Fim da data
  
  regex_data_nascimento <- "(?i)(nasc|d\\.n\\.|anivers[áa]ri)\\D{0,20}\\b(0?[1-9]|[12][0-9]|3[01])([./-])(0?[1-9]|1[0-2])\\3(\\d{2}|19\\d{2}|20[0-1]\\d|202[0-6])\\b"
  
  return(str_detect(textos, regex_data_nascimento))
}

# ------------------------------------------------------------------------------
#                                 Próximo passo 
# ------------------------------------------------------------------------------
# Função utilizada dentro de src/scripts/05_classificar_textos.R
# ------------------------------------------------------------------------------
