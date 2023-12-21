.include "sleep.s"
.include "gpio.s"
.include "lcd.s"
.include "uart_teste.s"

.global _start
_start:
	@ realização do mapeamento de memoria referente ao GPIO
	MemoryMap
	
	@ Configuração e mapeamento de memoria referente a UART
	@ Alem de configurar, é resetado o FIFO
	@ Durante a execução do codigo chamadas a essa função ocorrem diversas vezes

    bl ConfigurarUart
	@ setando os pinos que serão utilizados para o controle do LCD
	setLCDPinsOut
	@ configuração dos pinos dos botoes
	GPIOPinIn b1
	GPIOPinIn b2
	GPIOPinIn PA7
	.ltorg
	@ inicialização do display LCD
	init
	.ltorg
	twoLine 
	@ liga a segunda linha do display
	.ltorg


	@ Pagina que serve para apresentar um breve tutorial de uso da placa
	@ com relação ao uso dos botoes, alem de uma tela de boas vindas
	
	@ Nela as variaveis que contem o texto sao carregadas em R12 e em R6
	@ para poderem ser escritas nas 2 linhas usando a função "escreverLinhas"
	@ esse processo ocorre novamente depois de 2 segundos, tempo colocado
	@ para permitir a visualização e leitura do texto de boas vindas na tela
	@ Finalizado os processos que deve realizar, ele irá para a pagina Menu principal
	
    inicio:
		@carrega em r12 e em r6 as variaveis que contem o texto para apresentar na tela
		ldr r12, =p_seja
		ldr r6, =p_bemvindo
		@chama a função que realiza o processo de escrever nas duas linhas do display
		bl escreverLinhas
		@da um tempo antes de trocar de tela, para melhor visualização do texto
		nanoSleep time1s timeZero
		nanoSleep time1s timeZero
		ldr r12, =p_menu2
		ldr r6, =p_botoes
		bl escreverLinhas
		@da um tempo antes de trocar de tela, para melhor visualização do texto
		nanoSleep time1s timeZero
		nanoSleep time1s timeZero
		nanoSleep time1s timeZero
		b paginaMenu

/*=========================================================================================
===========================================================================================
====         A SEQUENCIA DE FUNÇÕES DE PAGINA ABAIXO SERVE COMO PARTE DO MENU.         ====
==== ELAS PERMITEM IR PARA A PROXIMA PAGINA, OU PARA A ANTERIOR, OU SELECIONAR A OPÇÃO ====
===========================================================================================
===========================================================================================
*/

/*
Pagina principal do menu, a primeira pagina vista, e que permite ir para as outras paginas
Ocorre nela o procedimento de escrita na tela, usando a logica descrita no comentario da "função" "inicio"
	logica usada para diversos momentos de escrita
 */

paginaMenu:
	ldr r12, =p_menuInicial
	ldr r6, =p_segundaLinhaMenu
	bl escreverLinhas
	@ permanece no loop ate que seja apertado algum botao, para ir para proxima pagina, ou para a ultima pagina do menu
	waitToGo2:
		GPIOPinState PA7
		CMP R1, #0 @ botão apertado
		beq pagina6

		GPIOPinState b2
		CMP R1, #0 @ botão apertado
		beq pagina1
		b waitToGo2
	b paginaMenu

/*
Função que permite escolher qual sensor vai ser escolhido, para isso
depende dos botoes para incrementar ou decrementar o valor
*/ 

