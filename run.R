# ==============================================================================
# 1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF
# ==============================================================================
# ORQUESTRADOR PRINCIPAL (run.R)
# ==============================================================================
# Este script executa todo o pipeline da solução, desde a preparação das bases
# de conhecimento (nomes) até a classificação final dos textos.
# ==============================================================================

# Limpa o ambiente para garantir uma execução estéril
rm(list = ls())
# cat("\014") # Limpa o console

# Inicia cronômetro global
cronometro_inicio <- Sys.time()

# Função auxiliar para logs bonitos
imprimir_etapa <- function(titulo) {
  cat("\n")
  cat(paste0(strrep("=", 80), "\n"))
  cat(paste0("🚀 EXECUTANDO: ", titulo, "\n"))
  cat(paste0(strrep("=", 80), "\n"))
}

# Verifica diretórios essenciais
if (!dir.exists("dados/entrada")) dir.create("dados/entrada", recursive = TRUE)
if (!dir.exists("dados/saida")) dir.create("dados/saida", recursive = TRUE)
if (!dir.exists("dados/processado")) dir.create("dados/processado", recursive = TRUE)

# ==============================================================================
# ETAPA 1: CONSTRUÇÃO DAS BASES DE CONHECIMENTO (NOMES)
# ==============================================================================
# Nota: Estes scripts geram os arquivos .rds em dados/processado/

imprimir_etapa("01_download_nomes_ibge.R (Download Censo)")
# source("src/scripts/01_download_nomes_ibge.R", encoding = "UTF-8", echo = FALSE)

imprimir_etapa("02_criar_base_nomes_ibge.R (Processamento IBGE)")
# source("src/scripts/02_criar_base_nomes_ibge.R", encoding = "UTF-8", echo = FALSE)

imprimir_etapa("03_criar_base_nomes_transparencia_df.R (Nomes Servidores DF)")
# source("src/scripts/03_criar_base_nomes_transparencia_df.R", encoding = "UTF-8", echo = FALSE)

# ==============================================================================
# ETAPA 2: CLASSIFICAÇÃO DOS DOCUMENTOS (O MOTOR)
# ==============================================================================

imprimir_etapa("05_classificar_textos.R (Auditoria e Classificação)")
source("src/scripts/05_classificar_textos.R", encoding = "UTF-8", echo = FALSE)

# ==============================================================================
# RESUMO FINAL
# ==============================================================================
cronometro_fim <- Sys.time()
tempo_total <- round(difftime(cronometro_fim, cronometro_inicio, units = "mins"), 1)

cat("\n")
cat("########################################################################\n")
cat(sprintf("✅  PIPELINE CONCLUÍDO COM SUCESSO!\n"))
cat(sprintf("⏱️   Tempo Total de Execução: %s minutos\n", tempo_total))
cat("########################################################################\n")
