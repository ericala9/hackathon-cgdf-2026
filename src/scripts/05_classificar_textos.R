# ==============================================================================
#  1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF - ACESSO À INFORMAÇÃO 
# ==============================================================================
# Script: src/scripts/05_classificar_textos.R
# Objetivo: Classificação dos textos apresentados em públicos ou não públicos. 
# Data: 2026-01
# ==============================================================================

# ---------------------------- Configuração inicial ----------------------------

library(dplyr)
library(openxlsx)
library(stringi)
library(stringr)
library(tm)
library(tools)

# Carregando as funções necessárias para a classificação dos textos.
source("src/utils/detectar_cep.R")
source("src/utils/detectar_cpf_celular.R")
source("src/utils/detectar_data_nascimento.R")
source("src/utils/detectar_email.R")
source("src/utils/detectar_fixo_docs.R")
source("src/utils/detectar_nomes.R")

# ----------------------------- Leitura dos dados ------------------------------ 

## 1. Lista de nomes e sobrenomes ----------------------------------------------

# Lista de nomes e sobrenomes coletados no Censo 2022 do IBGE e no Portal da
# Transparência do DF.
# Objetos criados nos scripts:
# src/scripts/01_download_nomes_ibge.R
# src/scripts/02_criar_base_nomes_ibge.R
# src/scripts/03_criar_base_nomes_transparencia_df.R

nomes_ibge_2022 <- readRDS("dados/processado/nomes_ibge_2022.rds")
nomes_transparencia_df <- readRDS("dados/processado/nomes_transparencia_df.rds")

## 2. Textos de solicitação da LAI ---------------------------------------------

# Leitura do arquivo em formato XLSX na pasta de entrada de dados, independente
# do seu nome.
arquivo_textos <- list.files("dados/entrada", pattern = "\\.xlsx$")[1]
textos <- read.xlsx(paste0("dados/entrada/", arquivo_textos))

# ---------------------------- Tratamento de dados ----------------------------- 

## 1. Lista de nomes -----------------------------------------------------------

lista_nomes_comuns <- nomes_ibge_2022 |> 
  select(nome) |> 
  bind_rows(nomes_transparencia_df) |> 
  distinct() |> 
  pull(nome)

rm(nomes_ibge_2022, nomes_transparencia_df)

## 2. Textos de solicitação da LAI ---------------------------------------------

# A variável com o texto é a que é do tipo character e tem o maior número médio
# de caracteres e gtande variabilidade. Esta função procura a coluna que tem
# indícios de conter o texto da solicitação.
descobrir_coluna_texto <- function(df) {
  
  cols_char <- names(df)[sapply(df, is.character)]
  
  if (length(cols_char) == 0) stop("ERRO: Nenhuma coluna de texto encontrada.")
  if (length(cols_char) == 1) return(cols_char)
  
  # Calculando o score de cada coluna candidata
  scores <- sapply(cols_char, function(col_name) {
    vec <- na.omit(df[[col_name]])
    if (length(vec) == 0) return(0)
    
    # Amostragem para análise da performance
    amostra <- vec[1:min(100, length(vec))]
    
    # Métricas Estatísticas
    tam_medio <- mean(nchar(amostra))
    variabilidade <- length(unique(vec)) / length(vec)
    score <- tam_medio * (variabilidade + 0.1)
    
    # Ponderação Semântica (Nomes de coluna)
    nome_limpo <- tolower(iconv(col_name, to="ASCII//TRANSLIT"))
    
    # Indícios de solicitação  -> Multiplica Score
    if (grepl("texto|pedido|solicit|descri|mensag|detalhe|manifest|conteudo|demanda", nome_limpo)) {
      score <- score * 5.0
    }
    
    # Indícios de resposta ou metadado -> Derruba Score
    if (grepl("resp|soluc|provid|observ|parecer|situac|status|setor|unidade|data|origem", nome_limpo)) {
      score <- score * 0.01
    }
    
    return(score)
  })
  
  return(names(scores)[which.max(scores)])
}

texto_coluna <- descobrir_coluna_texto(textos)

# Tirar acentos e cedilha. A lista de nomes já vem da origem com esse
# tratamento. Aproveito para deixar apenas a coluna com a solicitação e retiro
# as que estão duplicadas.

textos_classificar <- textos |> 
  select(all_of(texto_coluna)) |>
  rename(texto_original = all_of(texto_coluna)) |> 
  mutate(
    texto = stri_trans_general(str = texto_original, 
                               id = "Latin-ASCII"),
  ) |> 
  distinct()

# Fluxos separados porque a base é muito pesada. Fazendo junto estava demorando
# muito.
textos_classificar <- textos_classificar |> 
  mutate(texto = str_squish(texto)) |> 
  distinct()

# -------------------- Detecção de dados pessoais - Parte 1 --------------------

# Configuração de variáveis auxiliares à detecção de dados pessoais pela
# estratégia de curto circuito.
n <- length(textos_classificar$texto)
res_class <- rep("Público", n)
res_motivo <- rep(NA_character_, n)
mask <- rep(TRUE, n)

# Detecção de datas de nascimento.
hits_nasc <- detectar_data_nascimento(textos_classificar$texto)

if (any(hits_nasc)) {
  res_class[hits_nasc]  <- "Não Público"
  res_motivo[hits_nasc] <- "Data de Nascimento"
  mask[hits_nasc]       <- FALSE # Baixa no sistema
}

# -------------------------- Mascaramento de números --------------------------- 

# Para evitar falsos positivos, números de processos, protocolos, leis, decretos
# e afins, além de datas e anos do século 20 e 21 e CNPJ, são mascarados neste
# ponto. Por este motivo as datas de nascimento foram detectadas no passo
# anterior.