choiceSensor:
    @procedimento para guardar na pilha o valor de onde foi realizada a chamada para vir ate essa função
	sub sp, sp, #4
    str lr, [sp]
    mov r6, #0
	@realiza a escrita dos textos na tela
	escolherSensor:
		bl LimpeDisplay
		mov r5, #10
		sdiv r3, r6, r5	
		add r3, r3, #48
		WriteCharLCD r3
		mov r5, #10
		sdiv r3, r6, r5
		mul r4, r3, r5
		sub r2, r6, r4
		add r2, r2, #48
		WriteCharLCD r2
		ldr r12, =p_sensor
		mov r10, #0
		bl escrita
		bl segundaLinha
		ldr r12, =p_confirma2
		mov r10, #0
		bl escrita
		mov r6, r6
		@fica em loop esperando para saber qual botao foi apertado e ir para determinada função
		waitToGo1:
			nanoSleep timeZero time500ms
			GPIOPinState PA7
			CMP R1, #0 @ botão apertado
			beq podeSubtrairValor @vai ir para subtrair o valor do sensor escrito na tela

			GPIOPinState b1
			CMP R1, #0 @ botão apertado
			beq sairDaqui

			GPIOPinState b2
			CMP R1, #0 @ botão apertado
			beq somaValor @vai ir somar o valor do sensor escrito na tela

			b waitToGo1
		b escolherSensor

	/*
	realiza o incremento do valor em 1, e verifica se ja chegou ate os 32
	caso tenha chegado ele vai ir para zerar o valor dos sensores
	*/
	somaValor:
		add r6, r6, #1
		cmp r6, #32
		beq zerarContador
		b escolherSensor
	@verifica se o valor pode ser subtraido, para evitar chegar ao sensor "-1", valores negativos
	podeSubtrairValor:
		cmp r6, #0
		beq jogaPraCima
		bgt subtraiValor

	/*
	joga o valor do sensor para 31, caso tente subtrair e esteja o valor zero na tela
	dai é permite fazer o loop voltando dos 31 e subtraindo
	*/
	jogaPraCima:
		mov r6, #31
		b escolherSensor
	@realizar a operação de decrementar o valo
	subtraiValor:
		sub r6, r6, #1
		b escolherSensor
	@serve para retornar o valor a 0
	zerarContador:
		mov r6, #0
		b escolherSensor
	@para voltar a onde foi feita a chamada da função geral
	sairDaqui:
		ldr lr, [sp]
		add sp, sp, #4
		bx lr

/*
-Esta função realiza a escrita de um numero de 00 a 99 na tela
-dentro dela a uma operação para converter o numero binario em decimal
e deste para o seu correspondente na tabela ASCII
*/
escreveNumero:

	mov r5, #10
	sdiv r3, r6, r5	
	add r3, r3, #48
	@escrita do primeiro digito na tela
	WriteCharLCD r3
	
	mov r5, #10
	sdiv r3, r6, r5
	mul r4, r3, r5
	sub r2, r6, r4
	add r2, r2, #48
	@escrita do primeiro digito na tela
	WriteCharLCD r2
	
	bx lr

pagina1: @PAGINA REREFERENTE A UMIDADE ATUAL
    ldr r12, = p_umidadeAtual
    ldr r6, =p_menu2
    bl escreverLinhas
	@LOOP DE ESPERA DO BOTAO PARA SABER O QUE REALIZAR
    ondeIr1:
		GPIOPinState PA7 @BOTAO MAIS A ESQUERDA
        CMP R1, #0 @ botão apertado
        beq paginaMenu

		GPIOPinState b1 @BOTAO MAIS A DIREITA
        CMP R1, #0 @ botão apertado
        beq escreverValorUartUmidade@ir pedir umidade via uart
		
		GPIOPinState b2 @BOTAO MAIS A ESQUERDA
        CMP R1, #0 @ botão apertado
        beq pagina2 @vai para a pagina subsequente
        
        b ondeIr1

pagina2:  @PAGINA REFERENTE AO MENU TEMPERATURA ATUAL
	ldr r12, =p_tempAtual
	ldr r6, =p_menu2
	bl escreverLinhas
	@LOOP DE ESPERA DO BOTAO PARA SABER O QUE REALIZAR
	ondeIr2:
		GPIOPinState PA7 @BOTAO MAIS A DIREITA
		CMP R1, #0   @ botão apertado 
		beq pagina1  @ volta para a pagina anterior

		GPIOPinState b1 @BOTAO MAIS A ESQUERDA
		CMP R1, #0 @ botão apertado
		beq escreverValorUartTemperatura @IR PARA PROXIMA PAGINA

		GPIOPinState b2 @BOTAO MAIS A DIREITA
		CMP R1, #0 @ botão apertado 
		beq pagina3 @IR PARA AMOSTRAGEM DOS DADOS
		
		b ondeIr2

