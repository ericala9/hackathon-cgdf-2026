# ==============================================================================
#  1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF - ACESSO À INFORMAÇÃO 
# ==============================================================================
# Script: src/utils/detectar_email.R
# Objetivo: Definição da função 'detectar_email()', que identifica e-mails em
# textos, tolerando pequenos erros de digitação.
# Data: 2026-01
# ==============================================================================

# -------------------------- Configuração do ambiente --------------------------

library(stringr)
library(dplyr)

# ------------------------------ detectar_email() ------------------------------ 

#' Detecta e classifica e-mails com risco de privacidade
#'
#' @description Esta função identifica endereços de e-mail em textos livres,
#'   tolerando erros comuns de digitação, como espaços antes do domínio ou uso
#'   de vírgulas no lugar de pontos.
#'
#'   Além de detectar, a função classifica o risco:
#' \itemize{
#'   \item \strong{Retorna FALSE:} Se não encontrar e-mail OU se o e-mail for
#'   institucional (ex: contato@, sac@, ouvidoria@).

#'    \item \strong{Retorna TRUE:} Se encontrar um e-mail que não aparenta ser
#'    estritamente institucional que não esteja na lista de exceções
#'    institucionais. }
#'
#' @param texto Vetor de caracteres com os textos onde se deseja buscar por
#'   endereços de e-mail.
#'
#' @return Um vetor lógico (`TRUE` ou `FALSE`) indicando se o texto contém um
#'   endereço de e-mail que não aparenta ser estritamente institucional.
#' @export
#'
#' @examples
#' \dontrun{
#'   meus_textos <- c(
#'     "Meu email é maria@gmail.com",       # Pessoal -> TRUE
#'     "Fale com o sac@sigla.df.gov.br",    # Institucional -> FALSE
#'     "Não tenho email."                   # Nenhum -> FALSE
#'   )
#'   detectar_email(meus_textos)
#'   # Retorno esperado: TRUE, FALSE, FALSE
#' }
detectar_email <- function(texto) {
  
  # 1. Deteção de e-mail no texto. ---------------------------------------------
  # regex_email
  # (?i)                  -> Ignorar maiúsculas/minúsculas
  # [a-z0-9._%+\-\s]+     -> Usuário: Aceita letras, números, símbolos e espaços (exemplo: "joao silva@")
  # @                     -> O caractere arroba obrigatório
  # \s*                   -> Espaços opcionais após o arroba
  # (?:                   -> Início do grupo de domínio (não captura)
  # [a-z0-9\-\s]+         -> Nome do domínio, aceita espaços (exemplo: "gmail . com")
  # (?:                   -> Início do separador após o domínio
  # \s*\.+\s*             -> Ponto como separador após o domínio, aceitando espaços antes ou depois
  # |                     -> Operador OU
  # ,(?!\s)               -> Vírgula como separador após o dominio, desde que NÃO tenha espaço depois. Regra incluída pois é um erro comum de digitação.
  # )                     -> Fim do separador
  # )+                    -> Fim do grupo de domínio, repetindo um ou mais vezes para subdomínios
  # [a-z]{2,}             ->  Extensão final com pelo menos 2 letras (ex: br, com)
  regex_email <- "(?i)[a-z0-9._%+\\-\\s]+@\\s*(?:[a-z0-9\\-\\s]+(?:\\s*\\.+\\s*|,(?!\\s)))+[a-z]{2,}"
  email_bruto <- str_extract(texto, regex_email)
  
  # Se não achar nada em nenhum texto, retorna tudo FALSE
  if (all(is.na(email_bruto))) return(rep(FALSE, length(texto)))
  
  # 2. Refinamento do resultado ------------------------------------------------
  resultado <- data.frame(bruto = email_bruto, stringsAsFactors = FALSE) %>%
    mutate(
      # Passo A: Separa o usuário do domínio no primeiro @ encontrado
      parte_usuario_suja = str_remove(bruto, "@.*"), 
      
      # Passo B: Extrai apenas o último bloco de texto válido do usuário
      usuario_limpo = str_extract(parte_usuario_suja, "[a-zA-Z0-9._%+-]+$"),
      
      usuario_limpo = tolower(usuario_limpo),
      
      # Passo C: Lista de indicativos de e-mail institucional
      email_institucional = str_detect(
        usuario_limpo, 
        regex("^(contato|sac|ouvidoria|suporte|atendimento|faleconosco|financeiro|adm|administrativo|geral|info|imprensa|comunicacao|naoresponda|noreply|no-reply|gabinete|protocolo|secretaria|agenda|coord|diretoria)$", ignore_case = TRUE)
      ),
      
      email_classificado = !is.na(bruto) & !email_institucional
    )
  
  return(resultado$email_classificado)
}

# ------------------------------------------------------------------------------
#                                 Próximo passo 
# ------------------------------------------------------------------------------
# Função utilizada dentro de src/scripts/05_classificar_textos.R
# ------------------------------------------------------------------------------