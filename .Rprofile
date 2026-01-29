source("renv/activate.R")

options(repos = c(CRAN = "https://packagemanager.posit.co/cran/latest"))

# Impede que o R tente usar 'gcc' ou 'make'. Se ele não achar o binário, ele vai
# avisar, mas não vai tentar compilar e travar.
options(pkgType = "binary")

options(timeout = 300)

setHook("rstudio.sessionInit", function(newSession) {
  
  if (newSession && file.exists("run.R")) {
    
    # Mensagem de Boas-vindas
    cat("\033[1;34m") 
    cat("\n================================================================================\n")
    cat("  1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF - ACESSO À INFORMAÇÃO\n") 
    cat("================================================================================\n")
    cat("\033[0m") 
    cat("- O ambiente será configurado via 'renv'.\n")
    cat("- O script principal 'run.R' foi aberto para você.\n\n")
    
    cat("INSTRUÇÕES DE EXECUÇÃO:\n")
    cat("📂 1. Verifique se o arquivo .xlsx com textos a serem classificados está na pasta: 'dados/entrada'\n")
    cat("▶️ 2. Para rodar, clique no botão 'Source' (acima à direita) ou use o atalho:\n")
    cat("      [ Ctrl + Shift + S ]\n\n")
    
    # Tenta usar o rstudioapi (mais bonito). Se não tiver instalado (ambiente virgem),
    # usa o file.edit (nativo do R) que funciona sempre.
    if (requireNamespace("rstudioapi", quietly = TRUE)) {
      rstudioapi::navigateToFile("run.R")
    } else {
      file.edit("run.R") 
    }
  }
}, action = "append")