pagina3: @PAGINA REFERENTE AO MENU SITUAÇÃO DO SENSOR
	ldr r12, =p_situacao
	ldr r6, =p_menu2
	bl escreverLinhas
	@LOOP DE ESPERA DO BOTAO PARA SABER O QUE REALIZAR
	ondeIr3:
		GPIOPinState PA7 @BOTAO MAIS A DIREITA
		CMP R1, #0 @ botão apertado 
		beq pagina2 @IR PARA AMOSTRAGEM DOS DADOS
		
		GPIOPinState b1 @BOTAO MAIS A ESQUERDA
		CMP R1, #0 @ botão apertado
		beq pegarSituacao @IR PARA PROXIMA PAGINA

		GPIOPinState b2 @BOTAO MAIS A DIREITA
		CMP R1, #0 @ botão apertado 
		beq pagina4 @IR PARA AMOSTRAGEM DOS DADOS
		
		b ondeIr3

pagina4: @PAGINA REFERENTE AO MENU UMIDADE CONTINUA
	ldr r12, =p_umidCont
	ldr r6, =p_menu2
	bl escreverLinhas
	@LOOP DE ESPERA DO BOTAO PARA SABER O QUE REALIZAR
	ondeIr9:
		GPIOPinState PA7 @BOTAO MAIS A DIREITA
		CMP R1, #0 @ botão apertado 
		beq pagina3 @IR PARA AMOSTRAGEM DOS DADOS
		
		GPIOPinState b1 @BOTAO MAIS A ESQUERDA
		CMP R1, #0 @ botão apertado
		beq ativarContinuoUmidade @IR PARA PROXIMA PAGINA

		GPIOPinState b2 @BOTAO MAIS A DIREITA
		CMP R1, #0 @ botão apertado 
		beq pagina5 @IR PARA AMOSTRAGEM DOS DADOS
		.ltorg
		b ondeIr9
	b pagina5

pagina5:
	ldr r12, =p_tempCont
	ldr r6, =p_menu2
	bl escreverLinhas
	ondeIr10:
		GPIOPinState PA7 @BOTAO MAIS A DIREITA
		CMP R1, #0 @ botão apertado 
		beq	pagina4 @IR PARA AMOSTRAGEM DOS DADOS
		
		GPIOPinState b1 @BOTAO MAIS A ESQUERDA
		CMP R1, #0 @ botão apertado
		beq ativarContinuo @IR PARA PROXIMA PAGINA

		GPIOPinState b2 @BOTAO MAIS A DIREITA
		CMP R1, #0 @ botão apertado 
		beq	pagina6 @IR PARA AMOSTRAGEM DOS DADOS
		
		b ondeIr10

pagina6: @PAGINA REFERENTE AO MENU SAIR DO PROGRAMA
	ldr r12, =p_desligar
	ldr r6, =p_menu2
	bl escreverLinhas
	ondeIr15:
		GPIOPinState PA7 @BOTAO MAIS A DIREITA
		CMP R1, #0 @ botão apertado 
		beq	pagina5 @IR PARA AMOSTRAGEM DOS DADOS
		
		GPIOPinState b1 @BOTAO MAIS A ESQUERDA
		CMP R1, #0 @ botão apertado
		beq sair1 @IR PARA PROXIMA PAGINA

		GPIOPinState b2 @BOTAO MAIS A DIREITA
		CMP R1, #0 @ botão apertado 
		beq	paginaMenu @IR PARA AMOSTRAGEM DOS DADOS
		
		b ondeIr15

@ ========================================
@  FINAL DA SEQUENCIA DE PAGINAS DE MENU
@ ========================================

@ =========================================
@ Realiza o processo de:
@	-escolha do sensor
@	-verificar primeiro se o sensor esta presente, ou com problema, ou ausente
@	-com o sensor OK ele envia a requisição e o endereço
@	-recebe o valor recebido pela uart
@	-escreve os 2 digitos na tela do valor recebido
@	-vai para a função de escrever o restante dos textos na tela
@ ==========================================

