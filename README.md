# 1º Hackathon em Controle Social: Desafio Participa DF – Acesso à Informação

Solução do 1º Hackathon em Controle Social: Desafio Participa DF - Acesso à Informação, organizado pela Controladoria-Geral do Distrito Federal (CGDF). O desafio de Acesso à Infromação versa a respeito do desenvolvimento de solução para classificar automaticamente, entre os pedidos de acesso à informação marcados como públicos, aqueles que contenham dados pessoais. O edital foi publicado no Diário Oficial do Distrito Federal em 25 de novembro de 2025, e está disponível [neste link](https://dodf.df.gov.br/dodf/materia/visualizar?co_data=550905&p=edital-n-10de-24-de-novembro-de-2025).

![Status](https://img.shields.io/badge/Status-Stable-green) ![Language](https://img.shields.io/badge/Language-R-blue) ![License](https://img.shields.io/badge/License-MIT-yellow)

## Sobre o Projeto

Conforme disposto no item 2.2 do edital, o desafio consiste em classificar **automaticamente** solicitações que contenham dados pessoais.

Embora a identificação de um CPF, e-mail ou telefone seja uma tarefa simples para um ser humano, a execução repetitiva esbarra em um inimigo silencioso: a fadiga. O cansaço gera inconsistência, e a inconsistência gera riscos, seja o risco de expor um dado dados pessoais ou de ocultar uma informação que deveria ser pública.

Se é simples para um humano reconhecer esses padrões, também é possível ensinar uma máquina a fazer o mesmo, com o benefício que estas não se cansam. No entanto, diantes de tantos modelos possíveis, como escolher qual é o melhor? Como bem lembrado pelo estatístico George Box (1976):

> *"Since all models are wrong the scientist must be alert to what is importantly wrong. It is inappropriate to be concerned about mice when there are tigers abroad."*
> *(Como todos os modelos estão errados, o cientista deve estar alerta ao que está 'importantemente' errado. É inapropriado preocupar-se com ratos quando há tigres à solta.)* - Tradução livre

Partindo do pressuposto que todos os modelos estão errados, é importante se concentrar onde os 'tigres' estão. Nesta solução, **os Tigres são os Dados Pessoais Reais**. Deixá-los escapar (Falso Negativo) é o erro inaceitável, pois viola a LGPD e expõe o cidadão. Os **ratos** são os Falsos Positivos — sequências numéricas que parecem dados pessoais, mas não são.

### A Estratégia de Detecção

Nesta solução, **os Tigres são os Dados Pessoais Reais**. Deixá-los escapar (Falso Negativo) é o erro inaceitável, pois viola a LGPD e expõe o cidadão.
Os **Ratos** são os Falsos Positivos — sequências numéricas que parecem dados pessoais, mas não são (como o número de uma Lei ou Protocolo).

Com isso em mente, foi desenvolvida uma solução com **Viés de Segurança**:

1. **Caça aos Tigres (Recall alto):** O sistema é calibrado para capturar padrões que se assemelhem a um dado pessoal.
2. **Controle de Ratos (Imunização):** São aplicadas regras de contexto para limpar casos óbvios (ex: leis, CNPJs), mas são aceitas margens residuais de falsos positivos em favor da segurança dos dados.

O resultado é uma ferramenta que busca proteger o cidadão que solicita acesso à informação e otimiza drasticamente o tempo do servidor público, entregando uma triagem segura e auditável.


### Diferenciais Técnicos
* **Filosofia "Safety-First":** A arquitetura prioriza o **Recall (Sensibilidade)**. Em testes de validação, o sistema atingiu **100% de Recall** (zero vazamento de dados), mantendo uma taxa de revisão manual (falsos positivos) inferior a 5%.
* **Imunização Contextual:** Utiliza algoritmos de limpeza prévia que distinguem dados pessoais reais de padrões governamentais comuns que geram falso positivo (ex: números de leis, NUPs, CNPJs e datas).
* **Auditabilidade:** Diferente de modelos "caixa preta", todas as regras de classificação são determinísticas e rastreáveis.

---

## 🛠️ Instalação e Configuração

*Critério P2.1: Instalação e Dependências*

### 1. Pré-requisitos
Para executar este projeto, você precisará apenas de:
* **R** (versão 4.0.0 ou superior) instalado.
* **RStudio** (recomendado para visualização, mas opcional).
* Sistema Operacional: Windows, Linux ou macOS.

### 2. Gerenciamento de Dependências (Automático)
Este projeto utiliza o pacote `renv` para garantir que o ambiente seja exatamente o mesmo em qualquer máquina, isolando as bibliotecas do sistema. O arquivo `renv.lock` contém a lista exata de versões utilizadas.

### 3. Passo a Passo de Instalação

1.  Clone este repositório:
    ```bash
    git clone [https://github.com/SEU-USUARIO/participa-df-classificador.git](https://github.com/SEU-USUARIO/participa-df-classificador.git)
    cd participa-df-classificador
    ```

2.  Abra o projeto no R (ou abra o arquivo `ParticipaDF.Rproj` no RStudio).

3.  No console do R, execute o comando para restaurar o ambiente:
    ```r
    if (!require("renv")) install.packages("renv")
    renv::restore()
    ```
    *O sistema irá baixar e instalar automaticamente todas as bibliotecas necessárias listadas no `renv.lock`.*

---

## ▶️ Como Executar

*Critério P2.2: Execução e Formatos de Dados*

O fluxo de execução é centralizado no script mestre `run.R`.

### 1. Formato de Entrada
O sistema espera arquivos na pasta `dados/entrada/`.
* **Formato suportado:** `.csv` ou `.xlsx`.
* **Estrutura:** O arquivo deve conter uma coluna com os textos dos pedidos. O script detecta automaticamente colunas de texto comuns.

### 2. Comando de Execução
Com o ambiente configurado, execute no console do R:

```r
source("run.R")

```

### 3. Formato de Saída

O resultado será gerado na pasta `dados/saida/` com o nome `resultado_classificacao.xlsx`.

* **O arquivo contém:** O texto original, a classificação binária ("Público" / "Não Público"), o motivo da classificação (ex: "CPF Identificado") e o trecho que disparou o alerta (mascarado para segurança).

---

## 📂 Estrutura do Projeto

*Critério P2.3: Clareza e Organização*

A estrutura de pastas foi desenhada para separar lógica, dados e configuração:

* `R/`: Contém os scripts modulares com as funções de negócio.
* `01_leitura.R`: Carregamento e padronização dos dados.
* `02_limpeza.R`: Rotinas de "imunização" (remoção de leis, datas, etc).
* `03_regex.R`: Biblioteca de padrões para CPF, Email, Telefone.
* `04_nlp.R`: Identificação de nomes próprios.
* `05_classificacao.R`: Lógica de decisão e geração de relatório.


* `dados/`:
* `entrada/`: Local para depositar os arquivos a serem auditados.
* `saida/`: Local onde os relatórios finais são salvos.
* `recursos/`: Bases de conhecimento auxiliares (listas de nomes, stopwords).


* `run.R`: Script principal que orquestra todo o pipeline.
* `renv.lock`: Manifesto de dependências (reprodutibilidade).

---

## 🤖 Uso de Inteligência Artificial

*Em conformidade com o item 13.9 do Edital:*
Este projeto utilizou Grandes Modelos de Linguagem (LLMs), especificamente o Gemini (Google), para auxílio na otimização de Expressões Regulares (Regex) complexas e refinamento da documentação. A lógica de classificação final, contudo, é estritamente algorítmica e determinística, não dependendo de chamadas de API de IA em tempo de execução.

## 📝 Licença

Este projeto (código-fonte) é distribuído sob a **Licença MIT**. Consulte o arquivo `LICENSE` para mais detalhes.

**Nota sobre os Dados:**
As bases de conhecimento utilizadas para detecção de nomes foram derivadas de dados públicos do Portal da Transparência do Distrito Federal e, conforme a fonte original, estão disponíveis sob a licença **Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0)**.

```
