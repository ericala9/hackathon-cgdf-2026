# ==============================================================================
# 1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF - ACESSO À INFORMAÇÃO
# ==============================================================================
# Script: src/utils/detectar_fixo_docs.R 
# Objetivo: Definição da função 'detectar_fixo_e_docs()', que identifica
# telefones fixos e documentos (RG, CNH, etc) através de expressões regulares.
# Os números de telefone e dos documentos não foram validados matematicamente ou
# por outras regras.  A ideia é pecar pelo excesso de zelo, garantindo que até
# textos com documentos digitados errados sejam classificados como não públicos.
#
# Nota: Diferente da função 'detectar_cpf_celular()', que busca pelo padrão
# visual das informações, esta função busca por gatilhos que levam a números de
# documentos (como, "CPF: 123...") e telefones fixos que seguem algum formato
# conhecido. Data: 2026-01
# ==============================================================================

# -------------------------- Configuração do ambiente --------------------------

library(stringr)

# --------------------------- detectar_fixo_e_docs() --------------------------- 

#' Detecta telefones fixos e documentos em texto após a identificação de
#' palavras-chave
#'
#' @description Esta função combina estratégias de reconhecimento visual e
#'   contextual para identificar dados pessoais numéricos, sejam eles telefones
#'   fixos ou números de documentos, por meio de expressões regulares.
#'
#'   Em vez de validar cada documento matematicamente, a função atua em duas
#'   frentes:
#' \enumerate{
#'   \item \strong{Pelo Formato (Visual):} Para telefones fixos, busca a estrutura
#'   típica de discagem (como prefixos e hífens), aceitando variações comuns.
#'   \item \strong{Pelo Contexto (Gatilhos):} Para documentos (RG, CPF, OAB, etc),
#'   procura por palavras-chave no texto e "captura" qualquer sequência numérica
#'   que apareça em até 25 caracteres de distância.
#' }
#'
#' @details Os resultados não são validados matematicamente e nem por outras
#'   regras. Isto permite que mesmo um número de telefone fixo ou documento com
#'   erro de digitação seja encontrado. O objetivo é evitar a reidentificação do
#'   cidadão: impedindo que terceiros deduzam a identidade real dele explorando
#'   um dado com erros simples de digitação.
#'
#'   A prioridade é a minimização de falsos negativos, evitando vazamento de
#'   dados. Assume-se que, por exemplo, se existe a palavra "CPF" seguida de
#'   números, trata-se de um dado pessoal, independentemente da formatação
#'   correta.
#'
#' @param textos Vetor de caracteres com os textos onde se deseja buscar a
#'   presença de telefones fixos e número de documentos.
#'
#' @return Um vetor lógico (`TRUE` ou `FALSE`) com o mesmo comprimento do vetor
#'   de entrada, indicando se algum telefone fixo ou número de documento foi
#'   encontrado em cada texto.
#' @export
#'
#' @examples
#' \dontrun{
#'   meus_textos <- c(
#'     "Ligue no (61) 3333-3333.",               # Fixo -> TRUE
#'     "Meu RG é o 1.234.567 SSP/DF",            # Gatilho "RG" -> TRUE
#'     "Sou advogado OAB/DF n. 12345",           # Gatilho "OAB" -> TRUE
#'     "O valor é 2000 reais"                    # Números sem gatilho -> FALSE
#'   )
#'   detectar_fixo_e_docs(meus_textos)
#' }
detectar_fixo_e_docs <- function(textos) {
  
  detectar_linha <- function(texto) {
    if (is.na(texto) || texto == "") return(FALSE)
    
    # 1. Telefone fixo --------------------------------------------------------
    # regex_fixo
    # \b                        -> Início da expressão
    # (?:                       -> Grupo do DDD, opcional
    # \(?\d{2}\)?               -> 2 dígitos, aceitando parênteses opcionais (exemplo: (61) ou 61)
    # [\s-]?                    -> Separador opcional logo após o DDD
    # )?                        -> Fim do grupo opcional do DDD
    # \d{4}                     -> 4 primeiros dígitos
    # [-\s]?                    -> Separador, hífen ou espaço 
    # \d{4}                     -> 4 últimos dígitos
    # \b                        -> Fim de expressão
    # (?!/)                     -> Garantir que não tem barra depois, para não confudir com data (exemplo: 2025/2026) ou números de processo 
    regex_fixo <- "\\b(?:\\(?\\d{2}\\)?[\\s-]?)?\\d{4}[-\\s]?\\d{4}\\b(?!/)"
    
    if (str_detect(texto, regex_fixo)) {
      return(TRUE)
    }
    
    # 2. Documentos ------------------------------------------------------------
    
    gatilhos <- c(
      # Documentos e informações pessoais
      "matr[íi]cula", "nis", "pis", "pasep", "nit",
      "rg", "cpf", "cnh", "identidade", "identifica[çc][ãa]o", "passaporte",
      "carteira de trabalho", "ctps", "s[ée]rie", # Série da carteira
      "cart[ãa]o do sus", "cns", "sus", "t[íi]tulo de eleitor",
      
      # Dados profissionais e outras informações
      "oab", "crm", "crea", "coren", "cau", "crc", "crefito", "creci",
      "siape", "inscri[çc][ãa]o", "IPTU",
      
      # Bancários
      "ag[êe]ncia", "conta", "poupan[çc]a", "banco", "pix"
    )
    
    #regex_docs
    # \d                        -> Tem que começar com um dígito (evita pegar apenas só "-.-")
    # [\d\.\-\/]{3,}            -> Seguido de 3 ou mais caracteres que podem ser: números, pontos, traços ou barras, totalizando um bloco de pelo menos 4 caracteres
    regex_docs <- "\\d[\\d\\.\\-\\/]{3,}"
    
    # regex_gatilhos
    # (?i)                      -> Ignora se é maiúscula ou minúscula (pega CPF, cpf, Cpf)
    # \b(gatilho1|gatilho2)\b   -> A palavra gatilho exata
    # .{0,25}?                  -> Aceita de 0 a 25 caracteres de entre o gatilho e o número (exemplo: OAB inscrita sob o número 1234)
    #                           -> O '?' faz ser "preguiçoso" (para assim que achar o número)
    regex_gatilhos <- paste0(
      "(?i)\\b(", paste(gatilhos, collapse = "|"), ")\\b.{0,25}?", regex_docs
    )
    
    if (str_detect(texto, regex_gatilhos)) {
      return(TRUE)
    }
    
    return(FALSE)
  }
  
  vapply(textos, detectar_linha, logical(1), USE.NAMES = FALSE)
}

# ------------------------------------------------------------------------------
#                                 Próximo passo 
# ------------------------------------------------------------------------------
# Função utilizada dentro de src/scripts/05_classificar_textos.R
# ------------------------------------------------------------------------------
