# ==============================================================================
#  1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF - ACESSO À INFORMAÇÃO 
# ==============================================================================
# Script: src/utils/detectar_nomes.R
# Objetivo: Identificar nomes de pessoas físicas utilizando uma abordagem
# híbrida de validação com base de nomes e sobrenomes do Censo 2022 do IBGE e
# nomes e sobrenomes retirados do Portal da Transparência do DF e análise de
# contexto por meio de gatilhos.
# Data: 2026-01
# ==============================================================================

# -------------------------- Configuração do ambiente --------------------------

library(stringr)
library(tm)

# ------------------------------ detectar_nome() -------------------------------

#' Detecta nomes de pessoas em texto após a identificação de palavras e posições
#' chave no texto
#'
#' @description Esta função utiliza uma estratégia de "Ataque e Defesa" para
#'   identificar nomes:
#' - **Fase 1 (Contextual):** Identifica gatilhos e verifica se as palavras ao redor
#'   constam na base do IBGE.
#' - **Fase 2 (Assinatura):** Se a fase 1 falhar, analisa o final do documento,
#'   onde geralmente constam assinaturas, aplicando padronização de texto (Title
#'   Case) para detectar nomes escritos sem diferenciação entre maiúsculas e
#'   minúsculas.
#'
#' @param textos Vetor de caracteres com os textos onde se deseja buscar a
#'   presença de nomes pessoais.
#'
#' @param lista_nomes Vetor de caracteres com os nomes e sobrenomes a serem
#'   procurados no texto.
#'
#' @return Um vetor lógico (`TRUE` ou `FALSE`) com o mesmo comprimento do vetor
#'   de entrada, indicando se nomes pessoais foram encontrados em cada texto.
#' @export
#' @examples
#' \dontrun{
#'   lista_nomes <- c("João", "Silva", "Maria", "Oliveira", "Ana", "Souza", "Carlos")
#'   
#'   meus_textos <- c(
#'     "Meu nome é João Silva e gostaria de saber...",                             #'  -> TRUE
#'     "Solicito o número do meu processo. Atenciosamente, Maria Oliveira",        #'  -> TRUE
#'     "A secretaria informou que o prazo acabou ontem.",                          #'  -> FALSE
#'     "PEDIDO DE HISTÓRICO ESCOLAR DO CEF 555 DE BRASÍLIA. ANA SOUZA 91234-5678"  #'  -> TRUE
#'   )
#'   
#'   #' 3. Executar a função
#'   detectar_nome(meus_textos, lista_nomes)
#'   #' Resultado esperado: TRUE, TRUE, FALSE, TRUE
#' }
detectar_nome <- function(textos, lista_nomes) {
  
  detectar_linha <- function(texto) {
    
    if (is.na(texto) || texto == "") return(FALSE)
    
    # 1. Listagem de gatilhos ----------------------------------------------------
    
    gatilhos_pre <- c(
      "nome", "requerente", "paciente", "cliente", "aluno", "aluna", "pai", 
      "m[ãa]e", "filho", "filha", "esposo", "esposa",     "representante", 
      "procurador", "advogado", "advogada", "eu sou", "\\bEu\\b", "chamo", 
      "chama", "abaixo assinado", "declarate", "sr", "sra", "senhor", "senhora", 
      "\\bdr\\b", "\\bdra\\b", "doutor", "doutora", "\\bprof", "servidor", 
      "servidora", "funcion[áa]rio", "funcion[áa]ria", "matr[íi]cula", "dados", 
      "orientador", "orientadora", "referente", "solicitante", "discente",  
      "cidad[ãa]o", "cidad[ãa]"
    )
    
    gatilhos_pos <- c(
      "brasileiro", "brasileira", "casado", "casada", "solteiro", "solteira",
      "uniao estavel", "divorciado", "viuvo", "convivente", "advogado", 
      "advogada", "portador", "inscrito", "residente", "domiciliado", "nascido",
      "rg", "cpf", "oab", "identidade", "ctps", "matr[íi]cula", 
      "atenciosamente", "atensiosamente", "att", "at.t.", "at.te", "grato", 
      "grata", "obrigada", "obrigado", "agradeço", "cordialmente", 
      "respeitosamente", "assinatura", "assino", "deferimento", "assinado"
    )
    
    todas_pistas <- c(gatilhos_pre, gatilhos_pos)
    
    regex_pistas <- paste0("(?i)\\b(", paste(todas_pistas, collapse = "|"), ")\\b")
    
    # 2. Detecção de nomes por meio de gatilhos ----------------------------------
    
    # if (!str_detect(texto, regex(regex_pistas, ignore_case = TRUE))) {
    #   tem_gatilho <- FALSE
    # } else {
    #   tem_gatilho <- TRUE
    # }
    
    tem_gatilho <- ifelse(!str_detect(texto, regex(regex_pistas, ignore_case = TRUE)), FALSE, TRUE)
    
    tem_nome <- FALSE
    
    if (tem_gatilho) {
      # Extração da 5 palavras antes e depois do gatilho
      padrao_janela <- paste0("(\\w+\\W+){0,5}(?:", regex_pistas, ")(\\W+\\w+){0,5}")
      trechos_relevantes <- str_extract_all(texto, regex(padrao_janela, ignore_case = TRUE))[[1]]
      
      if (length(trechos_relevantes) > 0) {
        palavras_encontradas <- unlist(str_split(trechos_relevantes, "\\W+"))
        candidatos <- palavras_encontradas[nchar(palavras_encontradas) > 2]
        candidatos <- candidatos[!str_to_lower(candidatos) %in% stopwords("pt")]
        
        # Verificação principal
        tem_nome <- any(candidatos %in% lista_nomes)
      }
    }
    
    # Se achou o algum nome foi encontrado próximo ao gatilho, retorna TRUE.
    if (tem_nome) return(TRUE)
    
    
    # 3. Detecção de nomes no fim do texto ---------------------------------------
    
    # Só executa se não achou nomes próximos aos gatihos, isto é tem_nome == FALSE
    
    tokens_brutos <- unlist(str_split(texto, "\\s+"))
    tokens_limpos <- str_remove_all(tokens_brutos, "[[:punct:]]")
    
    # Seleção dos últimos dez "blocos" de palavras no texto. Não é incomum as
    # pessoas colocarem CPF ou telefone após escrever o nome no final da
    # solicitação.
    n_total <- length(tokens_limpos)
    
    # Se o texto for muito curto, olha tudo. Se for longo, só o final.
    inicio_janela <- max(1, n_total - 9) 
    janela_final <- tokens_limpos[inicio_janela:n_total]
    
    # Remoção de palavras curtas e stopwords
    janela_filtrada <- janela_final[nchar(janela_final) > 2]
    janela_filtrada <- janela_filtrada[!str_to_lower(janela_filtrada) %in% stopwords("pt")]
    
    # Remove o que parece ser telefone, CPF ou data, leva em conta só números
    janela_filtrada <- janela_filtrada[!str_detect(janela_filtrada, "^\\d+$")]
    
    matches <- sum(janela_filtrada %in% lista_nomes)
    
    if (matches < 2) {
      
      # Força Title Case em tudo o que sobrou na janela, importante para textos
      # inteiros em maiúsculas
      janela_forcada <- stringr::str_to_title(janela_filtrada)
      matches_forcado <- sum(janela_forcada %in% lista_nomes)
      
      if (matches_forcado >= matches) {
        matches <- matches_forcado
      }
    }
    
    # Sem gatilho, só retorna resultado se tiver pelo menos 2 nomes (exemplo:
    # "Nome Sobrenome"), para evitar falsos positivos, como a pessoa que assina só
    # o primeiro nome.
    return(matches >= 2)
  }
  
  vapply(textos, detectar_linha, logical(1), USE.NAMES = FALSE)
  
}

# ------------------------------------------------------------------------------
#                                 Próximo passo 
# ------------------------------------------------------------------------------
# Função utilizada dentro de src/scripts/05_classificar_textos.R
# ------------------------------------------------------------------------------