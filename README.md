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

<p align="center">
  <img width="" src="https://github.com/nailasuely/IHM_Problem2/blob/main/resources/2.1.png" />
</p>

Na fase inicial do desenvolvimento do projeto, focamos na criação das interfaces visuais, sendo essencial compreender o funcionamento do GPIO (General Purpose Input/Output). Para atingir o funcionamento de maneira eficaz, desenvolvemos o módulo "gpio.s".

### GPIO
O primeiro mapeamento feito é o para realizar o mapear os pinos GPIO na memória do sistema. Isto é necessário para que o programa possa interagir diretamente com esses pinos e controlar os dispositivos conectados a eles. Este mapeamento é feito através de chamadas de sistemas, no qual primeiro o código abre o arquivo “/dev/men” que concede permissões de leitura e escrita armazenando o descritor do arquivo em um registrador (R4). Posteriormente, a syscall mmap2 é utilizada para mapear uma região de memória que corresponde aos pinos GPIO. Nesse processo também é definido a variável “pagelen” que usada para obter o tamanho da página de memória do sistema e o endereço físico do registrador (gpioaddr) é lido e a chamada de sistema é usada para indicar que o sistema operacional deve escolher o endereço da memória mapeada. Assim, como resultado, a região de memória que contém os registradores é mapeada para um endereço virtual que é ajustado adicionando 0x800, que fornece o endereço base no qual os pinos da GPIO podem ser acessados.

Uma macro destacada no código é MemoryMap, responsável por realizar o mapeamento dos registradores GPIO na memória do sistema. Isso é alcançado através do uso de chamadas de sistema (sys_open e sys_mmap2) para abrir o arquivo /dev/mem e mapear a região de memória correspondente aos GPIO. Este é um passo crítico para permitir o acesso direto e seguro aos registradores de hardware.

Outras macros, como GPIOPinIn e GPIOPinOut, são utilizadas para configurar pinos GPIO específicos como entrada ou saída, respectivamente. Essas macros manipulam os registradores de função dos pinos, garantindo que a configuração desejada seja refletida nos modos de operação dos pinos.

Além disso, as macros GPIOPinHigh e GPIOPinLow são responsáveis por definir o estado lógico de um pino como alto (1) ou baixo (0), modificando os registradores de dados correspondentes. Essas operações são fundamentais para o controle de dispositivos conectados aos pinos GPIO, como LEDs, sensores ou outros dispositivos de entrada/saída.

O código também inclui macros para verificar e obter o estado atual de um pino, como GPIOPinState. Essas operações são úteis para a leitura do estado lógico de um pino após a sua configuração e manipulação.

Adicionalmente, a macro GPIOPinTurn permite a mudança do estado de um pino para alto ou baixo com base em um valor passado como parâmetro, fornecendo uma funcionalidade flexível para a aplicação
Em seguida, progredimos para a etapa subsequente, na qual desenvolvemos as macros essenciais para a exibição de caracteres na tela. Essas macros estão contidas no módulo "lcd.s", que desempenha o papel fundamental de controlar o display LCD e integrar as funcionalidades para garantir a apresentação adequada das interfaces.

### LCD

