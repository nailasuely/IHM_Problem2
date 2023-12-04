@ CÓDIGO QUE MAPEIA A UART DA ORANGE PI E A HABILITA PARA RECEBER E TRANSMITIR DADOS SERIAIS


@ parte do mapeamento do uart 

.equ sys_open, 5
.equ sys_mmap2, 192 @ linux 

@manipulação de arquivos 
.equ S_RDWR, 0666
.equ pagelen, 4096
.equ PROT_READ, 1
.equ PROT_WRITE, 2
.equ MAP_SHARED, 1

@ modo e leitura e escrita 
.equ O_RDWR,	00000002
.equ O_SYNC,	00010000


 @offsets dos registradores da uart 

.equ UART_CR, 0x30  @ controle 
.equ UART_FR, 0x18  @ dados
.equ UART_DR, 0x0  @ linhas de controle para o fifo   
.equ UART_LCR, 0x2c @ divisor de boud inteiro 
.equ UART_IBRD, 0x24 
.equ UART_FBRD, 0x28

.equ UART_TXFF, (1<<5)  @ checar se fifo ta vazio 
@ nessa parte ele faz o deslocamento de bit tb
.equ UART_RXE, (1<<9) @ ATIVAR RECEBIMENTO (VERIFICAR NO DATASHEET) 
.equ UART_TXE, (1<<8) @ ativar transmissão
.equ UART_UARTEN, (1<<0) @ enable uart (ativar uart)

@isso aqui me deixa um pouco confusa, mas teoricamente é para ligar uart, configurar a trnamissão e recepção ao mesmo tempo
.equ FINALBITS, (UART_RXE|UART_TXE|UART_UARTEN)

.equ UART_FIFOCLR, (0<<4)  @ parte de desabilitar 
.equ UART_FIFOEN, (1<<4) @ 
.equ BITS, (UART_WLEN1|UART_WLEN0|UART_FEN|UART_STP2|UART_PEN|UART_PT)
.equ UART_WLEN1, (1<<6)
.equ UART_WLEN0, (1<<5)
.equ UART_FEN, (1<<4)
.equ UART_STP2, (1<<3)
.equ UART_PEN, (1<<1)
.equ UART_PT, (1<<2)

.align 2

.data
flags:	.word O_RDWR + O_SYNC
openMode:	.word 0666
devmem: .asciz "/dev/mem"
uartaddr: .word 0x01C28C00
.align 2

.section .text
.global _start
_start:
    ldr r0, =devmem
    ldr r1, =(O_RDWR + O_SYNC)
    mov r7, #sys_open
    svc 0
    movs r4, r0 
    BPL 1f

1:  ldr r5, =uartaddr
    ldr r5, [r5]
    mov r1, #pagelen
    mov r2, #(PROT_READ + PROT_WRITE)
    mov r3, #MAP_SHARED
    mov r0, #0
    mov r7, #sys_mmap2
    svc 0
    movs r9, r0

    @ aqui é onde acontece a desabilitação da uart para realizar a config 
    mov r0, #0
    str r0, [r9, #UART3_CR]

    @ espera do fim da recepção ou transmisão do caractere final (no fifo)

    loop: ldr r2, [r9, #UART3_FR]
          tst r2, #UART_TXFF
          bne loop

    ldr r1, [r8, #UART_LCR]
    mov r0, #1
    lsl r0, #4
    bic r1, r0
    str r1, [r8, #UART_LCR]

    mov r0, #0x13
    str r0, [r8, #UART_IBRD]
    mov r0, #0x22
    str r0, [r8, #UART_FBRD]

    ldr r0, =FINALBITS
    str r0, [r8, #UART_CR]

    mov r0, #BITS
    str r0, [r8, #UART_LCR]

loop1:  mov r0, #0b10101010
        str r0, [r8, #UART_DR]
        mov r0, #0b0000010
        str r0, [r8, #UART_DR]
        bl loop1

_end:   mov r0, #0
        mov r7, #1
        svc 0