escreverValorUartUmidade:
	bl choiceSensor
	@verificar se o sensor ta ok
	bl ConfigurarUart
	mov r0, #0x00
	bl EnviarDados
	mov r0, r6
	bl EnviarDados
	//nanoSleep time1s time1ms
	bl ReceberDados
	cmp r0, #0x1F
	beq pagSensorProblema
	cmp r0, #0x2F
	beq pagSensorInexistente
	
	
	bl LimpeDisplay
	bl ConfigurarUart
	mov r0, #0x02
	bl EnviarDados
	mov r0, r6
	bl EnviarDados
	//nanoSleep time1s time1ms
	bl ReceberDados
	mov r6, r0
	mov r5, #10
	sdiv r3, r6, r5	
	add r3, r3, #48
	WriteCharLCD r3
	mov r5, #10
	sdiv r3, r6, r5
	mul r4, r3, r5
	sub r2, r6, r4
	add r2, r2, #48
	WriteCharLCD r2
	b mostrarUmidade
	 


@ ==========================================
@ Realiza o processo de:
@	-escolha do sensor
@	-verificar primeiro se o sensor esta presente, ou com problema, ou ausente
@	-com o sensor OK ele envia a requisição e o endereço
@	-recebe o valor recebido pela uart
@	-escreve os 2 digitos na tela do valor recebido
@	-vai para a função de escrever o restante dos textos na tela
@
@ ==========================================

escreverValorUartTemperatura:

	bl choiceSensor
	
	@verificar se o sensor ta ok
	bl ConfigurarUart
	mov r0, #0x00
	bl EnviarDados
	mov r0, r6
	bl EnviarDados
	//nanoSleep time1s time1ms
	bl ReceberDados
	cmp r0, #0x1F
	beq pagSensorProblema
	cmp r0, #0x2F
	beq pagSensorInexistente


	bl LimpeDisplay
	bl ConfigurarUart
	mov r0, #0x01
	bl EnviarDados
	mov r0, r6
	bl EnviarDados
	//nanoSleep time1s time1ms
	bl ReceberDados
	
	mov r6, r0
	mov r5, #10
	sdiv r3, r6, r5	
	add r3, r3, #48
	WriteCharLCD r3
	mov r5, #10
	sdiv r3, r6, r5
	mul r4, r3, r5
	sub r2, r6, r4
	add r2, r2, #48
	WriteCharLCD r2
	b mostrarTemperatura

/*
realiza a escrita do texto complementar ao resultado na tela, e fica aguardando
pelo pressionar do botao para poder sair da função
*/ 
mostrarTemperatura:
	mov r10, #0
	ldr r12, =p_TemperaturaResultado
	bl escrita
	bl segundaLinha
	mov r10, #0
	ldr r12, =p_sair
	bl escrita
	
	ondeIr5:
		GPIOPinState b2 @BOTAO MAIS A DIREITA
		CMP R1, #0 @ botão apertado
		beq pagina2 @ir pedir umidade via uart

		b ondeIr5
	b sair

/*
realiza a escrita do texto complementar ao resultado na tela, e fica aguardando
pelo pressionar do botao para poder sair da função
*/
mostrarUmidade:
	mov r10, #0
	ldr r12, =p_UmidadeResultado
	bl escrita
	bl segundaLinha
	mov r10, #0
	ldr r12, =p_sair
	bl escrita
	ondeIr7:
		GPIOPinState b2 @BOTAO MAIS A DIREITA
		CMP R1, #0 @ botão apertado
		beq pagina1 @ir pedir umidade via uart
		b ondeIr7
	b sair

