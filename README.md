# 1º Hackathon em Controle Social: Desafio Participa DF – Acesso à Informação

Solução do 1º Hackathon em Controle Social: Desafio Participa DF - Acesso à Informação, organizado pela Controladoria-Geral do Distrito Federal (CGDF). O desafio de Acesso à Infromação versa a respeito do desenvolvimento de solução para classificar automaticamente, entre os pedidos de acesso à informação marcados como públicos, aqueles que contenham dados pessoais. O edital foi publicado no Diário Oficial do Distrito Federal em 25 de novembro de 2025, e está disponível [neste link](https://dodf.df.gov.br/dodf/materia/visualizar?co_data=550905&p=edital-n-10de-24-de-novembro-de-2025).

![Status](https://img.shields.io/badge/Status-Stable-green) ![Language](https://img.shields.io/badge/Language-R-blue) ![License](https://img.shields.io/badge/License-MIT-yellow)

----
## Sumário
- [Sobre a solução](#sobre-a-solução)
- [Pré-requisitos do sistema](#pré-requisitos-do-sistema)
- [Configuração do ambiente](#configuração-do-ambiente)
- [Guia de execução](#guia-de-execução)
- [Especificação de dados](#especificação-de-dados)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Uso de inteligência artificial](#uso-de-inteligência-artificial)
- [Contato](#contato)

----

## Sobre a solução

### Objetivo
Esta solução tem como objetivo principal automatizar a detecção e classificação de solicitações de acesso à informação que contenham dados pessoais, atendendo diretamente ao item 2.2 do edital. Apesar das campanhas de conscientização da CGDF ([Video passo a passo para fazer seu pedido de acesso à informação](https://youtu.be/6pBADErxS-4?si=nbB-hph2b0uAZHzn) da @TVCONTROLADORIADF no YouTube) a realidade do servidor que recebe e responde estas solicitações, tarefa que desempenho ocasionalmente, confirma que a inclusão de dados pessoais nos pedidos de acesso à informação acontece com frequência.

Um dos passos da solução, que será tratado em mais detalhes adiante, foi a análise exploratória de solicitações de acesso à informação disponíveis no [FalaBR](https://buscalai.cgu.gov.br/DownloadDados/DownloadDados), [Ceará Transparente](https://cearatransparente.ce.gov.br/portal-da-transparencia/manifestacoes-e-solicitacoes-publicas?__=__) e [Dados Abertos do Espírito Santo](https://dados.es.gov.br/dataset/pedidos-de-informacoes). No início da análise, eram só muitos Josés, Marias, Paulos e Anas que compartilharam seus dados e nomes nas solicitações. O desafio se tornou real quando foi encontrada, de forma completamente aleatória, uma solicitação feita por uma pessoa que conheço. Nesta solicitação constavam o nome completo dela e onde trabalhava. Não tinha conhecimento desta última informação, até ler aquela solicitação. Quando a situação foi compartilhada com a pessoa, ela disse, entre risadas: "Pois é, minhas informações estão disponíveis na internet e meu pedido ainda foi indeferido."

Embora a identificação de um CPF, e-mail ou telefone seja uma tarefa simples para um ser humano, a execução repetitiva esbarra em um inimigo silencioso: a fadiga. O cansaço gera inconsistência, e a inconsistência gera riscos, seja o risco de expor um dados pessoais ou de ocultar uma informação que deveria ser pública. Se é simples para um humano reconhecer esses padrões, também é possível ensinar uma máquina a fazer o mesmo, com o benefício de que estas não se cansam. E neste ponto surge a pergunta: como ensinar uma máquina a reconhecer dados pessoais?


### Abordagem técnica
Existem tantas maneiras possíveis de ensinar uma máquina a reconhecer dados pessoais que testar todas elas para apresentar apenas a melhor solução gastaria um tempo que não está disponível para o escopo deste desafio. A frase utilizada como norte é do estatístico George Box (1976):

> *"Since all models are wrong the scientist must be alert to what is importantly wrong. It is inappropriate to be concerned about mice when there are tigers abroad."* (Tradução livre: "Como todos os modelos estão errados, o cientista deve estar alerta ao que está realmente errado. Não faz sentido se preocupar com ratos quando há tigres à solta.")

<p align="center">
  <img src="./img/tigre_01.png" alt="Pessoas se preocupam com ratos quando tem um grupo de tigres logo atrás delas" width="600px">
</p>

<p align="center"><em><strong>"Não faz sentido se preocupar com ratos quando há tigres à solta."</strong></em></p>

Partindo da ideia de que todos os modelos estão errados, devemos lembrar que nem todo erro tem o mesmo peso prático. Para o contexto desta solução, temos:

-   **Tigres**: São os dados pessoais reais (CPF, nome, endereço, e-mail) que o modelo deixa passar. Um "tigre" solto pode causar muito dano, pois viola a LGPD e expõe o cidadão a riscos reais. Um "tigre" solto é um falso negativo.
-   **Ratos**: São sequências, a princípio, inofensivas (número de Lei, protocolo, processo SEI) que o modelo confunde com dados pessoais. Eles são incômodos, mas são mais fáceis de controlar a longo prazo e não são o foco emergencial, pois o potencial de causar dano é menor. "Ratos" que são capturados pela solução são falsos positivos.

Desta maneira, a prioridade desta solução foi capturar o maior número possível de "tigres". Para tal, foi utilizada uma abordagem determinística, com análise de contexto e expressões regulares intencionalmente menos restritivas, e sem validação de valores, para capturar até mesmo dados digitados com erro. Como resultado, um pequeno número de "ratos" é capturado junto com os "tigres". Optou-se por uma abordagem determinística para que a solução tenha explicabilidade, seja rápida e reprodutível praticamente qualquer computador. A solução encontrada se mostrou satisfatória o bastante, de tal maneira que os ganhos que seriam obtidos ao se acrescentar métodos probabilísticos seriam decrescentes neste momento. Isto não quer dizer que não existem planos de uma nova versão dessa solução com a integração de modelos probabilísticos. Decidiu-se por se desenhar uma solução em R, onde os pacotes apresentam retrocompatibilidade e existem opções como `renv` que permite, de maneira simples, que o ambiente onde a solução foi desenhada seja reproduzido fielmente em outras máquinas. Nesta solução determinística é possível saber em que ponto ela falhou, e isto contribui para a melhoria contínua da mesma.

Os parágrafos abaixo trazem, de forma resumida, a estratégia desenhada para esta solução. Mais detalhes podem ser encontrados nos comentários das funções escritas para cada uma das regras. Os links de cada uma estão ao final do parágrafo de cada regra. As regras foram combinadas de tal maneira a serem todas chamadas para execução do script [`05_classificar_textos.R`](src/scripts/05_classificar_textos.R).

<p align="center">
  <img src="./img/tigre_02_03.png" alt="Dois tigres e um rato dentro de uma gaiola e alguns ratos fora da gaiola; pessoas passeando felizes enquanto há um único tigre à espreita." width="600px">
</p>

<p align="center"><em><strong>Às vezes ratos são capturados junto com os tigres, e podem persistir alguns tigres solitários</strong></em></p>

Dois princípios guiaram a solução: o do queijo suíço e do curto-circuito. O princípio do *queijo suíço* faz com que as várias camadas de diferentes regras capturem dados pessoais que não seriam capturados caso apenas uma regra estivesse em vigor. E para entender o efeito do princípio do *curto-circuito*, a ilustração dos tigres pode ser de ajuda. Se um tigre é visto numa região, não é necessário encontrar todos os tigres que estão ali para declarar que existem tigres naquela localidade. De modo similar, para a classificação de textos de solicitação de acesso à informação em público e não público, o texto é prontamente classificado como não público ao se encontrar um dado pessoal e a análise dele é finalizada naquele momento, não importando quantas regras ainda poderiam ser aplicadas. 

O primeiro passo foi a classificação manual dos textos de amostra do Hackathon, disponibilizados na [página oficial](https://www.cg.df.gov.br/w/1-hackathon-em-controle-social-desafio-participa-df) do desafio. O mesmo foi feito para 1.000 textos extraídos aleatoriamente de solicitações de acesso à informação feitas em 2025 encontradas no [FalaBR](https://buscalai.cgu.gov.br/DownloadDados/DownloadDados). Esta classificação manual dos textos permitiu que se pudesse acompanhar como estava o desempenho da solução e onde ela poderia melhorar. Além disso, foi feita a análise destes textos e dos encontrados no [Ceará Transparente](https://cearatransparente.ce.gov.br/portal-da-transparencia/manifestacoes-e-solicitacoes-publicas?__=__) e [Dados Abertos do Espírito Santo](https://dados.es.gov.br/dataset/pedidos-de-informacoes), onde foram anotados os tipos de dados pessoais encontrados, e os gatilhos que levam a declarações de dados pessoais. 

Expressões regulares foram utilizadas para detectar no texto da solicitação a ocorrência de e-mails, CEP, CPF e números de celulares.  Os resultados não foram validados, como a conferência se os telefones estão no formato permitido pela legislação, como, por exemplo, celulares com nono dígito "9" ou a validação dos dígitos verificadores do CPF. A regra para captura de e-mails permite erros simples de digitação, como "gmail,com". Scripts: [`detectar_cep.R`](src/utils/detectar_cep.R), [`detectar_cpf_celular.R`](src/utils/detectar_cpf_celular.R), e [`detectar_email.R`](src/utils/detectar_email.R).

Regras de expressões regulares foram combinadas com gatilhos para a detecção de outros documentos, como RG, título de eleitor, matrícula, OAB e inscrição das principais entidades de classe, passaporte, carteira de trabalho, Cartão Nacional de Saúde, data de nascimento, e informações bancárias e números de inscrição em geral. A regra utilizada para este caso foi de buscar a presença de quatro dígitos, com separadores ou não, na vizinhança imediata do texto próximo a gatilhos de texto referentes a estas informações. Scripts: [`detectar_data_nascimento.R`](src/utils/detectar_data_nascimento.R) e [`detectar_fixo_docs.R`](src/utils/detectar_fixo_docs.R).

A detecção de nomes ocorre pela pela comparação de trechos do texto com listas de nomes a partir gatilhos que podem levar a nomes, como "meu nome é", e "me chamo", e a varredura das palavras finais do texto, onde os cidadãos costumam escrever seus nomes completos para assinar a solicitação. As listas de nome foram construídas com base na lista de nomes e sobrenomes coletados no Censo 2022 do IBGE (script de [download](src/scripts/01_download_nomes_ibge.R) e [tratamento](src/scripts/02_criar_base_nomes_ibge.R)), e nos nomes e sobrenomes dos servidores do Distrito Federal presentes no Portal da Transparência em janeiro de 2026 ([script](src/scripts/03_criar_base_nomes_transparencia_df.R)). Estas listas foram salvas na pasta [`dados/processado`](dados/processado) deste repositório, e, para o bom desempenho da solução final, são lidas apenas as listas, e não há a reconstrução total delas. O repositório traz os scripts necessários para a reconstrução destas com todos os passos e tratamentos que foram feitos. Tal abordagem com as listas de nomes e sobrenomes do Censo 2022 e do Portal da Transparência do Distrito Federal permite que nomes relativamente raros sejam detectados por esta solução. Script: [`05_classificar_textos.R`](src/scripts/05_classificar_textos.R).

Por conta da complexidade do assunto, não foram elaboradas regras para a detecção de endereços sem CEP. Como a proposta desenhada não envolve a utilização de *machine learning*, não seria possível detectar endereços completos sem essa ferramenta. Além disso, mesmo com a utilização de modelos de *machine learning*, seria gasto muito tempo refinando o modelo para que ele evitasse confundir a mera citação de um endereço ("moro na QL 35") de a declaração de um endereço completo ("moro na QL 35 conjunto 14 casa 6"). Endereços sem CEP são "tigres" que esta solução não consegue capturar. Mas estes "tigres" não costumam andar sozinhos. Na análise exploratória feita nas solicitações disponíveis no FalaBR, Ceará Transparente e Dados Abertos do Espírito Santo, além do teste de estresse com a solução final feita com as solicitações do FalaBR, foi possível ver que não é comum o endereço ser o único dado pessoal declarado numa solicitação de análise de dados. As outras camadas de detecção de dados pessoais permitem com que o texto tenha a classificação correta e o "tigre" do endereço sem CEP seja encontrado.

Para evitar que dados como número de processos e protocolos, números de leis e afins sejam confundidos com dados pessoais, foi feita uma verificação na vizinhança de termos que levam a estas numerações. Se encontradas, estas eram prontamente mascaradas, ou, na narrativa utilizada neste documento, ratos muito parecidos com tigres eram escondidos. Script: [`05_classificar_textos.R`](src/scripts/05_classificar_textos.R).

## Pré-requisitos do sistema

### Versão da linguagem de programação: 
R versão 4.1 ou superior - [download](https://cloud.r-project.org/)

### Softwares necessários
RStudio Desktop versão 2023.06 ou superior - [download](https://posit.co/download/RStudio-desktop/)

### Sistema operacional
Windows 11

*Nota: Embora a solução tenha sido escrita puramente em código R e possa ser executada em qualquer ambiente (VS Code, Terminal, Jupyter) e qualquer sistema operacional, o caminho da solução final para avaliação no Hackathon foi otimizado no RStudio para Windows, permitindo que a execução seja simples e fluida. Aos que desejam reconstruir a solução do zero, podem utilizar o ambiente e sistema operacional de sua escolha.*

## Configuração do ambiente

### Gerenciador de pacotes
O arquivo [`00_requirements.R`](src/scripts/00_requirements.R) permite que os pacotes sejam instalados automaticamente, seja por meio do `renv`, ou, caso ocorra alguma falha na restauração do ambiente, o script acionará um método de contingência que instala os pacotes, tendo como fonte o repositório da Posit.


### Passo a passo de instalação
O script principal da solução, [`run.R`](run.R), executa o [`00_requirements.R`](src/scripts/00_requirements.R) logo no início do processo. Não é necessária nenhuma ação manual de instalação prévia. Mais detalhes sobre como executar a solução, que inclui a instalação de dependências, estão na próxima seção, [Guia de execução](#guia-de-execução).

## Guia de execução
Os passos a seguir descrevem o que deve ser feito para que o ambiente seja configurado e a solução seja executada:

- Clone este repositório (ou faça o download do arquivo ZIP). Para clonar via terminal, use o comando:
```bash
git clone https://github.com/ericala9/hackathon-cgdf-2026.git
```
- Instale o R e o RStudio nas versões indicadas na seção [Pré-requisitos do sistema](#pré-requisitos-do-sistema).
- Salve o arquivo em formato .xlsx com os textos a serem classificados na pasta `dados/entrada` do projeto.
- Abra o arquivo [`hackathon_cgdf_2026.Rproj`](hackathon_cgdf_2026.Rproj) no RStudio. O arquivo está na raiz do projeto.
- O arquivo [`run.R`](run.R) foi configurado para ser aberto automaticamente dentro de [`hackathon_cgdf_2026.Rproj`](hackathon_cgdf_2026.Rproj). Se isto não acontecer, abra-o dentro deste projeto no RStudio.

### Comando de execução
Com o arquivo [`run.R`](run.R) aberto dentro do [`hackathon_cgdf_2026.Rproj`](hackathon_cgdf_2026.Rproj), são três os caminhos possíveis, todos com o mesmo resultado. Escolha o que for mais conveniente.
- Clique em 'Source', no alto à direita na janela do script;
- Ou, execute no console do RStudio:
```R
source("run.R", encoding = "UTF-8")
```
- Ou, utilize o atalho de teclado **Ctrl + Shift + S**.

## Especificação de dados

### Formato de entrada
- Arquivo em formato .xlsx, a ser salvo na pasta `dados/entrada`. 

Será lida a primeira planilha do arquivo, que pode ter qualquer número de colunas. A solução foi desenhada para identificar qual a coluna que apresenta o texto com solicitação de acesso à informação. O arquivo de entrada pode ter qualquer nome, contanto que seja o único arquivo .xlsx na pasta.

### Formato de saída
- Arquivo em formato .xlsx, a ser salvo na pasta `dados/saida`.

O arquivo é uma cópia exata do arquivo de entrada, com o acréscimo da coluna "Classificacao", que terá os valores "Público" e "Não público". O nome do arquivo terá o formato `[NOME_ORIGINAL]_classificado.xlsx`.

## Estrutura do projeto

A solução segue uma arquitetura modular, separando claramente a lógica de orquestração ([`run.R`](run.R)), as funções auxiliares e de detecção de dados pessoais (pasta [`src/utils`](src/utils)) e os scripts de processamento sequencial (pasta [`src/scripts`](src/scripts)). Destes scripts de processamento sequencial, o script principal da solução ([`run.R`](run.R)) executa apenas os arquivos ([`00_requirements.R`](src/scripts/00_requirements.R)) e ([`05_classificar_textos.R`](src/scripts/05_classificar_textos.R)). 

Os scripts com numeração de 01 a 04 são preparatórios à classificação e foram executados previamente para gerar bases de conhecimento e insights distribuídos por toda a solução. O script principal ([`run.R`](run.R)) consome diretamente essas bases processadas, garantindo uma execução rápida.

Abaixo está a árvore que descreve os principais arquivos e pastas do projeto. Esta traz destaque para os pontos de interação do usuário:

```
hackathon-cgdf-2026/
├── hackathon_cgdf_2026.Rproj           # ⭐ Garante caminhos relativos corretos. ABRIR na execução.
├── run.R                               # ⭐ Instala dependências e executa a classificação. ABRIR na execução.
├── README.md                           # Documentação do projeto
├── renv.lock                           # Arquivo de bloqueio que documenta as versões dos pacotes
│
├── dados/                      
│   ├── entrada/                        # ⭐ COLOCAR AQUI o arquivo .xlsx com os textos a serem classificados
│   ├── processado/                     # Bases de conhecimento: listas de nomes do Censo 2022 e Portal da Transparência DF
│   └── saida/                          # ⭐ Onde o ARQUIVO FINAL será salvo: [NOME_ORIGINAL]_classificado.xlsx
│
└── src/                        
    ├── scripts/                
    │   ├── 00_requirements.R           # Instalação automática de pacotes
    │   ├── 01_download_nomes_ibge.R    # Download da lista de nomes e sobrenomes do Censo 2022 do IBGE
    │   ├── 02_criar_base_nomes_ibge.R  # Tratamento dos dados baixados do IBGE e criação da lista
    │   ├── 03_criar_base_nomes...R     # Download e tratamento dos nomes e sobrenomes do Portal da Transparência DF
    │   ├── 04_analise_explorat...R     # Análise exploratória das solicitações do FalaBR
    │   └── 05_classificar...R          # Classifica os textos utilizando as bases em dados/processado e as funções de utils
    │
    └── utils/                  
        ├── baixar_nomes_ibge.R         # Baixa lista de nomes e sobrenomes do Censo 2022 do IBGE
        ├── detectar_cep.R              # Detecta CEPs no texto
        ├── detectar_cpf_celular.R      # Detecta CPF e telefones celulares no texto
        ├── detectar_data_nasc...R      # Detecta data de nascimento no texto
        ├── detectar_email.R            # Detecta e-mails no texto
        ├── detectar_fixo_docs.R        # Detecta telefones fixos e numeração de documentos diversos no texto
        └── detectar_nomes.R            # Detecta nomes no texto
```

##  Uso de inteligência artificial

O desenvolvimento desta solução utilizou o Google Gemini 3. Este atuou como assistente de programação para a otimização de sintaxe de expressões regulares, depuração de scripts em R e estruturação da documentação técnica, além de auxílio na confecção das ilustrações deste documento. Ressalta-se que a IA foi utilizada apenas na etapa de desenvolvimento; o código final entregue é determinístico e não realiza chamadas externas a modelos de IA.

## Contato

Pode me contatar aqui pelo GitHub, na aba Issues deste repositório. Se já nos conhecemos, pode me procurar para falar o que achou da solução e trocarmos ideias sobre o assunto.
