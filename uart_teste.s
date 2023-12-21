@OFFSETS 
.equ RBR,   0x0000   @ UART Receive Buffer Register
.equ THR,   0x0000   @ UART Transmit Holding Register
.equ FCR,   0x0008   @ UART FIFO Control Register
.equ LCR,   0x000C   @ UART Line Control Register
.equ HALT,   0x00A4   @ UART Halt TX Register
.equ DLL,   0x0000 @UART parte baixa do registrador
.equ DLH,   0x0004  @UART parte alta do registrador
.equ CCU_UART_CLOCK_BIT, 0x0058
.equ UART_OFFSET, 0b0


@OFFSETS
.EQU UART_RBR, 0x0000 @registro de buffer de recebimento uart
.EQU UART_THR, 0x0000 @registro de retenção de transmissão uart
.EQU UART_DLL, 0x0000 @registro baixo de trava do divisor uart
.EQU UART_DLH, 0x0004 @registro alto da trava do divisor uart
.EQU UART_IER, 0x0004 @registro de ativação de interrupção uart
.EQU UART_IIR, 0x0008 @registro de identidade de interrupção uart
.EQU UART_FCR, 0x0008 @registro de controle uart FIFO
.EQU UART_LCR, 0x000C @registro de controle de linha uart
.EQU UART_MCR, 0x0010 @registro de controle de moden uart
.EQU UART_LSR, 0x0014 @registro de status de linha uart
.EQU UART_MSR, 0x0018 @registro de status de moden uart
.EQU UART_SCH, 0x001C @registro de rascunho uart
.EQU UART_USR, 0x007C @registro de status uart
.EQU UART_TFL, 0x0080 @nível FIFO de tranmissão uart
.EQU UART_RFL, 0x0084 @uart_RFL 
.EQU UART_HALT, 0x00A4 @uart interrompe registro de tx
.EQU UART3_RST, 0x02D8 @BUS_SOFT_RST_REG4
.EQU UART3_GATING, 0x006C @BUS_CLK_GATING_REG3
.EQU APB2_CLK_SRC_SEL, 0x0058 @APB2_CFG_REG
.EQU PLL_PERIPH0_CTRL_REG, 0x0028 @offset do PLL PERIFERICO 0

@ CONSTANTES E ENDEREÇOS
.equ O_RDWR, 2            @ Permissões de leitura e escrita para sys_open
.equ sys_open, 5          @ Número do serviço sys_open
.equ sys_mmap2, 192       @ Número do serviço sys_mmap2


