# 1º Hackathon em Controle Social: Desafio Participa DF – Acesso à Informação

Solução do 1º Hackathon em Controle Social: Desafio Participa DF - Acesso à Informação, organizado pela Controladoria-Geral do Distrito Federal (CGDF). O desafio de Acesso à Infromação versa a respeito do desenvolvimento de solução para classificar automaticamente, entre os pedidos de acesso à informação marcados como públicos, aqueles que contenham dados pessoais. O edital foi publicado no Diário Oficial do Distrito Federal em 25 de novembro de 2025, e está disponível [neste link](https://dodf.df.gov.br/dodf/materia/visualizar?co_data=550905&p=edital-n-10de-24-de-novembro-de-2025).

![Status](https://img.shields.io/badge/Status-Stable-green) ![Language](https://img.shields.io/badge/Language-R-blue) ![License](https://img.shields.io/badge/License-MIT-yellow)

----

## Sobre a solução

### Objetivo do Projeto
Conforme disposto no item 2.2 do edital, o desafio consiste em classificar automaticamente solicitações que contenham dados pessoais. As campanhas de conscientização da CGDF sobre o Participa DF incluem instruções de boas práticas sobre a não inclusão de dados pessoais na solicitação de acesso à informação, como pode ser visto no [Video passo a passo para fazer seu pedido de acesso à informação](https://youtu.be/6pBADErxS-4?si=nbB-hph2b0uAZHzn) da @TVCONTROLADORIADF no YouTube. Apesar disso, a realidade do servidor que recebe e responde estas solicitações, tarefa que desempenho ocasionalmente, confirma que a inclusão de dados pessoais nos pedidos de acesso à informação acontece com frequência.

Um dos passos da solução, que será tratado em mais detalhes adiante, foi a análise exploratória de solicitações de acesso à informação disponíveis no [FalaBR](https://buscalai.cgu.gov.br/DownloadDados/DownloadDados), [Ceará Transparente](https://cearatransparente.ce.gov.br/portal-da-transparencia/manifestacoes-e-solicitacoes-publicas?__=__) e [Dados Abertos do Espírito Santo](https://dados.es.gov.br/dataset/pedidos-de-informacoes). No início da análise, eram só muitos Josés, Marias, Paulos e Anas que compartilharam seus dados e nomes nas solicitações. O desafio se tornou real quando foi encontrada, de forma completamente aleatória, uma solicitação feita por uma pessoa que conheço. Nesta solicitação estava o nome completo dela e onde trabalhava. Não tinha conhecimento desta última informação, até ler aquela solicitação. Quando a situação foi compartilhada com a pessoa, e ela disse, entre risadas: "Pois é, minhas informações estão disponíveis na internet e meu pedido ainda foi indeferido."

Embora a identificação de um CPF, e-mail ou telefone seja uma tarefa simples para um ser humano, a execução repetitiva esbarra em um inimigo silencioso: a fadiga. O cansaço gera inconsistência, e a inconsistência gera riscos, seja o risco de expor um dado dados pessoais ou de ocultar uma informação que deveria ser pública. Se é simples para um humano reconhecer esses padrões, também é possível ensinar uma máquina a fazer o mesmo, com o benefício que estas não se cansam. E neste ponto surge a pergunta: como ensinar uma máquina a reconhecer dados pessoais?


### Abordagem Técnica
Existem tantas maneiras possíveis de ensinar uma ensinar uma máquina a reconhecer dados pessoais que testar todas elas para apresentar apenas a melhor solução gastaria um tempo que não está disponível para o escopo deste desafio. A frase utilizada como norte ao ao se decidir o que fazer é do estatístico George Box (1976):

> *"Since all models are wrong the scientist must be alert to what is importantly wrong. It is inappropriate to be concerned about mice when there are tigers abroad."* (Tradução livre: "Como todos os modelos estão errados, o cientista deve estar alerta ao que está 'importantemente' errado. Não faz sentido se preocupar com ratos quando há tigres à solta.")

<p align="center">
  <img src="./img/tigre_01.png" alt="Pessoas se preocupam com ratos quando tem um grupo de tigres logo atrás delas" width="600px">
</p>

<p align="center"><em><strong>"Não faz sentido se preocupar com ratos quando há tigres à solta."</strong></em></p>

Partindo da ideia que todos os modelos estão errados, os erros podem ter o mesmo peso no edital, mas nem todo erro tem o mesmo peso prático. Para o contexto desta solução, temos:

-   **Os Tigres** (falsos negativos): São os dados pessoais reais (CPF, nome, endereço, e-mail) que o modelo deixa passar. Um "tigre" solto pode causar muito dano, pois viola a LGPD e expõe o cidadão a riscos reais.
-   **Os Ratos** (falsos positivos): São sequências, a princípio, inofensivas (número de Lei, Protocolo, processo SEI) que o modelo confunde com dados pessoais. Eles são incômodos, mas são mais fáceis de controlar a longo prazo e não são o foco emergencial, pois o potencial de causar dano é menor.

Desta maneira, foi a prioridade desta solução foi capturar o maior número possível de "tigres". Para tal, foi utilizada uma abordagem determinística, com análise de contexto e expressões regulares intencionalmente menos restritivas, e sem validação de valores, para capturar até mesmo dados digitados com erro. Como resultado, um pequeno número de "ratos" é capturado junto com os "tigres". Esta solução não envolve *machine learning* e/ou inteligência artificial, por conta do tempo necessário para treinar e ajustar modelos para este contexto, e a incerteza quanto ao tipo de hardware disponível para a avaliação da solução final. A solução encontrada se mostrou satisfatória o bastante, de tal maneira que os ganhos que seria obtidos ao se acrescentar métodos probabilísticos seriam decrescentes neste momento. Isto não quer dizer que não existem planos de uma nova versão dessa solução com a integração de modelos proabilísiticos. Decidiu-se por se desenhar uma solução em R, onde os pacotes apresentam retrocompatibilidade e existem opções como `renv` que permite de maneira simples que o ambiente onde a solução foi desenhada seja reproduzido de maneira simples em outras máquinas. Nesta solução deterministística é possível saber em que ponto ela falhou, e isto contribui para a melhoria contínua da mesma.

Os parágrafos abaixo trazem, de forma resumida, a estratégia desenhada para esta solução. Mais detalhes podem ser encontrados nos comentários das funções funções escritas para cada uma das regras. Os links de cada uma estão ao final do parágrafo de cada regra. As regras foram combinadas de tal maneira a serem todas chamadas para execução do [05_classificar_textos.R](script src/scripts/05_classificar_textos.R).

<p align="center">
  <img src="./img/tigre_02_03.png" alt="Dois tigres e um rato dentro de uma gaiola e alguns ratos fora da gaiola; pessoas passeando felizes enquanto há um único tigre à espreita." width="600px">
</p>

<p align="center"><em><strong>Às vezes ratos são capturados junto com os tigres, e podem persistir alguns tigres solitários</strong></em></p>

Dois princípios guiaram a solução: o do queijo suíço e do curto-circuito. O princípio do queijo suíço faz com que as várias camadas de diferentes regras capturem dados pessoais que não seriam capturados caso apenas uma regra estivesse em vigor. Seguindo na ilustração dos tigres, se um tigre é visto numa região, não é necessário encontrar todos os tigres que estão ali para declarar que existem tigres naquela localidade. De modo similar, para a classificação de textos de solicitação de acesso à informação em público e não público, é aplicado o princípio do curto-circuito, que contribui para a otimização de performance computacional: o texto é prontamente classificado ao se encontrar um dado pessoal e a análise dele é finalizada naquele momento, não importando quantas regras ainda poderiam ser aplicadas. 

Expressões regulares foram utilizadas para detectar no texto da solicitação a ocorrência de e-mails, CEP, CPF e números de celulares.  Os resultados não foram validados, como a conferência se os telefones estão no formato permitido pela legislação, como, por exemplo, celulares com nono dígito "9" ou a validação dos dígitos verificadores do CPF. A regra para captura de e-mails permite erros simples de digitação, como "gmail,com". Scripts: [detectar_cep.R](src/utils/detectar_cep.R), [detectar_cpf_celular.R](src/utils/detectar_cpf_celular.R), e [detectar_email.R](src/utils/detectar_email.R).

Regras de expressões regulares foram combinadas com gatilhos para a detecção de outros documentos, como RG, título de eleitor, matrícula, OAB e inscrição das principais entidades de classe, passaporte, carteira de trabalho, Cartão Nacional de Saúde, data de nascimento, e informações bancárias e números de inscrição em geral. A regra utilizada para este caso foi de buscar a presença de quatro dígitos, com separadores ou não, na vizinha imediata do texto próximo a gatilhos de texto referentes à estas informações. Scripts: [detectar_data_nascimento.R](src/utils/detectar_data_nascimento.R) e [detectar_fixo_docs.R](src/utils/detectar_fixo_docs.R).

A detecção de nomes em comparação de trechos do texto com listas de nomes a partir gatilhos que podem levar a nomes, como "meu nome é", e "me chamo", e a varredura das palavras finais do texto, onde os cidadãos costumam escrever seus nomes completos para assinar a solicitação. As listas de nome foram construídas com base na lista de nomes e sobrenomes coletados no Censo 2022 do IBGE (script de [download](src/scripts/01_download_nomes_ibge.R) e [tratamento](src/scripts/02_criar_base_nomes_ibge.R)), e nos nomes e sobrenomes dos servidores do Distrito Federal presentes no Portal da Transparência em janeiro de 2026 ([script](src/scripts/03_criar_base_nomes_transparencia_df.R)). Estas listas foram salvas na pasta [dados/processado](dados/processado) deste repositório, e, para o bom desempenho da solução final, são lidas apenas as listas, e não há a reconstrução total delas. O repositório traz os scripts necessários para a reconstrução destas com todos os passos e tratamentos que foram feitos. Tal abordagem com as listas de nomes e sobrenomes do Censo 2022 e do Portal da Transparência do Distrito Federal permite com que nomes relativamente raros sejam detectados por esta solução. Script: [detectar_nomes.R](src/utils/detectar_nomes.R)

Por conta de sua complexidade do assunto, não foram elaboradas regras para a detecção de endereços sem CEP. Como a proposta desenhada não envolve a utilização de *machine learning*, não seria possível detectar endereços completos sem essa ferramenta. Além disso, mesmo com a utilização de modelos de *machine learning*, gastaria-se muito tempo refinando o modelo para que ele evitasse confudir a mera citação de um endereço ("moro na QL 35") de a declaração de um endeço completo ("moro na QL 35 conjunto 14 casa 6"). Endereços sem CEP são "tigres" que esta solução não consegue capturar. Mas estes "tigres" não costumam andar sozinhos. Na análise exploratória feita nas solicitações disponíveis no FalaBR, Ceará Transparente e Dados Abertos do Espírito Santo, além do teste de estresse com a solução final feita com as solicitações do FalaBR, foi possível ver que não é comum o endereço ser o único dado pessoal declarado numa solicitação de análise de dados. As outras camadas de detecção de dados pessoais permitem com que o texto tenha a classificação correta e o "tigre" do endereço sem CEP seja encontrado.

Para evitar que dados como número de processos e protocolos, números de leis e afins sejam confundidos com dados pessoais, foi feita uma verificação na vizinhança de termos que levam à estas numerações. Se encontradas, estas eram prontamente mascaradas, ou, na narrativa utilizada neste documento, ratos muito parecidos com tigres eram escondidos. Script: [05_classificar_textos.R](script src/scripts/05_classificar_textos.R).

## Pré-requisitos do Sistema

### Versão da Linguagem: 
R versão 4.1 ou superior - [download](https://vps.fmvz.usp.br/CRAN/)

### Softwares Necessários
RStudio Desktop versão 2023.06 ou superior - [download](https://posit.co/download/rstudio-desktop/)

### Sistema Operacional
Windows 11

*Nota: Embora a solução tenha sido escrita puramente em código R e possa ser executada em qualquer ambiente (VS Code, Terminal, Jupyter) e qualquer sistema operacional, o caminho da solução final para avaliação no Hackathon foi otimizado para a experiência "One-Click" do RStudio. Aos que desejam reconstruir a solução do zero, podem utilizar o ambiente e sistema operacional de sua escolha.*

## Gestão de Dependências e Instalação

### Gerenciador de Pacotes
Os pacotes são instalados automaticamente 
Menção explícita ao uso do renv para reprodutibilidade.

### Passo a Passo de Instalação
Comandos sequenciais para restaurar o ambiente (ex: renv::restore()).

## Guia de Execução (Pipeline)

(Atende ao critério: Instruções de Execução - item a )

### Comando de Execução
O comando exato para rodar o script principal (ex: source("run.R")).

### Argumentos
Se houver necessidade de apontar arquivos específicos.

## Especificação de Dados (Entrada e Saída)

(Atende ao critério: Instruções de Execução - item b )

### Formato de Entrada
Descrição da planilha Excel esperada (colunas, formato).

### Formato de Saída
Descrição exata do arquivo gerado (colunas "ID" e "Classificacao", formato .xlsx ou .csv conforme sua entrega).

##  Estrutura do Projeto (Arquitetura de Arquivos)

(Atende ao critério: Clareza e Organização - itens a e c )

### Árvore de Diretórios
Diagrama ou lista das pastas (data/, src/, output/).

### Dicionário de Arquivos
Explicação breve da função de cada script importante (ex: 01_limpeza.R - normaliza texto; 02_classifica.R - aplica regex).

##  Declaração de Uso de Inteligência Artificial

(Atende ao critério: Disposições Gerais - item 13.9 )

### Modelos/Ferramentas
Indicação clara se usou LLMs para auxílio no código ou lógica.

### Bibliotecas e Fontes
Citação das fontes utilizadas (se aplicável).
