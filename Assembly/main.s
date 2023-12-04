.equ VALUE, 30 @ Valor a ser contado
.equ QTD_DIGITO, 2

.include "gpio.s"
.include "sleep.s"
.include "lcd.s"
.include "divisao.s"

.global _start
/*
======================================================
	syscall exit
======================================================
*/
.macro _end
    MOV R0, #0
    MOV R7, #1
    SVC 0
.endm

_start:
    MemoryMap
	GPIOPinIn b1 @ botão do meio
	GPIOPinIn b2 @ botão mais a direita antes do espaço
	GPIOPinIn PA7 @ botão mais a esquerda
	setLCDPinsOut
	init
	.ltorg
    twoLine @ liga a segunda linha do display
    

    inicio: @exibe no display a pagina de boas vindas
		@coloca os valores de texto para serem escritos na primeira e segunda linha	
		ldr r12, =p_bemvindo
		ldr r6, =p_menu 
		bl escreverLinhas @chama a função de escrever as 2 linhas do display

		waitToGo: @fica esperando em loop o pressionar do botao para poder ir para outra pagina
			GPIOPinState PA7
			CMP R1, #0 @ botão apertado
			beq pagina1
			b waitToGo
		b inicio
    
	//=====================================================================================================//
//PAGINAS DO MENU=================================================================================//
	//=====================================================================================================//

	@exibe menu -> umidade do sensor
	pagina1: 
		@coloca os valores de texto para serem escritos na primeira e segunda linha	
		ldr r12, = p_umidadeAtual 
		ldr r6, =p_confirma
		bl escreverLinhas  @chama a função de escrever as 2 linhas do display

		@fica esperando em loop o pressionar do botao para poder ir para outra pagina
		ondeIr:
			GPIOPinState b2 @botao a direita => confirmar essa opção
        	CMP R1, #0 @ botão apertado
        	beq pagUmidadeResultado @ir para proxima tela

			GPIOPinState PA7 @botao a esquerda => proxima pagina do menu
	        CMP R1, #0 @ botão apertado
    	    beq pagina2  
			
			b ondeIr
	

	@exibe menu -> situação do sensor
	pagina2: 
		@coloca os valores de texto para serem escritos na primeira e segunda linha	
		ldr r12, =p_situacao
		ldr r6, =p_confirma
		bl escreverLinhas @chama a função de escrever as 2 linhas do display

		@fica esperando em loop o pressionar do botao para poder ir para outra pagina
		ondeIr2:
			GPIOPinState b2 @botao a direita => confirmar essa opção
        	CMP R1, #0 @ botão apertado
        	beq pagSituacaoSensor @IR PARA PROXIMA PAGINA

			GPIOPinState PA7 @botao a esquerda => proxima pagina do menu
	        CMP R1, #0 @ botão apertado 
    	    beq pagina3 @IR PARA AMOSTRAGEM DOS DADOS
			
			b ondeIr2
	

	@exibe menu -> temperatura atual
	pagina3: 
		@coloca os valores de texto para serem escritos na primeira e segunda linha	
		ldr r12, =p_tempAtual
		ldr r6, =p_confirma
		bl escreverLinhas @chama a função de escrever as 2 linhas do display

		@fica esperando em loop o pressionar do botao para poder ir para outra pagina
		ondeIr3:
			GPIOPinState b2 @botao a direita => confirmar essa opção
        	CMP R1, #0 @ botão apertado
        	beq pagTemperaturaResultado @ir para amostragem de dados

			GPIOPinState PA7 @botao a esquerda => proxima pagina do menu
	        CMP R1, #0 @ botão apertado
    	    beq pagina4
			
			b ondeIr3


	@exibe menu -> temperatura continua
	pagina4: 
		@coloca os valores de texto para serem escritos na primeira e segunda linha	
		ldr r12, =p_tempCont
		ldr r6, =p_confirma
		bl escreverLinhas @chama a função de escrever as 2 linhas do display

		@fica esperando em loop o pressionar do botao para poder ir para outra pagina
		ondeIr4:
			GPIOPinState b2 @botao a direita => confirmar essa opção
        	CMP R1, #0 @ botão apertado
        	beq pagTemperaturaContinua @ir para amostragem de dados

			GPIOPinState PA7 @botao a esquerda => proxima pagina do menu
	        CMP R1, #0 @ botão apertado
    	    beq pagina5
			
			b ondeIr4


	@exibe menu -> umidade continua
	pagina5: 
		@coloca os valores de texto para serem escritos na primeira e segunda linha	
		ldr r12, =p_umidCont
		ldr r6, =p_confirma
		bl escreverLinhas @chama a função de escrever as 2 linhas do display

		@fica esperando em loop o pressionar do botao para poder ir para outra pagina
		ondeIr5:
			GPIOPinState b2 @botao a direita => confirmar essa opção
        	CMP R1, #0 @ botão apertado
        	beq pagUmidadeContinua @ir para amostragem de dados

			GPIOPinState PA7 @botao a esquerda => proxima pagina do menu
	        CMP R1, #0 @ botão apertado
    	    beq inicio
			
			b ondeIr5


	@exibe tela de confirmação de sair do monitoramento de temp continua
	pagExitTempContinua: 
		@coloca os valores de texto para serem escritos na primeira e segunda linha	
		ldr r12, =p_exitTemp
		ldr r6, =p_sairVoltar
		bl escreverLinhas @chama a função de escrever as 2 linhas do display

		@fica esperando em loop o pressionar do botao para poder ir para outra pagina
		ondeIr6:
			GPIOPinState b2 @botao a direita => confirmar essa opção
        	CMP R1, #0 @ botão apertado
        	beq inicio @ir para amostragem de dados
			
			GPIOPinState PA7 @botao a esquerda => volta para a temperatura continua
	        CMP R1, #0 @ botão apertado
    	    beq pagTemperaturaContinua

			b ondeIr6


	@exibe tela de confirmação de sair do monitoramento de umidade continua
	pagExitUmidContinua: 
		@coloca os valores de texto para serem escritos na primeira e segunda linha	
		ldr r12, =p_exitUmid
		ldr r6, =p_sairVoltar
		bl escreverLinhas @chama a função de escrever as 2 linhas do display

		@fica esperando em loop o pressionar do botao para poder ir para outra pagina
		ondeIr7:
			GPIOPinState b2 @botao a direita => confirmar essa opção
        	CMP R1, #0 @ botão apertado
        	beq inicio @ir para amostragem de dados

			GPIOPinState PA7 @botao a esquerda => volta para a umidade continua
	        CMP R1, #0 @ botão apertado
    	    beq pagUmidadeContinua
			
			b ondeIr7

	//=====================================================================================================//