/*
envia a requisição pedindo a situação em que o sensor escolhido se encontra
a depender do valor ele vai para determinada função realizar a amostragem do resultado,
seja ele SENSOR OK, SENSOR COM PROBLEMA, SENSOR INEXISTENTE
*/ 
pegarSituacao:
	bl choiceSensor
	bl LimpeDisplay
	bl ConfigurarUart
	
	mov r0, #0x00
	bl EnviarDados
	mov r0, r6
	bl EnviarDados
	//nanoSleep time1s time1ms
	bl ReceberDados
	cmp r0, #0x1F
	beq pagSensorProblema
	cmp r0, #0x2F
	beq pagSensorInexistente
	cmp r0, #0x07
	beq pagSensorOk
	nanoSleep time1s time950ms
	b pagina1

/*
mostra na tela que o sensor esta funcionando, e espera pelo
comando do usuario, apertando o botao, para poder sair da tela
*/ 
pagSensorOk:
	ldr r12, =p_SensorOk
	ldr r6, =p_sair
	bl escreverLinhas
	ondeIr4:
		GPIOPinState b2 @BOTAO MAIS A ESQUERDA
		CMP R1, #0 @ botão apertado
		beq pagina3 @IR PARA PROXIMA PAGINA
		b ondeIr4
	b pagSensorOk

/*
mostra na tela que o sensor esta ausente, e espera pelo
comando do usuario, apertando o botao, para poder sair da tela
*/
pagSensorInexistente:
	ldr r12, =p_SensorInex
	ldr r6, =p_sair
	bl escreverLinhas
	ondeIr11:
		GPIOPinState b2 @BOTAO MAIS A ESQUERDA
		CMP R1, #0 @ botão apertado
		beq paginaMenu @IR PARA PROXIMA PAGINA
		b ondeIr11
	b pagSensorOk

/*
mostra na tela que o sensor esta com problema, e espera pelo
comando do usuario, apertando o botao, para poder sair da tela
*/ 
pagSensorProblema:
	ldr r12, =p_SensorProb
	ldr r6, =p_sair
	bl escreverLinhas
	ondeIr12:
		GPIOPinState b2 @BOTAO MAIS A ESQUERDA
		CMP R1, #0 @ botão apertado
		beq paginaMenu @IR PARA PROXIMA PAGINA
		b ondeIr12
	b pagSensorOk

/*
realiza a escolha do sensor, e depois envia a requisição para poder 
ativar o sensoriamento continuo de temperatura
*/ 
ativarContinuo:
	bl choiceSensor

	@verificar se o sensor ta ok
	bl ConfigurarUart
	mov r0, #0x00
	bl EnviarDados
	mov r0, r6
	bl EnviarDados
	//nanoSleep time1s time1ms
	bl ReceberDados
	cmp r0, #0x1F
	beq pagSensorProblema
	cmp r0, #0x2F
	beq pagSensorInexistente


	bl ConfigurarUart
	
	mov r0, #0x03
	bl EnviarDados
	
	mov r0, r6
	bl EnviarDados
	b receberContinuo
	.ltorg

/*
Realiza o processo de ta recebendo o valor via via UART
Escreve tambem o valor numerico recebido na tela
*/ 
receberContinuo:
	.ltorg
	bl LimpeDisplay
	bl ConfigurarUart
	
	
	bl ReceberDados
	@bl ReceberDados
	cmp r0, #0x1F
	beq desativarContTempSensorProb


	mov r6, r0
	mov r5, #10
	sdiv r3, r6, r5	
	add r3, r3, #48
	WriteCharLCD r3
	mov r5, #10
	sdiv r3, r6, r5
	mul r4, r3, r5
	sub r2, r6, r4
	add r2, r2, #48
	WriteCharLCD r2
	
	b mostrarTemperaturaContinuo

desativarContTempSensorProb:
	bl ConfigurarUart
	mov r0, #0x05
	bl EnviarDados
	mov r0,  #0x0F
	bl EnviarDados
	b pagSensorProblema

/*
Realiza o processo de escrever na tela o texto complementar
além de permitir que ele saia do sensoriamento continuo, ao 
pressionar o botao e segurar
*/
mostrarTemperaturaContinuo:
	mov r10, #0
	ldr r12, =p_TemperaturaResultado
	bl escrita
	bl segundaLinha
	mov r10, #0
	ldr r12, =p_sair
	bl escrita
	
	ondeIr8:
		nanoSleep time1s time950ms
		GPIOPinState b2 @BOTAO MAIS A DIREITA
		CMP R1, #0 @ botão apertado
		beq pagDesativarContinuoTemperatura @ir pedir umidade via uart
		b pagAtualizandoTemp
	b sair


