# ==============================================================================
#  1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF - ACESSO À INFORMAÇÃO 
# ==============================================================================
# Script: src/utils/baixar_nomes_ibge.R
# Objetivo: Definição da função 'baixar_nomes_ibge()', que baixa a base de nomes
# e sobrenomes mais comuns no Brasil e no DF a partir dos dados do Censo 2022.
# Data: 2026-01
# ==============================================================================

# -------------------------- Configuração do ambiente --------------------------

library(jsonlite)
library(dplyr)

# ---------------------------- baixar_nomes_ibge() -----------------------------

#' Baixa nomes ou sobrenomes mais comuns do Censo 2022 (IBGE)
#'
#' @description Esta função conecta à API do IBGE com informações de nome e
#'   sobrenome coletadas no Censo 2022, e itera sobre as páginas de resultados
#'   para construir uma base consolidada de nomes ou sobrenomes mais frequentes
#'   para o Brasil ou Distrito Federal.
#'
#' @param dado String. O tipo de informação desejada. Aceita "nome" (ou
#'   "prenome") e "sobrenome". O valor padrão é "nome" (case-insensitive e
#'   aceita plural).
#' @param localidade String. O recorte geográfico. Aceita "Brasil", "BR",
#'   "Distrito Federal" ou "DF" (case-insensitive).
#' @param paginas Inteiro. Quantidade de páginas da API a serem percorridas.
#'   Cada página retorna 20 itens. O valor padrão é 100 páginas (top 2000
#'   nomes).
#' @param delay Numérico. Tempo de espera em segundos entre cada requisição para
#'   evitar sobrecarregar a API. O valor padrão é um delay de 0.2s.
#'
#' @return Um `tibble` com quatro colunas principais: `nome` (ou
#'   sobrenome),	`percent` (frequência percentual de ocorrência na
#'   localidade),	`frequencia` (frequência absoluta na localidade) e	`rank`
#'   (posição da classificação do nome entre os mais populares na localidade).
#' @export
#'
#' @examples
#' \dontrun{
#'   # Baixar os nomes mais comuns do Brasil (primeiras 5 páginas)
#'   nomes_br <- baixar_nomes_ibge(dado = "nome", localidade = "BR", paginas = 5)
#'
#'   # Baixar sobrenomes do DF
#'   sobrenomes_df <- baixar_nomes_ibge("sobrenome", "DF", paginas = 10)
#' }
baixar_nomes_ibge <- function(dado = "nome", localidade, paginas = 100, delay = 0.2) {
  
  # 1. Tratamento dos parâmetros -----------------------------------------------
  
  ## 1.1 Localidade ------------------------------------------------------------
  
  localidade <- tolower(localidade)
  localidade_id <- case_when(
    localidade %in% c("brasil", "br") ~ 0,
    localidade %in% c("distrito federal", "df", "brasília", "brasilia") ~ 53,
    TRUE ~ NA_real_ 
  )
  
  if (is.na(localidade_id)) {
    stop(paste0("Localidade não reconhecida: '", localidade, "'.\n",
                "Use apenas 'Brasil' ou 'Distrito Federal' (DF)."))
  }
  
  ## 1.2 Nome ou sobrenome -----------------------------------------------------
  
  dado <- tolower(dado)
  dado <- case_when(
    dado %in% c("nome", "nomes", "prenome", "prenomes") ~ "nome",
    dado %in% c("sobrenome", "sobrenomes") ~ "sobrenome",
    TRUE ~ NA_character_
  )
  
  if (!dado %in% c("nome", "sobrenome")) {
    stop("Tipo de dado inválido. Use 'nome' ou 'sobrenome'.")
  }
  
  # 2. Criação da URL base -----------------------------------------------------
  
  # URL da API do Censo 2022 (Nomes)
  url_base <- paste0("https://servicodados.ibge.gov.br/api/v3/nomes/2022/localidade/",
                     localidade_id,
                     "/ranking/",
                     dado,
                     "?page=")
  
  # 3. Loop para ler e baixar os dados -----------------------------------------
  
  lista_nomes<- list()
  
  # Barra de progresso
  pb <- txtProgressBar(min = 0, max = paginas, style = 3)
  
  for (i in 1:paginas) {
    tryCatch({
      
      ## 3.1. Monta a URL e faz o download -------------------------------------
      
      url_atual <- paste0(url_base, i)
      dados <- jsonlite::fromJSON(url_atual)
      
      # 3.2. Verifica se o conteúdo é válido -----------------------------------
      if (!is.null(dados$items) && length(dados$items) > 0) {
        lista_nomes[[i]] <- dados$items
      } else {
        message(paste("Página", i, "veio vazia ou sem itens. Parando o loop."))
        break
      }
      
      # 3.4. Delay para não sobrecarregar a API --------------------------------
      Sys.sleep(delay)
      
      # Atualização da barra de progresso
      setTxtProgressBar(pb, i)
      
    }, error = function(e) {
      warning(paste("Erro ao baixar página", i, ":", e$message))
    })
  }
  
  close(pb)
  
  # 4. Consolidação dos dados --------------------------------------------------
  
  resultado <- dplyr::bind_rows(lista_nomes) |>
    as_tibble() |>
    distinct()
  
  return(resultado)
}

# ------------------------------------------------------------------------------
#                                 Próximo passo 
# ------------------------------------------------------------------------------
# Função utilizada dentro de src/scripts/01_download_nomes_ibge.R
# ------------------------------------------------------------------------------