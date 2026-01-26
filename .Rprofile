source("renv/activate.R")

# Configuração de espelho do CRAN
options(repos = c(CRAN = "https://cloud.r-project.org"))

setHook("rstudio.sessionInit", function(newSession) {
  
  if (newSession && file.exists("run.R")) {
    
    # Mensagem de boas-vindas
    cat("\033[1;34m") # Azul
    cat("\n================================================================================\n")
    cat("  1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF - ACESSO À INFORMAÇÃO\n") 
    cat("================================================================================\n")
    cat("\033[0m") # Volta para a cor automática
    cat("- O ambiente foi configurado via 'renv'.\n")
    
    # Tenta usar a API do RStudio para abrir o arquivo de forma limpa
    if (requireNamespace("rstudioapi", quietly = TRUE)) {
      cat("- O script principal 'run.R' foi aberto para você.\n\n")
      cat("INSTRUÇÕES DE EXECUÇÃO:\n")
      cat("📂 1. Verifique se o arquivo .xlsx com textos a serem classificados está na pasta: 'dados/entrada'\n")
      cat("▶️  2. Para rodar, clique no botão 'Source' (acima à direita) ou use o atalho:\n")
      cat("      [ Ctrl + Shift + S ]\n\n")
      rstudioapi::navigateToFile("run.R")
    } else {
      cat("INSTRUÇÕES DE EXECUÇÃO:\n")
      cat("📂 1. Verifique se o arquivo .xlsx com textos a serem classificados está na pasta: 'dados/entrada'\n")
      cat("▶️  2. Abra o script 'run.R' e execute-o. Clique no botão 'Source' (acima à direita) ou use o atalho:\n")
      cat("      [ Ctrl + Shift + S ]\n\n")
    }
  }
}, action = "append")