/*
realiza a desativação do sensoriamento continuo de temperatura
VALE RESSALTAR:
	-para melhor funcionamento tem de ativar a escolha dos sensor que deseja desligar
	-isso esta presente na função de "pagDesativarContinuoUmidade"
*/

desativaContinuoTemp:
	bl ConfigurarUart
	mov r0, #0x05
	bl EnviarDados
	mov r0,  #0x0F
	bl EnviarDados
	ldr r12, =p_desativado
	ldr r6, =p_voltandoAoMenu
	bl escreverLinhas
	nanoSleep time1s timeZero
	b paginaMenu

/*
realiza o processo apresentar uma tela de espera para poder
dar o tempo de receber o novo dado via UART, ja que o envio dos dados
ocorre de maneira espaçada no sensoriamento continuo
*/ 
pagAtualizandoTemp:
	@coloca os valores de texto para serem escritos na primeira e segunda linha	
	ldr r12, =p_aguarde
	ldr r6, =p_vazio
	bl escreverLinhas @chama a função de escrever as 2 linhas do display

	@esperar o tempo para receber novo valor e entao poder voltar a pagina que apresenta o resultado
	esperarTempo2:
		nanoSleep time1s timeZero
		nanoSleep time1s time950ms
		b receberContinuo

/*
realiza a escolha do sensor, e verificação a respeito dele
e depois envia a requisição para poder 
ativar o sensoriamento continuo de umidade
*/ 
ativarContinuoUmidade:
	bl choiceSensor

	@verificar se o sensor ta ok
	bl ConfigurarUart
	mov r0, #0x00
	bl EnviarDados
	mov r0, r6
	bl EnviarDados
	//nanoSleep time1s time1ms
	bl ReceberDados
	cmp r0, #0x1F
	beq pagSensorProblema
	cmp r0, #0x2F
	beq pagSensorInexistente

	bl ConfigurarUart
	mov r0, #0x04
	bl EnviarDados
	mov r0, r6
	bl EnviarDados
	b receberContinuoUmidade
	.ltorg

/*
Realiza o processo de ta recebendo o valor via via UART
Escreve tambem o valor numerico recebido na tela
*/ 
receberContinuoUmidade:
	.ltorg
	bl LimpeDisplay
	bl ConfigurarUart
	
	bl ReceberDados
	@bl ReceberDados

	cmp r0, #0x1F
	beq desativarContUmidSensorProb

	mov r6, r0
	mov r5, #10
	sdiv r3, r6, r5	
	add r3, r3, #48
	WriteCharLCD r3
	mov r5, #10
	sdiv r3, r6, r5
	mul r4, r3, r5
	sub r2, r6, r4
	add r2, r2, #48
	WriteCharLCD r2
	b mostrarUmidadeContinua

desativarContUmidSensorProb:
	bl ConfigurarUart
	mov r0, #0x05
	bl EnviarDados
	mov r0,  #0x0F
	bl EnviarDados
	b pagSensorProblema



/*
Realiza o processo de escrever na tela o texto complementar
além de permitir que ele saia do sensoriamento continuo, ao 
pressionar o botao e segurar
*/ 

mostrarUmidadeContinua:
	mov r10, #0
	ldr r12, =p_UmidadeResultado
	bl escrita
	bl segundaLinha
	mov r10, #0
	ldr r12, =p_sair
	bl escrita
	ondeIr80:
		nanoSleep time1s time950ms
		GPIOPinState b2 @BOTAO MAIS A DIREITA
		CMP R1, #0 @ botão apertado
		beq pagDesativarContinuoUmidade @ir pedir umidade via uart
		b pagAtualizandoUmid
	b sair

