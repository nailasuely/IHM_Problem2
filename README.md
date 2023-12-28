<div align="center">
<h2> 🖥️ Problema #2 - Interface Homem-Máquina </h2>
<div align="center">


</div>

> Este é um projeto da disciplina TEC 499 - Módulo Integrador Sistemas Digitais, focado no desenvolvimento de uma Interface Homem-Máquina (IHM) que apresentará as informações do sensor em um display LCD. Esta nova interface substituirá a anterior, que foi desenvolvida em linguagem C.

## Download do repositório


```
gh repo clone nailasuely/IOInterfacesProblem1
```

<div align="left">
	
## Sumário
- [Apresentação](#apresentação)
- [Implementação](#implementação)
- [Executando o Projeto](#executando-o-projeto)
- [Testes](#testes)
- [Conclusão](#conclusão) 
- [Tutor](#tutor)
- [Equipe](#equipe)
- [Referências](#referências)

  
## Apresentação 
Este documento detalha o desenvolvimento de uma comunicação UART entre um microcontrolador ESP e um computador de placa única Orange Pi PC Plus, além de um sistemas de menus para uso pelo usuário, utilizando a linguagem assembly da arquitetura ARM V7. O projeto consiste em um sistema que tem como objetivo viabilizar a comunicação com sensores, especialmente o DHT11. Para visualização dos dados requisitados, um display LCD 16x2 é utilizado, proporcionando uma apresentação humanamente agradável  das informações.

Para estabelecer a comunicação com o sensor, empregou-se o projeto do monitor de Sistemas Digitais desenvolvido por Paulo Queiroz durante o semestre 2023.2 na UEFS. No [repositório correspondente](https://github.com/PauloQueirozC/EspCodigoPBL2_20232), estão disponíveis informações detalhadas sobre os comandos utilizados e suas respectivas respostas.

## Implementação
Para a compreensão do problema, foi necessário avaliar qual seria a estrutura utilizada para  a organização das telas, bem como ao entendimento dos fluxos normal e contínuo durante a execução do código. Essa análise, foi essencial para o desenvolvimento do sistema, resultou na criação de uma estrutura (Imagem XX)  que passou por diversas modificações ao longo do processo de codificação. Isso foi feito para destacar não apenas as telas que seriam utilizadas, mas também para ilustrar de que maneira essas telas interagiriam com os botões que são elementos importantes para a navegação e seleção de telas.

A estrutura final, que acompanha o fluxo do sistema exibido no LCD, está apresentada na imagem abaixo. Detalharemos essa organização ao decorrer deste tópico, fornecendo uma explicação do desenvolvimento dos módulos codificados em assembly que tornaram possível o funcionamento de cada tela específica.  A imagem representa uma síntese de inúmeras telas e como elas podem funcionar no sistema.


## Executando o Projeto
1. Abra o terminal.
   
2. Executar-se o seguinte comando para a comunicação com a placa Orange Pi Pc Plus: 
    ```bash
    ssh usuário@id-da-Orange-pi
    ```
3. Certifique-se de estar no diretório correto ou mude para o diretório desejado usando o comando:
    ```bash
    cd diretório/do/arquivo
    ```
4. Para compilar e executar o projeto, utilize o comando:
    ```bash
    make all
    ```
   O arquivo "Makefile" possui os seguintes comandos:
    ```bash
    as -o main.o main.s
    ld -o main main.o
    sudo ./main
    ```
    Esses comandos montam o código assembly, conectam os módulos e executam o programa final.

## Tutor 
- Anfranserai Morais Dias

## Equipe 
- [Naila Suele](https://github.com/nailasuely)
- [Rhian Pablo](https://github.com/rhianpablo11)
- [João Gabriel Araujo](https://github.com/joaogabrielaraujo)
- [Amanda Lima](https://github.com/AmandaLimaB)



## Referências 
> - [1] Smith, Stephen. (2019). Raspberry Pi Assembly Language Programming: ARM Processor Coding. Apress.
> - [2]  Allwinner. (2015). Allwinner H3 Datasheet Quad-Core OTT Box Processor.
> - [3] Queiroz, P. (2023). EspCodigoPBL2_20232. GitHub. https://github.com/PauloQueirozC/EspCodigoPBL2_20232



</div>
