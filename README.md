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
- [Documentação utilizada](#documentação-utilizada)
- [Hardware utilizado](#hardware-utilizado)
- [Implementação](#implementação)
  - [GPIO](#gpio)
  - [LCD](#lcd)
  - [UART](#uart)
  - [Main](#main)
- [Executando o Projeto](#executando-o-projeto)
- [Testes](#testes)
- [Conclusão](#conclusão) 
- [Tutor](#tutor)
- [Equipe](#equipe)
- [Referências](#referências)

  
## Apresentação 

Este documento detalha o desenvolvimento de uma comunicação UART entre um microcontrolador ESP e um computador de placa única Orange Pi PC Plus, além de um sistemas de menus para uso pelo usuário, utilizando a linguagem assembly da arquitetura ARM V7. O projeto consiste em um sistema que tem como objetivo viabilizar a comunicação com sensores, especialmente o DHT11. Para visualização dos dados requisitados, um display LCD 16x2 é utilizado, proporcionando uma apresentação humanamente agradável  das informações.

Para estabelecer a comunicação com o sensor, empregou-se o projeto do monitor de Sistemas Digitais desenvolvido por Paulo Queiroz durante o semestre 2023.2 na UEFS. No [repositório correspondente](https://github.com/PauloQueirozC/EspCodigoPBL2_20232), estão disponíveis informações detalhadas sobre os comandos utilizados e suas respectivas respostas.

<p align="center">
  <img width="600px" src="https://github.com/nailasuely/IHM_Problem2/blob/main/resources/COMPUTADOR%20(4).png" />
</p>

## Documentação utilizada

- Datasheet da H3 AllWinner: Contém todas as informações relacionadas ao funcionamento dos pinos da SBC Orange Pi Pc Plus, bem como seus endereços de memória. Além disso, o documento conta também com informações sobre como acessar e enviar ou receber dados para os pinos de entrada e saída de propósito geral (GPIO). Também é utilizado no projeto para obter as informações de como realizar o modelo de comunicação Uart e seus respectivos pinos.

- Datasheet do display LCD: O modelo do display LCD é o Hitachi HD44780U, e sua documentação nos permite descobrir o algoritmo responsável pela inicialização do display bem como o tempo de execução de cada instrução, que precisa seguir uma sequência específica para inicialização correta, além da representação de cada caractere em forma de número binário.

- Raspberry Pi Assembly Language Programming, ARM Processor Coding: Livro que mostra diversos casos de exemplo na prática do uso da linguagem Assembly na programação de dispositivos de placa única, no livro foi usado a Raspberry Pi. No projeto foi utilizado a placa Orange Pi que tem diversas similaridades com as Raspberry.

## Hardware utilizado
O hardware empregado para a síntese e testes deste projeto é uma Orange PI PC Plus, equipada com 40 pinos GPIO e um processador H3 Quad-core Cortex-A7 H.265/HEVC 4K, baseado na arquitetura ARM V7. O sistema operacional em execução é o Raspbian com um kernel proprietário, versão 5.15.74-sunxi com as espeficificações detalhadas na tabela abaixo.

<div align="center">
	
| Categoria                                                                            | Especificações                                                                                                                                                               |
| :------------------------------------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CPU             | H3 Quad-core Cortex-A7 H.265/HEVC 4K                                                                                                                          |
| GPU             | Mali400MP2 GPU @600MHz
| Memória (SDRAM)             | 1GB DDR3 (shared with GPU)    |
| Rede embarcada             | 10/100 Ethernet RJ45     |
| Fonte de alimentação            | Entrada DC, entradas USB e OTG não servem como fonte de alimentação |
| Portas USB             | 3 Portas USB 2.0, uma porta OTG USB 2.0     |
| Periféricos de baixo nível            | 40 pinos    |

<p>
      Especificações - Orange PI PC Plus
    </p>
</div>


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

	Para imprimir texto na tela, conforme visualizado nas telas da imagem XX, é necessário operar com a macro "writeCharLCD". No entanto, como essa macro escreve apenas um caractere, é essencial implementar uma lógica para seu uso conforme desejado. Para isso, é preciso indicar dois registradores para apontar a parte da memória onde a variável com o texto está armazenada, um para cada registrador. Após essa etapa, pode-se utilizar a função "escreverLinhas", que segue uma lógica de salvar inicialmente o valor do registrador LR (que guarda o endereço da chamada da função) na pilha. Em seguida, executa a macro de limpeza do display, "Clear Display", e atribui valores a dois registradores: um para definir quantos caracteres serão escritos por linha e o segundo, inicializado como zero, atua como contador. Uma função auxiliar chamada "Escrita" implementa a lógica de escrever caractere a caractere. Esta função também salva o endereço da chamada dela e inicia o loop para escrever cada caractere a cada passagem no loop, incrementando o contador. Quando esse contador iguala ao valor atribuído a um registrador anteriormente, a função é encerrada, pois o papel de escrever naquela linha foi concluído. Após essa etapa, o cursor é movido para a segunda linha para repetir o procedimento de configuração de registradores. No entanto, o valor do segundo registrador, que teve sua informação carregada nele antes de iniciar a função, é movido para outro usado na função auxiliar. Após a conclusão do procedimento, ao retornar ao local da chamada, o valor do registrador LR é restaurado ao que foi salvo na pilha, permitindo executar a instrução de retorno à chamada da função "EscreverLinhas".

	É importante notar que em situações envolvendo a apresentação de valores numéricos, a lógica de exibição passa por algumas alterações. Para isso, primeiro realiza-se a separação dos dígitos do valor recebido, a fim de escrever cada dígito separadamente na tela por meio da macro "WriteCharLCD". Sem essa operação, seria apresentado um caractere correspondente da tabela ASCII, não o valor numérico desejado. Nessa operação, é necessário pegar o valor completo, dividi-lo por 10 para obter o primeiro dígito do número. Em seguida, multiplica-se esse número por 10 e subtrai-o do valor inicial para obter o segundo dígito. Antes de apresentar na tela, soma-se 48 para obter o código correspondente a esse dígito na tabela ASCII. Por exemplo, com o valor inicial 64, ao dividir por 10, obtemos 6, que é o primeiro dígito. Em seguida, multiplicamos 6 por 10, resultando em 60. Ao subtrair 64 por 60, obtemos 4, que é o segundo dígito. Após escrever os dois dígitos do valor recebido, a função "Escrita" é utilizada para escrever na primeira linha. Em seguida, é chamada a macro para mudar o cursor para a segunda linha, além de carregar em um registrador a variável, que está na memória, contendo o texto a ser exibido na segunda linha e a função "Escrita" realiza novamente a sua função.

### UART
Logo depois, após o entendimento do LCD e o desenvolvimento de algumas telas, o grupo percebeu a necessidade da implementação da UART para poder enviar e receber os dados referentes ao sensor que é a parte primordial do problema. 

Para a integração da UART no sistema, o primeiro passo foi realizar o mapeamento da memória, começando pelo mapeamento do Clock Control Unit (CCU). Esse procedimento é parecido ao mapeamento do GPIO discutido anteriormente, utilizando chamadas de sistema similares. O endereço base associado ao CCU foi carregado no registrador R5 e posteriormente mapeado, armazenando-se em outro registrador para configurações futuras do CCU.

A configuração do CCU teve como objetivo ajustar a saída do Phase-Locked Loop (PLL), selecionar a fonte de clock para APB2 (APB3_CLK_SRC_SEL) e, por fim, habilitar o clock para a UART3. Em seguida, foi necessário realizar o mapeamento específico da UART3, seguindo o mesmo processo discutido anteriormente, solicitando ao sistema acesso à memória e configurando a flag de compartilhamento de memória, com um deslocamento de 0xC00 para posicionar o endereço dentro da região da UART3.

Para concluir a configuração da UART, foram necessárias diversas funções, começando por "pinosUART", que tem como propósito configurar os pinos associados à UART3 conforme informações disponíveis no datasheet [1]. Em seguida, "setarTamanhoDados" estabelece o tamanho dos dados transmitidos pela UART3 como 8 bits por caractere, sendo fundamental para assegurar uma comunicação eficaz entre os dispositivos. Logo depois, "AtivarDLab" ativa o DLAB (Divisor Latch Access Bit), configurando o bit 7. 

Além disso, "SetarValorDLL" e "SetarValorDLH" possuem configurações específicas para limpar os bits correspondentes ao divisor, para essa configuração foi necessário fazer uma conta para ter o valor em bínario para serem postos os 8 bits menos significativos no DLL e os demais bits mais significativos no DLH .Em seguimento ocorre desativação do DLAB, configurando o bit 7 como zero para restaurar o funcionamento normal da UART3. Por fim, a ativação do FIFO ocorre com o carregamento do conteúdo do registrador de controle de fluxo FIFO (FCR), um buffer que melhora a transmissão e recepção de dados aprimorando o desempenho geral da comunicação serial.Também existe duas funções que fazem a comunicação em si de fluxo de bits. Primeiramente a  função EnviarDados escreve dados no registrador THR (UART Transmit Holding Register) para iniciar a transmissão, e posteriormente a função ReceberDados verifica o status do registrador LSR (UART Line Status Register) para determinar se há dados no registrador RBR (UART Receive Buffer Register) antes de ler.

### Main
O próximo estágio de desenvolvimento, visou tornar o sistema acessível a diversos usuários, então "main.s" foi introduzida para articular a interação entre os módulos falados anteriormente e integrar os recursos disponíveis, incluindo os três botões presentes na placa (Componente 1, 2 e 3, imagem XX). 

Ao inicializar o programa, é apresentado 2 telas que só aparecem nesse momento, como podem ser vistas nas imagem X e X, a primeira desejando boas-vindas, e a segunda que apresenta uma leve explicação sobre o que cada botão faz para poder então preparar o usuário para navegar entre os menus, que estão estruturados conforme na parte “MENU” da imagem XX. Sendo então o botão 1 para voltar à página anterior, o botão 2 para selecionar a opção, e o botão 3 para avançar a opção.

A operação lógica para que essas duas telas sejam apresentadas, ocorre inicialmente carregando em 2 registradores 2 variáveis, uma para cada registrador, que contém o texto da primeira linha, e o da segunda linha respectivamente. Com essa etapa feita é utilizado a função “escreverLinhas” para realizar a escrita do texto nas duas linhas do display, visando resultado ilustrado na imagem X, e para melhorar visualização é utilizada uma função “nanoSleep” para gerar uma pausa no sistema de 2 segundos, e assim só após esse tempo, repetir o processo de salvar outras variáveis nos registradores conforme já citado, e então executar o processo de escrita na tela, apresentando na tela informação conforme imagem X, e após utilizando a função “nanoSleep” novamente para poder interromper o sistema por 3 segundos, um tempo maior por conta da informação mais composta apresentada, e após esse tempo o fluxo do código é direcionado para a função que apresenta o menu inicial.

<p align="center">
	<img width="300px" src="https://github.com/nailasuely/IHM_Problem2/blob/main/resources/incio_telas.png" />
	</p>

Conforme visto a lógica de exibição de texto para formar uma tela, ela persiste na exibição dos outros menus. Para cada uma das telas de menu há uma função, em que primeiramente é executado o processo de formar a tela, e após entrar em um loop para aguardar algum dos botões mudar de estado, ou seja ser pressionado, para definir a próxima etapa a ser executada. Havendo entre as telas de menu 3 opções: selecionar a opção, avançar para a próxima tela de menu, ou retornar para a tela de menu anterior. Enquanto nenhum botão é pressionado, permanece na mesma função e a mesma exibição na tela.


- Fluxo Normal
	
	Posteriormente, para utilizar os recursos do fluxo normal, como a verificação da umidade e temperatura atuais no programa, é necessário selecionar a opção desejada no menu. Após escolher o sensor do qual se deseja obter o dado específico, o valor obtido do sensor é apresentado na tela, e em seguida, é possível retornar ao menu. Internamente, para garantir que esse processo ocorra de maneira fluida para o usuário, algumas etapas precisam ser realizadas.
	1. **Realizar verificação do sensor**
	
	Antes de enviar a requisição de temperatura ou umidade, o sistema verifica informações sobre o sensor selecionado. Com base no valor recebido, existem três situações possíveis. Na primeira, se o sensor estiver ausente, o fluxo direciona imediatamente para a função que informa na tela sobre a ausência do sensor. Na segunda situação, se o sensor estiver com algum problema, o sistema redireciona para o método que exibe na tela que o sensor enfrenta problemas. Por fim, na terceira situação, o fluxo continua normalmente para completar a requisição do usuário.

	2. **Enviar a requisição desejada**
	
	Nesta etapa é enviado o comando requisitando temperatura ou umidade, obedecendo o protocolo de comunicação, e além dele o endereço do sensor também é enviado
	
	3. **Receber a resposta com o valor lido pelo sensor**
	4. **Apresentar na tela o valor**, junto com a discriminação de qual tipo ele é. Já estando nessa tela é possível apertar o botão 3 e sair de volta para o menu.

- Situação do Sensor
  
	O funcionamento para o usuário referente a requisitar a situação do sensor ocorre com uso dos botões e display LCD para navegar entre os menus até encontrar esta opção, após deve selecionar o sensor que deseja obter a situação, e por fim a informação sobre ele aparece na tela, conforme vídeo LINK mostra. Contudo, para que isso possa ocorrer, outras etapas internas são necessárias. Dentre elas:
	1. Salvar o valor do sensor escolhido em um dos registradores
	2. Realizar 2 envios de 1 byte pela UART, o primeiro contendo o código da requisição, e o segundo contendo o endereço do sensor
	3. Receber os dados via UART, e analisar qual foi o código retornado, para poder ir para função* de exibição do texto da situação na tela adequada

- Fluxo contínuo
  
	Para que o sensoriamento contínuo, tanto de umidade como de temperatura funcione, torna-se necessário, como para as outras opções oferecidas e relacionadas ao sensor DHT11, selecionar esta opção no menu, e após escolher o sensor e logo é apresentado o primeiro valor, seja de umidade ou de temperatura conforme foi escolhido previamente, com a apresentação do primeiro valor, uma segunda tela é apresentada pedindo para aguardar enquanto um novo dado vai ser recebido, esse tempo de aguardo é de cerca de 3 segundos, e já há o retorno para apresentar novamente o novo dado recebido. Vale lembrar que o dado fica apresentado na tela por aproximadamente 2 segundos antes de ir para a tela de atualização. Caso deseje sair do sensoriamento contínuo é preciso pressionar o botão 3 até mudar de tela, tempo necessário para impedir a desativação por engano. Conforme a ESP utilizada para comunicação UART, só estava mapeada para 1 sensor, o 15, foi comentado no código a tela de escolha do sensor para desativar o modo contínuo, sendo assim, é selecionado automaticamente o sensor 15, e após apresenta a tela confirmando que o contínuo foi desativado.

- Sair do programa
  Conforme vontade do usuário do sistema, pode ser possível encerrar o programa pelo menu do sistema. Para isso, basta navegar até este menu, e realizar a seleção usando o botão 2, e assim uma mensagem de despedida é apresentada na tela, e o programa é encerrado
	
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

https://github.com/nailasuely/IHM_Problem2/assets/98486996/a10ccb69-e79f-4363-9703-53e6418fb591

Em outro teste realizado (Video 2), simulou-se a ausência de um sensor no sistema, no qual, mesmo não havendo um sensor fisicamente conectado, a interface foi projetada para detectar essa condição e exibir a mensagem "SENSOR AUSENTE". Este teste foi para garantir que o sistema era capaz de identificar corretamente a ausência de sensores, fornecendo uma resposta adequada ao usuário.
Em seguida, um segundo foi conduzido com um sensor conectado, no caso, o sensor 15 (DHT11). A situação do sensor foi verificada, e a interface exibiu a mensagem "Situação do Sensor: OK" para indicar que o sensor estava operando corretamente.

https://github.com/nailasuely/IHM_Problem2/assets/98486996/416475fb-da7c-4d49-b050-cae51b178c3a

Também foi feito o teste para simular o uso de um sensor no sistema, no qual, este mesmo sensor estava com mal funcionamento, a interface foi projetada para detectar essa condição e exibir a mensagem "SENSOR C. PROB". Este teste foi para garantir que o sistema era capaz de identificar corretamente caso fosse utilizado um sensor que não estivesse funcionando em suas capacidades habituais, fornecendo uma resposta adequada ao usuário. Nessa etapa, o grupo testou com um sensor queimado e removendo o sensor 15 e ambos os resultados seguiram o roteiro esperado.

Agora, ao avançarmos para as solicitações de medidas, inicialmente, requisitamos a medição da umidade ao sensor 15, obtendo uma resposta de 39% no local onde a medição do vídeo foi realizada. 

https://github.com/nailasuely/IHM_Problem2/assets/98486996/bf928c27-3616-447f-a04d-6555728b83ee

Além disso, em outro teste subsequente (Video 5), solicitamos a medição da temperatura ao mesmo sensor (DHT11), recebendo como resposta 23 graus Celsius no ambiente.

https://github.com/nailasuely/IHM_Problem2/assets/98486996/f4345cff-d9c6-43dc-9ed9-f2ff2643c4de

Em seguida, para avaliar o funcionamento do fluxo contínuo, realizamos o teste da requisição ao sensor 15 (DHT11) para medição contínua de umidade (GIF 6). Essa operação envolve a comunicação entre a placa Orange Pi e o sensor, garantindo a atualização constante dos valores de umidade por tempo indeterminado, até que essa funcionalidade seja desativada.


https://github.com/nailasuely/IHM_Problem2/assets/98486996/bdbe814b-a7bd-4cf8-95ba-8e80fca12c0a


O mesmo procedimento é aplicado para requisitar medição contínua de temperatura.


https://github.com/nailasuely/IHM_Problem2/assets/98486996/d661181e-ef60-474e-b6b0-0e84ff28518d

## Conclusão
Por fim, o projeto foi concluído com êxito, visto que todos os testes obteve um resultado satisfatório. O objetivo do projeto era substituir a interface em C do projeto anterior para uma interface mais agradável, incorporando botões e uma tela LCD, permitindo assim uma interação mais direta. No entanto, a eficiência do código pode ser melhorada, uma vez que a UART é reconfigurada a cada vez que os dados são atualizados no modo monitoramento contínuo. Isso impacta na velocidade de atualização das informações.

O vídeo a seguir apresenta a interação com todas as funções do projeto, mostrando todo o funcionamento e todos seus usos. Além disso, também é um tutorial prático de como manipular o programa.


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
