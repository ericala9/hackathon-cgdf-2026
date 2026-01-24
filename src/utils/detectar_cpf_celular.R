# ==============================================================================
#  1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF - ACESSO À INFORMAÇÃO 
# ==============================================================================
# Script: src/utils/detectar_cpf_celular.R
# Objetivo: Definição da função 'detectar_cpf_celular()', que identifica CPFs e
# telefones celulares através de expressões regulares. Os números de telefone
# celulares e o CPF não foram validados matematicamente ou por outras regras.  A
# ideia é pecar pelo excesso de zelo, garantindo que até textos com estes
# números digitados com erros sejam classificados como não públicos.
#
# Nota: Diferente da função 'detectar_fixo_docs()', que busca por gatilhos
# ("CPF: 123..."), esta função busca pelo padrão do dado, capturando números
# soltos no texto que tenham formato de CPF ou Celular. sequência numérica. Como
# tanto o CPF quanto o celular com DDD têm onze dígitos, esta função aborda os
# dois casos.
# Data: 2026-01
# ==============================================================================

# -------------------------- Configuração do ambiente --------------------------

library(stringr)

# --------------------------- detectar_cpf_celular() --------------------------- 

#' Detecta CPFs e Celulares em vetor de textos
#'
#' @description Identifica padrões numéricos de 11 dígitos através de duas
#'   abordagens: 1. **Visual:** Busca máscaras comuns (ex: `XXX.XXX.XXX-XX` ou
#'   `(XX) XXXXX-XXXX`). 2. **Contagem:** Busca sequências de 11 dígitos.
#'    **Nota:** Protocolos, processos e outras sequências com exatos 11 dígitos
#'   (ex: 20230000001) serão marcados como positivos intencionalmente,
#'   priorizando a segurança contra vazamento de CPFs não formatados. Como os
#'   dados de treinamento são sintéticos, não foram aplicadas regras de
#'   validação e composição de CPF e números de telefone celular.
#'
#' @param textos Vetor de caracteres com os textos onde se deseja buscar a
#'   presença de telefones celulares e CPFs.
#'
#' @return Um vetor lógico (`TRUE` ou `FALSE`) com o mesmo comprimento do vetor
#'   de entrada, indicando se algum telefone celular ou CPF foi encontrado em
#'   cada texto.
#'
#' @examples
#' \dontrun{
#'   meus_textos <- c(
#'     "Meu CPF é 123.456.789-00",           # TRUE (Formatado)
#'     "Ligue no (61) 99999-8888",           # TRUE (Formatado)
#'     "O número é 11987654321",             # TRUE (11 dígitos - Celular)
#'     "Protocolo 20230000001",              # TRUE (11 dígitos, poderia ser um CPF)
#'     "Meu processo é 9786"                 # FALSE (Não tem 11 dígitos)
#'   )
#'   detectar_cpf_celular(meus_textos)
#' }
#' @export

detectar_cpf_celular <- function(textos) {
  
  detectar_linha <- function(texto) {
    if (is.na(texto) || texto == "") return(FALSE)
    
    # Flags
    tem_cpf <- FALSE
    tem_tel <- FALSE
    
    # --------------------------------------------------------------------------
    # 1. VALIDAÇÃO POR FORMATAÇÃO (Visual)
    # --------------------------------------------------------------------------
    
    # A. CPF Pontuado (XXX.XXX.XXX-XX) -> Imbatível
    if (str_detect(texto, "\\b\\d{3}\\.\\d{3}\\.\\d{3}-\\d{2}\\b")) {
      tem_cpf <- TRUE
    }
    
    # Lógica: 
    #   \d{2}     -> DDD (2 dígitos)
    #   [\s-]?    -> Separador opcional (espaço ou traço)
    #   [1-9]     -> O primeiro número NÃO pode ser 0 (Filtra processos iniciados em 000...)
    #   \d{8}     -> O resto do número
    #   (?!/)     -> Não pode ter barra depois (Filtra ano de processo)
    
    if (str_detect(texto, "\\b\\d{2}[\\s-]?[1-9]\\d{8}\\b(?!/)")) {
      tem_tel <- TRUE
    }
    
    # C. Telefone "Formatado Clássico" (com parênteses)
    # Pega (61) 9xxxx-xxxx
    if (str_detect(texto, "\\(\\d{2}\\)\\s?[1-9]\\d{4}[-\\s]?\\d{4}")) {
      tem_tel <- TRUE
    }
    
    # --------------------------------------------------------------------------
    # 2. VALIDAÇÃO POR CONTAGEM (Os 11 dígitos nus/colados)
    # --------------------------------------------------------------------------
    # Isso serve para casos onde não tem espaço nenhum: "12345678901"
    
    cand_11 <- str_extract_all(texto, "(?<![\\d/.-])\\d{11}(?![\\d/.-])")[[1]]
    
    for (cand in cand_11) {
      # Se pegou 11 dígitos juntos:
      # Se começar com algo que parece DDD válido (11-99) e o 3º dígito não for 0:
      if (str_detect(cand, "^[1-9][0-9][1-9]\\d{8}$")) {
        tem_tel <- TRUE
      } else {
        # Se começa com 0, ou o terceiro dígito é 0 -> CPF
        tem_cpf <- TRUE
      }
    }
    
    # --------------------------------------------------------------------------
    # 3. Classificação Final
    # --------------------------------------------------------------------------
    if (tem_cpf && tem_tel) return(TRUE)
    if (tem_cpf) return(TRUE)
    if (tem_tel) return(TRUE)
    return(FALSE)
  }
  
  vapply(textos, detectar_linha, FUN.VALUE = logical(1), USE.NAMES = FALSE)
}

# ------------------------------------------------------------------------------
#                                 Próximo passo 
# ------------------------------------------------------------------------------
# Função utilizada dentro de src/scripts/05_classificar_textos.R
# ------------------------------------------------------------------------------