# ==============================================================================
#  1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF - ACESSO À INFORMAÇÃO 
# ==============================================================================
# Script: run.R
# Objetivo: Executa a solução classificação de textos do desafio de Acesso à
# Informação
# Data: 2026-01
# ==============================================================================

# ==============================================================================
# INSTRUÇÕES: Salve o arquivo em formato .xlsx com os textos a serem
# classificados na pasta dados/entrada.
# ==============================================================================

# ---------------------------- Configuração inicial ----------------------------

# Limpa o ambiente para garantir uma execução estéril
rm(list = ls())

# Função auxiliar para mensagens de status com timestamp
log_status <- function(mensagem) {
  cat(sprintf("[%s] %s\n", format(Sys.time(), "%H:%M:%S"), mensagem))
  flush.console() # Força a exibição imediata no console
}

cat("\n")
log_status(">>> INICIANDO...")
log_status("1/5 - Carregamento de  bibliotecas e configuração do ambiente...")

# Toda configuração de ambiente e pacotes a serem utilizados estão salvos no
# script 00_requirements.R.
suppressWarnings(
  suppressPackageStartupMessages(
    source("src/scripts/00_requirements.R", encoding = "UTF-8", echo = FALSE)))

# Verificação de diretórios essenciais
if (!dir.exists("dados/entrada")) dir.create("dados/entrada", recursive = TRUE)
if (!dir.exists("dados/saida")) dir.create("dados/saida", recursive = TRUE)
if (!dir.exists("dados/processado")) dir.create("dados/processado", recursive = TRUE)



# TRAVA DE SEGURANÇA: Verifica se há arquivo de entrada para processar
log_status("2/5 - Verificação do arquivo de entrada...")
arquivos_entrada <- list.files("dados/entrada", pattern = "\\.(xlsx)$", full.names = TRUE)

if (length(arquivos_entrada) == 0) {
  cat("\n\033[1;31m[ERRO] Nenhum arquivo .xlsx encontrado na pasta 'dados/entrada'!\033[0m\n")
  cat("Por favor, coloque o arquivo .xlsx a ser classificado na pasta 'dados/entrada' e tente novamente.\n")
  stop("Execução interrompida por falta de dados.")
}

log_status(sprintf("     Arquivo detectado: %s", basename(arquivos_entrada[1])))

# Início do cronômetro
cronometro_inicio <- Sys.time()

# -------------------------- Classificação dos textos --------------------------

# Os scripts 01 a 04 são auxiliares à solução. Os dados derivados deles e
# necessários à solução estão salvos na pasta dados/processado, por isto estes
# scripts não são utilizados para rodar a solução final de classificação.

log_status("3/5 - Carregando bases de conhecimento e regras de expressões regulares...")
# Esta etapa ocorre dentro do script 05, mas é avisada aqui para que o usuário
# entenda o que vai ocorrer.

log_status("4/5 - INÍCIO DA CLASSIFICAÇÃO...")
cat("      (Esta etapa pode levar alguns minutos dependendo do volume de dados...)\n")
flush.console()

suppressWarnings(
  suppressPackageStartupMessages(source("src/scripts/05_classificar_textos.R", encoding = "UTF-8", echo = FALSE)))

log_status("5/5 - FIM DA CLASSIFICAÇÃO.")

# Stop no cronômetro.
cronometro_fim <- Sys.time()
tempo_total <- round(difftime(cronometro_fim, cronometro_inicio, units = "mins"), 1)

cat("\n")
cat("================================================================================\n")
cat(sprintf("                         SOLUÇÃO FINALIZADA COM SUCESSO!\n"))
cat(sprintf("Tempo total de execução: %.1f minutos\n", tempo_total))
cat(sprintf(paste0("Arquivo final: dados/saida/", file_path_sans_ext(basename(arquivos_entrada[1])), "_classificado.xlsx\n")))
cat("================================================================================\n")

# ----------------------------------- Output -----------------------------------
#
# Arquivo criado:
#                    dados/saida/[[NOME_ORIGINAL_DO_ARQUIVO]]_classificado.xlsx
#
# ------------------------------------------------------------------------------

