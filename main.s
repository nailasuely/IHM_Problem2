@ Valor para o contador
.equ VALUE, 30 
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
	GPIOPinIn PA7 @ botão alongado
	setLCDPinsOut
	init
    twoLine @ liga a segunda linah do display

    ldr r12, =p_bemvindo
    mov r10, #0
    
    @ botões são contadores, quando clica muda de indice/página
    @ cada "página" contém uma palavra que define a tela do display atual

    inicio:
        GPIOPinState PA7
        CMP R1, #0 @ botão apertado
        beq loop
        b inicio
    
    loop:
        @ percorre a palavra letra por letra
        ldr r11, [r12, r10]
        WriteCharLCD R11 @ escreve a letra no local certo e aumenta o ponteiro +1

        add r10, r10, #1 @ incrementa o r10
        
        @ verifica se ja atingiu o tamanho da palavra
        cmp r10, #17
        beq EXIT
        b loop

    loop2:
		@ Parte no qual a palavra é percorrida letra por letra
        ldr r11, [r12, r10]
        WriteCharLCD R11 @ escreve a letra no local certo e aumenta o ponteiro +1

        add r10, r10, #1 @ incrementa o r10
        
        @ verifica se ja atingiu o tamanho da palavra
        cmp r10, #17
        beq EXIT2
        b loop2

	mudaTela:
		GPIOPinState b2
        CMP R1, #0 @ botão apertado
		ldr r12, = p_situacao
        beq loop
        b mudaTela



	EXIT:
		ldr r12, =p_menu
		mov r10, #0
		secondLine
		b loop2

	EXIT2:
		b mudaTela
		_end

.data
    p_bemvindo: .ascii "--BEM-VINDO(A)--" 
    p_menu: .ascii "MENU COMANDOS >>" 
	p_situacao: .ascii "SITUACAO SENSOR "
	p_umidadeAtual: .ascii "UMID ATUAL"
	p_tempAtual: .ascii "TEMP ATUAL"
	p_confirma: .ascii "CONFIRMA: B3"
	p_tempCont: .ascii "MON CONT TEMP"
	p_umidCont: .ascii "MON CONT UMID"
	p_exitUmid: .ascii "SAIR CONT UMID"
	p_exitTemp: .ascii "SAIR CONT TEMP" 
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