Em seguida, progredimos para a etapa subsequente, na qual desenvolvemos as macros essenciais para a exibição de caracteres na tela. Essas macros estão contidas no módulo "lcd.s", que desempenha o papel fundamental de controlar o display LCD de 16 colunas e 2 linhas ([componente 4, imagem XX](https://github.com/nailasuely/IHM_Problem2/blob/main/resources/1.png)) e integrar as funcionalidades para garantir a apresentação adequada das interfaces. 

<p align="center">
  <img width="600px" src="https://github.com/nailasuely/IHM_Problem2/blob/main/resources/1.png" />
</p>


O chip HD44780 controla funções como alimentação, dados e ajuste de contraste por meio de 14 pinos:
- Vss (GND): Terra.
- Vdd (Alimentação): Energiza o circuito.
- Vo (Contraste): Controla o contraste.
- RS (Seleção Registro): Escolhe instruções ou dados.
- R/W (Leitura/Escrita): Define a operação.
- E (Habilita): Liga ou desliga o LCD.
- DB0-DB7 (Barramento de Dados): Transmite informações.

A escolha entre instruções (RS=0) e dados (RS=1) ocorre via RS e com a configuração dos pinos, exemplificada com detalhes na imagem XX. 

<p align="center">
  <img width="500px" src="https://github.com/nailasuely/IHM_Problem2/assets/98486996/78349e83-61d0-4293-adbc-82fc2a3deb29" />
</p>

A comunicação segue etapas:

- **Inicialização:** Configuração inicial, aguardando a preparação do LCD. Ativação do display e desativação do cursor.

	Para realizar essa parte na execução do código, a macro “init” presente no módulo “lcd.s” inicia configurando o pino RS para indicar que serão enviadas instruções. Executando posteriormente uma 		sequência específica nos pinos D7, D6, D5 e D4, alternando entre níveis altos e baixos, utilizando as macros “GPIOPinLow" e “GPIOPinHigh" e gerando um pulso de Enable para permitir que o display leia 	as informações. Após sequência inicial, há um tempo de espera de 5 milissegundos (nanoSleep timeZero, time5ms) para garantir que o display esteja pronto para a próxima etapa. Ocorre a repetição dessa 	sequência com algumas variações, incluindo tempos de espera menores e finaliza as configurações dos pinos D7, D6, D5 e D4, gerando pulsos no pino Enable.
   
- **Envio de Dados/Comandos:** RS=1 para dados e RW=0 para escrita. Os caracteres são convertidos automaticamente. RS=0 para comandos.
- **Posicionamento do Cursor:** Comandos definem a posição do cursor na tela.
- **Exibição de Texto:** Envio de caracteres para a posição do cursor.
  
	Para essas últimas etapas enumeradas, outras macros são utilizadas. Um exemplo, é a “twoLine” que foi projetada para o LCD operar com duas linhas, destacando que a segunda linha está localizada 40 		bits além da base da primeira linha. A configuração se inicia com os pinos D7, D6, D5 e D4 que alternam entre níveis alto e baixo. Também ocorre a geração de pulso de Enable para ativar o processo de 	leitura e interpretação das configurações e consolida a configuração com outro pulso adicional nos pinos D7 e D6. 

	Outro exemplo, é a macro “writeCharLCD” que como seu próprio nome diz ela é capaz de escrever um caractere no display. Com esse propósito, primeiro é configurado o pino RS para indicar que será 		enviado um dado, que nesse caso é o caractere ao invés de uma instrução. Necessariamente uma série de instruções são utilizadas para configurar os pinos D7, D6, D5 E D4  tendo como base o valor do 		caractere fornecido (hex, parâmetro da macro). Logo, para cada um desses pinos o estado do bit correspondente ao valor do caractere é verificado e o pino é setado com base nele. Isso é feito chamando 	a macro GPIOPinTurn que por sua vez utiliza a macro GPIOInState para obter e configurar o estado do bit. Após todo esse processo, um pulso de enable é enviado para indicar que os dados estão prontos 		para serem lidos e depois ocorre uma limpeza dos pinos utilizados para evitar conflitos ou interferências que não são desejadas.


 
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

## Testes

Ao longo do desenvolvimento do protótipo e após sua conclusão, foram conduzidas séries de testes para avaliar o desempenho do sistema e garantir sua operação conforme as expectativas

Na fase inicial dos testes, para verificar o funcionamento do código da UART, conectamos o sistema a um osciloscópio com o intuito de visualizar sinais elétricos ao longo do tempo e confirmar se os dados estavam sendo enviados e recebidos de maneira adequada.

Ao analisarmos os resultados no osciloscópio, tornou-se evidente que os dados estavam sendo transmitidos e recebidos conforme o esperado. Os sinais apresentaram padrões consistentes (Imagem XX), indicando uma comunicação estável entre os dispositivos. Esse teste inicial foi crucial para demonstrar ao grupo que as informações enviadas pelos sensores e outros componentes estavam sendo corretamente recebidas e interpretadas pelo sistema. Essa validação inicial permitiu a continuidade das etapas subsequentes do código, as quais foram implementadas e testadas utilizando os componentes disponíveis na placa.

<p align="center">
  <img width="500px" src="https://github.com/nailasuely/IHM_Problem2/blob/main/resources/MAP001.png" />
</p>

<p align="center">
  <img width="500px" src="https://github.com/nailasuely/IHM_Problem2/blob/main/resources/MAP002.png" />
</p>

Logo depois foram realizados testes voltados para a verificação da navegação no MENU (Video 1), onde a interação com os botões era testada para assegurar que as transições entre as telas ocorressem conforme o esperado. 

Em outro teste realizado (Video 2), simulou-se a ausência de um sensor no sistema, no qual, mesmo não havendo um sensor fisicamente conectado, a interface foi projetada para detectar essa condição e exibir a mensagem "SENSOR AUSENTE". Este teste foi para garantir que o sistema era capaz de identificar corretamente a ausência de sensores, fornecendo uma resposta adequada ao usuário.
Em seguida, um segundo foi conduzido com um sensor conectado, no caso, o sensor 15 (DHT11). A situação do sensor foi verificada, e a interface exibiu a mensagem "Situação do Sensor: OK" para indicar que o sensor estava operando conforme o esperado.





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
