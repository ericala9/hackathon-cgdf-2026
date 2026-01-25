# .Rprofile - Configuração Automática de Inicialização

# 1. Ativa o renv
source("renv/activate.R")

# 2. Configura o espelho do CRAN
options(repos = c(CRAN = "https://cloud.r-project.org"))

# 3. Gatilho de Interface
setHook("rstudio.sessionInit", function(newSession) {
  
  if (newSession && file.exists("run.R")) {
    
    # Mensagem de boas-vindas
    cat("\033[1;34m") # Azul
    cat("\n==============================================================\n")
    cat(" 🛡️  HACKATHON PARTICIPA DF - AUDITORIA LGPD\n")
    cat("==============================================================\n")
    cat("\033[0m") # Reseta cor
    cat("👋 O ambiente foi configurado via 'renv'.\n")
    
    # Tenta usar a API do RStudio para abrir o arquivo de forma limpa
    # Se não tiver a API, ele NÃO TENTA abrir com file.edit (evita a janela feia)
    if (requireNamespace("rstudioapi", quietly = TRUE)) {
      cat("👉 O script principal foi aberto para você.\n\n")
      rstudioapi::navigateToFile("run.R")
    } else {
      cat("👉 Por favor, abra o arquivo 'main.R' no painel de arquivos.\n\n")
    }
  }
}, action = "append")