mascarar_numeracoes <- function(txt) {
  txt |>
    str_replace_all("\\b\\d{1,2}[./-]\\d{1,2}[./-]\\d{2,4}\\b", "XXXXX") |> 
    str_replace_all("\\b\\d{5}-\\d{8}/\\d{4}-\\d{2}\\b", "XXXXX") |>
    str_replace_all("\\b(19|20)\\d{2}[-/](19|20)\\d{2}\\b", "XXXXX") |>
    str_replace_all("\\b(19|20)\\d{2}\\b", "XXXXX") |>
    str_replace_all("\\b\\d{2}\\.\\d{3}\\.\\d{3}/\\d{4}-\\d{2}\\b", "XXXXX") |>
    str_replace_all("(?i)(\\bLei|Decreto|\\bPort|\\bInstr|Ofício)[^\\d]{1,20}\\d+", "XXXXX") |> 
    str_replace_all("(?i)(protoc|processo|atend|chamado|contrato|contratos)[^\\d]{1,15}\\d{4,}", "XXXXX") 
}

if (any(mask)) {
  textos_classificar$texto[mask] <- mascarar_numeracoes(textos_classificar$texto[mask])
}

# -------------------- Detecção de dados pessoais - Parte 2 --------------------

# Lista de funções a serem aplicadas na estratégia 
regras <- list(
  list(n="CPF/Celular",  f=detectar_cpf_celular),
  list(n="CEP/Endereço", f=detectar_cep),
  list(n="E-mail",       f=detectar_email),
  list(n="Doc/TelFixo",  f=detectar_fixo_e_docs),
  list(n="Nome",         f=function(x) detectar_nome(x, lista_nomes_comuns))
)

# Lógica de de curto-circuito. Se acusar que o texto tem dado pessoal, ele já é
# classificado e as demais funções não são aplicadas nele.
for (regra in regras) {
  if (!any(mask)) break
  
  hits_local <- regra$f(textos_classificar$texto[mask])
  
  if (any(hits_local)) {
    idx_real <- which(mask)[hits_local]
    
    # 3. Atualiza
    res_class[idx_real]  <- "Não Público"
    res_motivo[idx_real] <- regra$n
    mask[idx_real]       <- FALSE
  }
}

res_motivo[is.na(res_motivo)] <- "Nenhum dado sensível detectado"

# Juntando a classificação aos textos.
textos_classificar <- textos_classificar |>
  mutate(
    Classificacao = res_class,
    motivo_classificacao = res_motivo
  )

# Junção da classificação com os textos originais. Passo importante porque pode
# haver textos repetidos, e a classificação foi feita em textos únicos.
# textos <- textos |> 
#   left_join(textos_classificar |> 
#               select(texto_original, Classificacao), 
#             by = join_by(Texto.Mascarado == texto_original))
textos <- textos |> 
  left_join(textos_classificar |> 
              select(texto_original, Classificacao), 
            by = setNames("texto_original", texto_coluna))

# --------------------------- Formatação do arquivo ---------------------------- 

# Seguindo o estilo de formatação do arquivo original. O arquivo de saída foi
# desenhado para ter o mesmo formato do arquivo original, sendo a exceção a
# coluna de classificação, que foi desenhada de forma a ser ligeiramente diferente
# das demais colunas do arquivo. Esta é a última coluna do arquivo.

# Releitura do arquivo original, para trazer junto os estilos, cores, larguras
# de coluna deste.
wb <- loadWorkbook(paste0("dados/entrada/", arquivo_textos))

# Só vou acrescentar a última coluna do objeto ao arquivo. Marco a numeração
# dela na ordem.
coluna_classificacao <- ncol(textos)

# Encaixa os dados da coluna de classificação no arquivo.
writeData(wb, 
          sheet = 1,
          x = textos |> select(Classificacao),
          startCol = coluna_classificacao, 
          startRow = 1)

# Edição do estilo do cabeçalho da coluna de classificação.
estilo_cabecalho <- createStyle(
  fontName = "Calibri",
  fontSize = 11,
  fontColour = "#FFFFFF",
  fgFill = "#4F4F4F", 
  textDecoration = "bold",
  halign = "left",
  valign = "center")

# Aplicação do estilo na coluna de classificação.
addStyle(wb, 
         sheet = 1, 
         style = estilo_cabecalho, 
         rows = 1, 
         cols = coluna_classificacao, 
         gridExpand = TRUE)

# Ajuste de largura automático para a coluna de classificação.
setColWidths(wb, 
             sheet = 1, 
             cols = coluna_classificacao,
             widths = "auto")

# ---------------------------- Exportação dos dados ----------------------------

# Criação da pasta de saída se ela ainda não existir.
if (!dir.exists("dados/saida")) {
  dir.create("dados/saida")
}

saveWorkbook(wb, paste0("dados/saida/", 
                        tools::file_path_sans_ext(arquivo_textos), 
                        "_classificado.xlsx"), 
             overwrite = TRUE)

message(paste0("Arquivo com textos classificados salvo em: ", 
               getwd(),
               "/dados/saida/", 
               file_path_sans_ext(arquivo_textos), 
               "_classificado.xlsx")
)

# ----------------------------------- Output -----------------------------------
#
# Arquivo criado:
#                    dados/saida/[[NOME_ORIGINAL_DO_ARQUIVO]]_classificado.xlsx
#
# ------------------------------------------------------------------------------
#                                 Próximo passo 
# ------------------------------------------------------------------------------
# Este é o último passo da solução. A fim de automatizá-la, foi criado o arquivo
# run.R na pasta raiz do projeto.
# ------------------------------------------------------------------------------
