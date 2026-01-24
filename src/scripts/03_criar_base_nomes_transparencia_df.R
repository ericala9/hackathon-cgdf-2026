# ==============================================================================
#  1º HACKATHON EM CONTROLE SOCIAL: DESAFIO PARTICIPA DF - ACESSO À INFORMAÇÃO
# ==============================================================================
# Script: src/scripts/03_criar_base_nomes_transparencia_df.R
# Objetivo: Ler dados do Portal da Transparência do Distrito Federal para
# enriquecer a lista de nomes do IBGE.
# Data: 2026-01
# ==============================================================================

# ---------------------------- Configuração inicial ---------------------------- 

library(dplyr)
library(readr)
library(stringr)
library(tidytext)
library(tm)

# -------------------- Download e Verificação do Arquivo ----------------------- 

# Cria a pasta se não existir
if (!dir.exists("dados/bruto")) dir.create("dados/bruto", recursive = TRUE)


nome_arquivo <- "dados/bruto/Servidores_Orgao_2025.zip"
link_arquivo <- "https://www.transparencia.df.gov.br/arquivos/Servidores_Orgao_2025.zip"

# Verifica se o arquivo existe. Se não, baixa automaticamente.
if (!file.exists(nome_arquivo)) {
  tryCatch({
    download.file(link_arquivo, 
                  destfile = nome_arquivo, mode = "wb")
    message(paste0("Download concluído com sucesso! Arquivo salvo em: '", nome_arquivo, "'"))
  }, error = function(e) {
    stop("Erro ao baixar o arquivo do Portal da Transparência. Verifique a conexão ou o link.")
  })
} else {
  message(paste0("Download não realizado, pois o arquivo de interesse já existe: '", nome_arquivo, "'"))
}

# ----------------------------- Leitura dos dados ------------------------------ 

# Arquivo disponível em: https://www.transparencia.df.gov.br/#/downloads
# Link direto: https://www.transparencia.df.gov.br/arquivos/Servidores_Orgao_2025.zip
# Acessado em 13 de janeiro de 2026.

# No site consta: "Nesta página estão disponíveis, em formato aberto, arquivos
# de dados provenientes de consultas do Portal da Transparência do Distrito
# Federal. Qualquer pessoa pode acessá-los e utilizá-los livremente, sem custos,
# nem necessidade de cadastro ou identificação prévia. [...] Conforme a Licença
# Creative Commons ShareAlike 4.0, disponível em:
# https://creativecommons.org/licenses/by-sa/4.0/deed.pt_BR"

portal <- read_csv2(unz(nome_arquivo, 
                        max(unzip(nome_arquivo, list = TRUE)$Name,
                            value = TRUE)),
                    locale = locale(encoding = "Latin1")) |> 
  select(NOME) |> 
  rename(nome = NOME) |> 
  distinct()
rm(nome_arquivo, link_arquivo)

# ---------------------------- Tratamento de dados -----------------------------  

# Transformação dos nomes em tokens.
portal_nomes <- portal  |>
  unnest_tokens(output = palavra, input = nome)  |>
  rename(nome = palavra) |>
  count(nome) |>
  # Remoção de nomes com menos de três ocorrências
  filter(n >= 3) |> 
  # Remoção palavras curtas, para evitar "de", "da", "e", "do"
  filter(nchar(nome) > 2) |>
  # Remoção de stopwords vindas de dicionário
  filter(!nome %in% stopwords("pt")) |>
  mutate(nome = str_to_title(nome)) |>
  arrange(nome) |> 
  select(nome)

# Após análise exploratória na lista de nomes com três letras, decidiu-se por
# acrescentar apenas estes à lista de nomes do IBGE.

# Nem todos os termos estão nos nomes provenientes do Portal da Transparência.
# Mas vou deixar a lista assim, porque se os dados mudarem, ela ainda será útil.
# Esta lista de exclusões está focada em termos burocráticos e conectivos.

# Retirada dos nomes com 3 caracteres que não estão na lista, e retirada de
# termos com 4 caracteres que se parecem com nomes. Após identificação
# exploratória de nomes desta lista presentes nas solicitações do FalaBR, retiro
# os nomes que têm mais chance de levarem a um falso positivo.
portal_nomes <- portal_nomes |> 
  filter(
    (nchar(nome) > 4) |
      (nome %in% c("Cho", "Chu", "Cox", "Guy", "Liu", "Liv", "Lyv", "Pak", "Yin", 
                   "Yui", "Acy", "Jim", "Joe", "Roy", "Ann", "Lys", "Kim", "Lee", 
                   "Ivy", "Leo", "Ary", "Lis", "Ivo", "Ian", "Eva", "Bia", "Dan", 
                   "Edu", "Gil", "Max", "Noe", "Rui")) |
      (nchar(nome) == 4 & !nome %in% c(
        "Para", "Pelo", "Pela", "Como", "Cada", "Todo", "Toda", "Qual", "Quem", 
        "Mais", "Meio", "Este", "Esta", "Isso", "Esse", "Essa", "Algo", "Tudo", 
        "Nada", "Data", "Teor", "Fase", "Base", "Item", "Area", "Bens", "Caso", 
        "Fato", "Acao", "Auto", "Juiz", "Vaga", "Veto", "Lote", "Nota", "Zona", 
        "Obras", "Valor", "Tipo", "Risco", "Grau", "Modo", "Vias", "Sede", 
        "Nome", "Peca", "Voto", "Teve", "Deve", "Pode", "Seja", "Fica", "Gera", 
        "Visa"))
  ) |> 
  filter(!str_to_lower(nome) %in% c("aba", "abad", "abade", "boa", "dia", "tarde", 
                                    "para", "pelo", "solicito", "piloto", 
                                    "interno","juvenil", "informado", "nao", 
                                    "adulto", "informar", "senhor", "bom", 
                                    "nova")
  ) |>  
  filter(
    !nome %in% c("Sao", "Brasil", "Brasilia", "Saude", "Responsavel", 
                 "Rio", "Grande", "Durante", "Tempo", "Cidade", "Datas", 
                 "Pais", "Areas")
  )

# ---------------------------- Exportação dos dados ---------------------------- 

# Criação da pasta de output se ela ainda não existir.
if (!dir.exists("dados/processado")) {
  dir.create("dados/processado")
}

saveRDS(portal_nomes, "dados/processado/nomes_transparencia_df.rds")

# Por que não usamos apenas o Censo do IBGE? Porque ele falha na proteção das
# minorias estatísticas.

# Encontramos casos reais, como o nome 'Karollina', presente na lista de
# servidores ativos e inativos do GDF, disponível no Portal da Transparência,
# mas ausente na base consolidada do IBGE. Sem essa etapa de extração do Portal
# da Transparência, alguém chamada 'Karollina Cogui', por exemplo, teria seus
# dados expostos, enquanto um 'João Silva' seria protegido. O sobrenome 'Cogui'
# não está em nenhuma das listas, então a detecção de nome pessoal depende
# exclusivamente do prenome.

# ---------------------------------- Outputs -----------------------------------
#
# Arquivo criado:
#                 dados/processado/nomes_transparencia_df.rds
#
# ------------------------------------------------------------------------------
#                                 Próximo passo 
# ------------------------------------------------------------------------------
# A) Para avaliação da solução:
#     src/scripts/05_classificar_textos.R
#
# B) Para reconstrução completa do projeto (opcional, não produz objetos,apenas 
# traz insights para melhoria e refinamento da solução):
#     src/scripts/04_analise_exploratoria_FalaBR.R
# ------------------------------------------------------------------------------

