source("renv/activate.R")

# --- CONFIGURAÇÃO DE SEGURANÇA MÁXIMA ---
# 1. Define o repositório da Posit (que contém os binários para Windows)
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/latest"))

# 2. A REGRA DE OURO: FORÇA O USO DE BINÁRIOS
# Isso impede que o R tente usar 'gcc' ou 'make'. Se ele não achar o binário,
# ele vai avisar, mas não vai tentar compilar e travar.
options(pkgType = "binary")

# 3. Aumenta o tempo limite de download (segurança para internet lenta do governo)
options(timeout = 300)

setHook("rstudio.sessionInit", function(newSession) {
  
  if (newSession && file.exists("run.R")) {
    
    # Mensagem de Boas-vindas
    cat("\033[1;34m") 
    cat("\n================================================================================\n")
    cat("  1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF - ACESSO À INFORMAÇÃO\n") 
    cat("================================================================================\n")
    cat("\033[0m") 
    cat("- Ambiente configurado (Modo Binário Seguro).\n")
    
    cat("INSTRUÇÕES DE EXECUÇÃO:\n")
    cat("📂 1. Verifique se o arquivo .xlsx com textos a serem classificados está na pasta: 'dados/entrada'\n")
    cat("▶️ 2. Para rodar, clique no botão 'Source' (acima à direita) ou use o atalho:\n")
    cat("      [ Ctrl + Shift + S ]\n\n")
    
    # Abertura garantida do arquivo
    if (requireNamespace("rstudioapi", quietly = TRUE)) {
      rstudioapi::navigateToFile("run.R")
    } else {
      file.edit("run.R") 
    }
  }
}, action = "append")
