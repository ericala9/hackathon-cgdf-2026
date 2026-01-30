# Dados Processados

Esta pasta contém arquivos em formato `.rds` utilizados como base de conhecimento para a detecção de nomes próprios e sobrenomes na solução.

Estes arquivos não precisam ser gerados novamente para a execução da solução (pois já estão processados), mas podem ser reconstruídos utilizando os scripts indicados abaixo. Os dados das listas estão tratados para o escopo deste projeto.

## Origem e Geração dos Dados

### 1. Nomes do Censo 2022 do IBGE
- **Conteúdo:** Lista de nomes e sobrenomes frequentes no Brasil.
- **Fonte:** Site do Censo 2022 do IBGE.
- **Scripts de Geração:**
  - [`01_download_nomes_ibge.R`](../src/scripts/01_download_nomes_ibge.R)
  - [`02_criar_base_nomes_ibge.R`](../src/scripts/02_criar_base_nomes_ibge.R)

### 2. Nomes do Portal da Transparência do Distrito Federal
- **Conteúdo:** Lista de nomes e sobrenomes de servidores do GDF (referência: Janeiro/2026).
- **Fonte:** Portal da Transparência do Distrito Federal.
- **Script de Geração:**
  - [`03_criar_base_nomes_transparencia_df.R`](../src/scripts/03_criar_base_nomes_transparencia_df.R)

## Licença de Uso - Portal da Transparência do Distrito Federal

Os dados derivados do Portal da Transparência do Distrito Federal seguem os termos de uso declarados na fonte original:

> "Nesta página estão disponíveis, em formato aberto, arquivos de dados provenientes de consultas do Portal da Transparência do Distrito Federal. Qualquer pessoa pode acessá-los e utilizá-los livremente, sem custos, nem necessidade de cadastro ou identificação prévia. [...] Conforme a **Licença Creative Commons ShareAlike 4.0**, disponível em: https://creativecommons.org/licenses/by-sa/4.0/deed.pt_BR"

Em conformidade com a licença, estes dados processados são compartilhados sob os mesmos termos.