/*
realiza o processo apresentar uma tela de espera para poder
dar o tempo de receber o novo dado via UART, ja que o envio dos dados
ocorre de maneira espaçada no sensoriamento continuo
*/
pagAtualizandoUmid:
	@coloca os valores de texto para serem escritos na primeira e segunda linha	
	ldr r12, =p_aguarde
	ldr r6, =p_vazio
	bl escreverLinhas @chama a função de escrever as 2 linhas do display

	@esperar o tempo para receber novo valor e entao poder voltar a pagina que apresenta o resultado
	esperarTempo3:
		nanoSleep time1s timeZero
		nanoSleep time1s time950ms
		b receberContinuoUmidade

/*
realiza a desativação do sensoriamento continuo de temperatura
VALE RESSALTAR:
	-para melhor funcionamento tem de ativar a escolha dos sensor que deseja desligar
	-isso esta presente na função de "pagDesativarContinuoUmidade"
*/

desativaContinuoUmid:
	bl ConfigurarUart
	mov r0, #0x06
	bl EnviarDados
	mov r0, #0x0F
	bl EnviarDados
	ldr r12, =p_desativado
	ldr r6, =p_voltandoAoMenu
	bl escreverLinhas
	nanoSleep time1s timeZero
	b paginaMenu


pagDesativarContinuoUmidade:
	/*
	bl choiceSensor 

	@verificar se o sensor ta ok
	bl ConfigurarUart
	mov r0, #0x00
	bl EnviarDados
	mov r0, r6
	bl EnviarDados
	//nanoSleep time1s time1ms
	bl ReceberDados
	cmp r0, #0x1F
	beq pagSensorProblema
	cmp r0, #0x2F
	beq pagSensorInexistente
 	*/
	b desativaContinuoUmid

pagDesativarContinuoTemperatura:
	/*
	bl choiceSensor 

		@verificar se o sensor ta ok
	bl ConfigurarUart
	mov r0, #0x00
	bl EnviarDados
	mov r0, r6
	bl EnviarDados
	//nanoSleep time1s time1ms
	bl ReceberDados
	cmp r0, #0x1F
	beq pagSensorProblema
	cmp r0, #0x2F
	beq pagSensorInexistente
	 */
	b desativaContinuoTemp

escrita:
    sub sp, sp, #4
    str lr, [sp]
    

    ldr r1, [r12, r10]
    WriteCharLCD r1
    
    add r10, r10, #1
    cmp r10, #16

    ldr lr, [sp]
    add sp, sp, #4

    blt escrita
    bx lr

escreverLinhas:
    sub sp, sp, #4
    str lr, [sp]
    clearDisplay
    mov r11, #17
    mov r10, #0

    bl escrita
    secondLine
    mov r12, r6
    mov r11, #17
    mov r10, #0
    bl escrita

    ldr lr, [sp]
    add sp, sp, #4

    bx lr

sair:
    mov r0, #0
    mov r7, #1
    svc 0

sair1:
	ldr r12, =p_tchau
	ldr r6, =p_volteSempre
	bl escreverLinhas
	
	mov r0, #0
    mov r7, #1
    svc 0