@ =========================================================================================================================
@ Função geral de configuração da UART e que permite que ela funcione como esperado
@ Para o seu funcionamento é necessario:
@    -realizar o mapeamento de memoria da CCU - referente ao clock
@    -realizar a configuração da CCU, colocando os valores nos bits desejados, seguindo o datasheet
@    do AllWinner H3 para que ele funcione no modo desejado
@   -realizar o mapeamento de memoria da UART
@   -realizar configuração da UART colocandos os valores nos determinados bits para poder
@    configura-la e tê-la funcionando conforme desejado
@
@  Nas configurações usou-se um registrador para poder colocar o valor nele, e mover ate o local adequado
@  e por fim carregar esse valor no registrador que foi mapeado na memoria
@ ========================================================================================================================
ConfigurarUart:
    MapeamentoMemoriaClock:
        @sys_open
        LDR R0, =devMem @ R0 = nome do arquivo
        MOV R1, #2 @ O_RDWR (permissao de leitura e escrita pra arquivo)
        MOV R7, #5 @ sys_open
        SVC 0
        MOV R4, R0 @ salva o descritor do arquivo.

        @sys_mmap2
        MOV R0, #0 @ NULL (SO escolhe o endereco)
        LDR R1, =pagelen 
        LDR R1, [R1]
        MOV R2, #3 @ protecao leitura ou escrita
        MOV R3, #1 @ memoria compartilhada
        LDR R5, =registerCCU
        LDR R5, [R5]  
        MOV R7, #192 @sys_mmap2
        SVC 0
        MOV R9, R0  

    @realiza a configuração do CCU para fazer os direcionamentos
    ConfiguracaoClock:
        @ativa a saida do PLL - v
        LDR R0, [R9, #PLL_PERIPH0_CTRL_REG]
        MOV R5, #1
        LSL R5, R5, #31
        ORR R0, R0, R5
        STR R0, [R9, #PLL_PERIPH0_CTRL_REG]

        @habilitar clock PLL_PERIPH0 - v
        LDR R0, [R9, #APB2_CLK_SRC_SEL]
        MOV R5, #3 @0b11
        LSL R5, R5, #24
        ORR R0, R0, R5
        STR R0, [R9, #APB2_CLK_SRC_SEL]

        @habilito clock na uart3 - v
        LDR R0, [R9, #UART3_GATING]
        MOV R5, #1
        LSL R5, R5, #19
        ORR R0, R0, R5
        STR R0, [R9, #UART3_GATING]


        @CONFERIR NECESSIDADE DE DESATIVAR E ATIVAR O RESET
        @PODE PRECISAR NEM MEXER
        @desativo o enable colocando o bit 19 do endereco em 1
        LDR R0, [R9, #UART3_RST]
        MOV R5, #1
        LSL R5, R5, #19
        BIC R0, R0, R5
        STR R0, [R9, #UART3_RST]
        
        @ativo o enable colocando o bit 19 do endereco em 1
        LDR R0, [R9, #UART3_RST]
        MOV R5, #1
        LSL R5, R5, #19
        ORR R0, R0, R5
        STR R0, [R9, #UART3_RST]

    @ =========================================================================================================================
    @ MapeamentoUart: Realiza o mapeamento de memória para a UART
    @
    @ Esta função é usada para solicitar ao sistema operacional o acesso à memória, realizar o mapeamento da região
    @ desejada (no caso, a UART) e salvar o endereço mapeado para operações futuras.
    @
    @ Passos:
    @   - Pedido ao Sistema Operacional: Usa o serviço sys_open para abrir o arquivo devMem e obter as permissões de leitura
    @     e escrita.
    @   - Mapeamento para a UART: Usa o serviço sys_mmap2 para mapear a memória, especificando opções como endereço
    @     aleatório (0), tamanho da página e proteção de leitura e escrita.
    @   - Salvando o Endereço: Salva o endereço mapeado na variável r9, adicionando um deslocamento de 0xC00,
    @     para a região da UART3.
    @
    @ Observações:
    @   - O endereço base da UART é carregado da variável base_uart, que deve conter o endereço inicial da região de
    @     memória associada à UART.
    @   - A solicitação ao sistema operacional para mapeamento de memória é muito importante para garantir acesso seguro e
    @     controle de permissões.
    @
    @ ========================================================================================================================
    MapeamentoUart:
        @PEDE AO SISTEMA OPERACIONAL PARA PODER MEXER Na MEMORIA
        ldr     R0, =devMem      @ Carrega o endereço do arquivo
        mov     R1, #O_RDWR      @ Define as permissões
        mov     R7, #sys_open    @ Chama o serviço sys_open para abrir o arquivo
        svc     0
        mov     R4, R0           @ Salva o retorno do serviço sys_open em R4

        @MAPEAMENTO PARA A UART
        mov     R0, #0                @ Deixa o S0 escolher o endereço aleatório (memória virtual)
        ldr     R1, =pagelen         @ Tamanho da página
        ldr     R1, [R1]
        mov     R2, #3                @ Opções de proteção de memória (PROT_READ + PROT_WRITE)
        mov     R3, #1
        ldr     R5, =base_uart        @ Endereço da memória
        ldr     R5, [R5]              @ Carrega o endereço
        mov     R7, #sys_mmap2        @ Chama o serviço sys_mmap2 para mapear a memória
        svc     0
        mov     r9, R0                @ Salva o retorno do serviço sys_mmap2
        add R9, #0xC00 @ soma para sair do endereço base ate a uart3

    @ =========================================================================================================================
    @ Configurações UART: Funções para configurar a UART3
    @
    @ Este conjunto de funções é responsável por configurar diferentes parâmetros da UART3, tais como tamanho dos dados,
    @ baud rate, ativação de FIFO.
    @ ========================================================================================================================
    PinosUart:
        ldr r1, [r0]
        ldr r3, [r0, #4]
        ldr r2, [r8, r1]
        mov r4, #0b111
        lsl r4, r3
        bic r2, r4
        mov r4, #0b011
        lsl r4, r3
        orr r2, r4
        str r2, [r8, r1]

    @faz a setagem do tamanho dos dados para 8 bits = 1 byte
    SetarTamanhoDados:
        ldr R0, [r9, #LCR]       @ Carrega o conteúdo do registrador
        mov R5, #3
        orr R0, R0, R5           @ Aplica a máscara
        str R0, [r9, #LCR]       @ Salva de volta no registrador
    @ ativa o DLAB para permitir alterar os valores do DLL e DLH
    AtivarDlab:
        ldr R0, [r9, #LCR]       @ Carrega o conteúdo do registrador
        mov R5, #1
        lsl R5, R5, #7
        orr R0, R0, R5           @ Aplica a máscara
        str R0, [r9, #LCR]       @ Salva de volta no registrador 
    @coloca o valor da parte BAIXA do divisor do baude rate
    SetarValorDLL:
        ldr R0, [r9, #DLL]        @ Carrega o conteúdo do registrador
        bic R5, #0b11111111
        bic R0, #0b11111111
        mov R5, #0b00000000
        orr R0, R0, R5            @ Aplica a máscara
        str R0, [r9, #DLL]       @ Salva de volta no registrador

    @coloca o valor da parte alta do divisor do baude rate
    SetarValorDLH:
        ldr R0, [r9, #DLH]        @ Carrega o conteúdo do registrador
        bic R5, #0b11111111
        bic R0, #0b11111111
        mov R5, #0b00010000
        orr R0, R0, R5            @ Aplica a máscara
        str R0, [r9, #DLH]        @ Salva de volta no registrador
    @desativa o DLAB para poder ter funcionamento normal da UART
    DesativarDLAB:
        ldr R0, [r9, #LCR]       @ Carrega o conteúdo do registrador
        mov R5, #1
        lsl R5, R5, #7
        bic R0, R5
        str R0, [r9, #LCR]       @ Salva de volta no registrador
    /*
    AtualizarValorBaudRateDivisor:
        ldr R0, [r9, #HALT]       @ Carrega o conteúdo do registrador
        mov R5, #1
        lsl R5, R5, #2
        orr R0, R0, R5            @ Aplica a máscara
        str R0, [r9, #HALT]       @ Salva de volta no registrador
    */
    @coloca o valor da parte alta do divisor do baude rate
    AtivarFIFO:
        ldr R0, [r9, #FCR]        @ Carrega o conteúdo do registrador
        mov R5, #1
        orr R0, R0, R5            @ Aplica a máscara
        str R0, [r9, #FCR]        @ Salva de volta no registrador

    bx lr

@coloca o valor no registrador que serve para enviar o dado pela UART
EnviarDados:
    str     r0, [r9, #THR]
    bx lr
@recebe o valor via UART, verificando antes de sair se chegou um dado ou nao, ou seja
@ele fica esperando chegar um dado para sair
ReceberDados:
    @verificação para o FIFO se esta vazio ou nao
    ldr r1, [r9, #0x7C]
    mov r2, #1
    lsr r1, #3
    and r1, r2
    cmp r1, #0
    beq ReceberDados

    ldr     r0, [r9, #RBR]
    
    bx lr

Mapeamento_Uart:
    @PEDE AO SISTEMA OPERACIONAL PARA PODER MEXER Na MEMORIA
    ldr     R0, =devMem      @ Carrega o endereço do arquivo
    mov     R1, #O_RDWR      @ Define as permissões
    mov     R7, #sys_open    @ Chama o serviço sys_open para abrir o arquivo
    svc     0
    mov     R4, R0           @ Salva o retorno do serviço sys_open em R4

    @MAPEAMENTO PARA A UART
    mov     R0, #0                @ Deixa o S0 escolher o endereço aleatório (memória virtual)
    ldr     R1, =pagelen         @ Tamanho da página
    ldr     R1, [R1]
    mov     R2, #3                @ Opções de proteção de memória (PROT_READ + PROT_WRITE)
    mov     R3, #1
    ldr     R5, =base_uart        @ Endereço da memória
    ldr     R5, [R5]              @ Carrega o endereço
    mov     R7, #sys_mmap2        @ Chama o serviço sys_mmap2 para mapear a memória
    svc     0
    mov     r9, R0                @ Salva o retorno do serviço sys_mmap2
    add R9, #0xC00 @ soma para sair do endereço base ate a uart3
    bx lr
    
resetFIFO:
    ldr R0, [r9, #FCR]        @ Carrega o conteúdo do registrador
    mov R5, #1
    lsl R0, R0, #1
    orr R0, R0, R5            @ Aplica a máscara
    str R0, [r9, #FCR]        @ Salva de volta no registrador
    bx lr
    