//PAGINAS DE RESULTADO=================================================================================//
	//=====================================================================================================//


	@exibe na tela o valor recebido da temperatura continua
	pagTemperaturaContinua: 
		@coloca os valores de texto para serem escritos na primeira e segunda linha	
		ldr r12, =p_TemperaturaResultado
		ldr r6, =p_sair
		bl escreverLinhas @chama a função de escrever as 2 linhas do display

		ondeIr9:
			nanoSleep time1s time950ms
			nanoSleep time1s time950ms
			GPIOPinState b2 
        	CMP R1, #0 @ botão apertado
        	beq pagExitTempContinua @ir para pagina de confirmação de saida
			bne pagAtualizandoTemp @caso nao tenha apertado o botao vai para tela de aguardando atualização
			b ondeIr9
			

	@exibe na tela o valor recebido da umidade continua
	pagUmidadeContinua:
		@coloca os valores de texto para serem escritos na primeira e segunda linha	
		ldr r12, =p_UmidadeResultado
		ldr r6, =p_sair
		bl escreverLinhas @chama a função de escrever as 2 linhas do display

		ondeIr10:
			nanoSleep time1s time950ms
			nanoSleep time1s time950ms
			GPIOPinState b2  @botao a direita => sair da umidade continua
        	CMP R1, #0 @ botão apertado
        	beq pagExitUmidContinua @ir para pagina de confirmação de saida
			bne pagAtualizandoUmid @caso nao tenha apertado o botao vai para tela de aguardando atualização
			b ondeIr10
	

	@pagina para informar que esta esperando receber novo valor da temperatura continua
	pagAtualizandoTemp:
		@coloca os valores de texto para serem escritos na primeira e segunda linha	
		ldr r12, =p_aguarde
		ldr r6, =P_historicoTemperatura
		bl escreverLinhas @chama a função de escrever as 2 linhas do display
		
		@esperar o tempo para receber novo valor e entao poder voltar a pagina que apresenta o resultado
		esperarTempo:
			nanoSleep time1s time950ms
			nanoSleep time1s time950ms
			b pagTemperaturaContinua


	@pagina para informar que esta esperando receber novo valor da umidade continua
	pagAtualizandoUmid:
		@coloca os valores de texto para serem escritos na primeira e segunda linha	
		ldr r12, =p_aguarde
		ldr r6, =P_historicoUmidade
		bl escreverLinhas @chama a função de escrever as 2 linhas do display

		@esperar o tempo para receber novo valor e entao poder voltar a pagina que apresenta o resultado
		esperarTempo2:
			nanoSleep time1s time950ms
			nanoSleep time1s time950ms
			b pagUmidadeContinua

	@exibe na tela o valor recebido da umidade
	pagUmidadeResultado:
		@coloca os valores de texto para serem escritos na primeira e segunda linha	
		ldr r12, =p_UmidadeResultado
		ldr r6, =p_sair
		bl escreverLinhas @chama a função de escrever as 2 linhas do display

		@loop para permanecer nessa pagina ate apertar botao e sair
		esperarSair:
			GPIOPinState b2  @botao a direita => sair dessa tela
        	CMP R1, #0 @ botão apertado
        	beq pagina1 @volta para o menu
			b esperarSair

	@exibe na tela o valor recebido da temperatura
	pagTemperaturaResultado:
		@coloca os valores de texto para serem escritos na primeira e segunda linha	
		ldr r12, =p_TemperaturaResultado
		ldr r6, =p_sair
		bl escreverLinhas @chama a função de escrever as 2 linhas do display

		@loop para permanecer nessa pagina ate apertar botao e sair
		esperarSair2:
			GPIOPinState b2 @botao a direita => sair dessa tela
        	CMP R1, #0 @ botão apertado
        	beq pagina3 @volta para o menu
			b esperarSair2

	@exibe na tela a informação sobre o sensor
	pagSituacaoSensor:
		@coloca os valores de texto para serem escritos na primeira e segunda linha	
		ldr r12, =p_SituacaoSensor
		ldr r6, =p_sair
		bl escreverLinhas @chama a função de escrever as 2 linhas do display
		
		@loop para permanecer nessa pagina ate apertar botao e sair
		esperarSair3:
			GPIOPinState b2 @botao a direita => sair dessa tela
        	CMP R1, #0 @ botão apertado
        	beq pagina2 @volta para o menu
			b esperarSair3


	//=====================================================================================================//