.data
    base_uart: .word 0x01C28
    registerCCU: .word 0x01C20
    devMem: .asciz "/dev/mem"
    pagelen: .word  0x1000
    gpioaddr: .word 0x1C20
    time1s: .word 1
    time1ms: .word 1000000
	time850ms: .word 850000000 @850ms
    time950ms: .word 950000000 @850ms
	time500ms: .word 500000000 @ 170ms
	time170ms: .word 170000000 @ 170ms
	timeZero: .word 0 @ zero
	time1d55ms: .word 1500000 @ 1.5ms
	time5ms: .word 5000000 @ 5 ms
	time150us: .word 150000 @ 150us
	p_bemvindo: .ascii "--BEM-VINDO(A)--" 
    p_menu: .ascii "MENU COMANDOS >>" 
	p_situacao: .ascii "SITUACAO SENSOR "
	p_confirma: .ascii "  CONFIRMA: B3  "
	p_umidadeAtual: .ascii "   UMID ATUAL   "
	p_tempAtual: .ascii "   TEMP ATUAL   "
	p_tempCont: .ascii " MON CONT TEMP  "
	p_umidCont: .ascii " MON CONT UMID  "
	p_exitUmid: .ascii " SAIR CONT UMID "
	p_exitTemp: .ascii " SAIR CONT TEMP " 
	p_showTemp: .ascii "   TEMP: 23 C   "
	p_escolher: .ascii "    SAIR: B2    "
	p_TemperaturaResultado: .ascii "C -> TEMPERATURA"
	p_UmidadeResultado: .ascii "% --> UMIDADE   "
	p_SituacaoSensor: .ascii "  SENSOR 01:    "
	p_sair: .ascii "    SAIR:B3     "
	p_sairVoltar: .ascii "SAIR:B3 VOLTA:B1"
	p_criando: .ascii "LOADING THE PAGE"
	p_aguarde: .ascii "  AGUARDE ATT   "
	P_historicoUmidade: .ascii " HISTORICO: 59% "
	P_historicoTemperatura: .ascii " HISTORICO: 25C "
	p_SensorOk: .ascii "   SENSOR: OK   "
	p_SensorProb: .ascii " SENSOR C. PROB "
	p_SensorInex: .ascii " SENSOR AUSENTE "
	p_sensor: .ascii " --> SENSOR   "
	p_desligar: .ascii "SAIR DO PROGRAMA"
	p_vazio: .ascii "                "
	p_menu2: .ascii "<< SELECIONAR >>" 
	p_menuInicial: .ascii "--MENU INICIAL--"
	p_botoes: .ascii "B1     B2     B3"
	p_seja: .ascii "   SEJA MUITO   "
	p_confirma2: .ascii " SELECIONAR: B2 "
	p_segundaLinhaMenu: .ascii "<<            >>"
	p_desativado: .ascii "CONT. DESATIVADO"
	p_voltandoAoMenu: .ascii "VOLTANDO AO MENU"
	p_tchau: .ascii " FOI UM PRAZER  "
	p_volteSempre: .ascii "  VOLTE SEMPRE  "

    @rx
    PA14:
        .word 0x4
        .word 0x18
        .word 0xe
        .word 0x10 

    @tx
    PA13:
        .word 0x4
        .word 0x14
        .word 0xd
        .word 0x10
    
    /*
	======================================================
       Todas as labels com o nome de um pino da
		Orange PI PC Plus contem 4 ~words~

		Word 1: offset do registrador de funcao do pino
		Word 2: offset do pino no registrador de funcao (LSB)
		Word 3: offset do pino no registrador de dados
		Word 3: offset do registrador de dados do pino
	======================================================
	*/

    @ LED Vermelho
    PA9:
		.word 0x4
		.word 0x4
		.word 0x9
		.word 0x10
    
	@botão alongado
	PA7:
		.word 0x0
		.word 0x1C
		.word 0x7
		.word 0x10
	

    @ LED Azul
    PA8:
		.word 0x4
		.word 0x0
		.word 0x8
		.word 0x10
		
	@PG7 - DB7
	d7:
		.word 0xD8
		.word 0x1C
		.word 0x7
		.word 0xE8

	@PG6 - DB6
	d6:
		.word 0xD8
		.word 0x18
		.word 0x6
		.word 0xE8

	@PG9 - DB5
	d5:
		.word 0xDC
		.word 0x4
		.word 0x9
		.word 0xE8

	@PG8 - DB4
	d4:
		.word 0xDC
		.word 0x0
		.word 0x8
		.word 0xE8
	
	@PA18 - Enable
	E:
		.word 0x8
		.word 0x8
		.word 0x12
    .word 0x10

	@PA2 - RS
	RS:
		.word 0x0
		.word 0x8
		.word 0x2
    .word 0x10

	@RW
	@GROUND

	@PA10 - Reset
	b1:
		.word 0x4
		.word 0x8
		.word 0xA
		.word 0x10

	@PA20 - Play/Pause
	b2:
		.word 0x8
		.word 0x10
		.word 0x14
		.word 0x10
