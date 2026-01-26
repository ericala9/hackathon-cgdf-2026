# 1º Hackathon em Controle Social: Desafio Participa DF – Acesso à Informação

Solução do 1º Hackathon em Controle Social: Desafio Participa DF - Acesso à Informação, organizado pela Controladoria-Geral do Distrito Federal (CGDF). O desafio de Acesso à Infromação versa a respeito do desenvolvimento de solução para classificar automaticamente, entre os pedidos de acesso à informação marcados como públicos, aqueles que contenham dados pessoais. O edital foi publicado no Diário Oficial do Distrito Federal em 25 de novembro de 2025, e está disponível [neste link](https://dodf.df.gov.br/dodf/materia/visualizar?co_data=550905&p=edital-n-10de-24-de-novembro-de-2025).

![Status](https://img.shields.io/badge/Status-Stable-green) ![Language](https://img.shields.io/badge/Language-R-blue) ![License](https://img.shields.io/badge/License-MIT-yellow)

------------------------------------------------------------------------

## Sobre a solução

Conforme disposto no item 2.2 do edital, o desafio consiste em classificar **automaticamente** solicitações que contenham dados pessoais.

Embora a identificação de um CPF, e-mail ou telefone seja uma tarefa simples para um ser humano, a execução repetitiva esbarra em um inimigo silencioso: a fadiga. O cansaço gera inconsistência, e a inconsistência gera riscos, seja o risco de expor um dado dados pessoais ou de ocultar uma informação que deveria ser pública.

Se é simples para um humano reconhecer esses padrões, também é possível ensinar uma máquina a fazer o mesmo, com o benefício que estas não se cansam. No entanto, diantes de tantos modelos possíveis, como escolher qual é o melhor? Como bem lembrado pelo estatístico George Box (1976):

> *"Since all models are wrong the scientist must be alert to what is importantly wrong. It is inappropriate to be concerned about mice when there are tigers abroad."* (Tradução livre: "Como todos os modelos estão errados, o cientista deve estar alerta ao que está 'importantemente' errado. Não faz sentido se preocupar com ratos quando há tigres à solta.")

<p align="center">
  <img src="./img/tigre_01.png" alt="Pessoas se preocupadas com ratos quando tem um grupo de tigres logo atrás delas" width="600px">
</p>

<p align="center"><em><strong>"Não faz sentido se preocupar com ratos quando há tigres à solta."</strong></em></p>

Partindo do pressuposto que todos os modelos estão errados, nem todo erro tem o mesmo peso prático. Para o contexto desta solução, temos:

-   **Os Tigres (Falsos Negativos):** São os dados pessoais reais (CPF, nome, endereço, e-mail) que o modelo deixa passar. Um "tigre" solto pode causar muito dano, pois viola a LGPD e expõe o cidadão a riscos reais.
-   **Os Ratos (Falsos Positivos):** São sequências, a princípio, inofensivas (número de Lei, Protocolo, CNPJ) que o modelo confunde com dados pessoais. Eles são incômodos, mas são mais fáceis de controlar a longo prazo e não são o foco emergencial, pois o potencial de causar dano é menor.

Desta maneira, foi a prioridade desta solução foi capturar o maior número possível de "tigres", isto é recall máximo. Para tal, foi utilizada uma abordagem determinística, com análise de contexto e expressões regulares intencionalmente menos restritivas, e sem validação de valores, para capturar até mesmo dados digitados com erro. Como resultado, um pequeno número de "ratos" é captuado junto com os "tigres".