//ESCREVER INFORMAÇÕES NO DISPLAY======================================================================//
	//=====================================================================================================//

	@realiza o controle dos registradores e escrita do caractere correto na linha do display
	escrita:
		sub sp, sp, #4
		str lr, [sp]

		ldr r9, [r12, r10]
		WriteCharLCD r9
		
		add r10, r10, #1
		cmp r10, r11

		ldr lr, [sp]
		add sp, sp, #4

		blt escrita
		bx lr


	@realiza o controle para poder escrever nas duas linhas do display
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



	EXIT2:
		_end

	@exibe uma tela generica de testes
	telaDelevopment:
		@coloca os valores de texto para serem escritos na primeira e segunda linha	
		ldr r12, =p_criando
		ldr r6, =p_bemvindo
		bl escreverLinhas @chama a função de escrever as 2 linhas do display

		ondeIr8:
			GPIOPinState b2
        	CMP R1, #0 @ botão apertado
        	beq inicio @ir para amostragem de dados

			GPIOPinState PA7
	        CMP R1, #0 @ botão apertado
    	    beq inicio
			
			b ondeIr8


//DATA

.data
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
	p_TemperaturaResultado: .ascii "   TEMP: 24 C   "
	p_UmidadeResultado: .ascii "   UMID: 59 %   "
	p_SituacaoSensor: .ascii "  SENSOR 01: OK "
	p_sair: .ascii "    SAIR:B3     "
	p_sairVoltar: .ascii "SAIR:B3 VOLTA:B1"
	p_criando: .ascii "LOADING THE PAGE"
	p_aguarde: .ascii "  AGUARDE ATT   "
	P_historicoUmidade: .ascii " HISTORICO: 59% "
	P_historicoTemperatura: .ascii " HISTORICO: 25C "



    fileName: .asciz "/dev/mem" @ caminho do arquivo que representa a memoria RAM
    gpioaddr: .word 0x1C20 @ endereco base GPIO / 4096
    pagelen: .word 0x1000 @ tamanho da pagina
    
	time1s: .word 1  @ 1s

	time1ms: .word 1000000 @ 1ms

	time850ms: .word 850000000 @850ms

    time950ms: .word 950000000 @850ms

	time170ms: .word 170000000 @ 170ms

	timeZero: .word 0 @ zero
   
	time1d55ms: .word 1500000 @ 1.5ms

	time5ms: .word 5000000 @ 5 ms

	time150us: .word 150000 @ 150us
	
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
