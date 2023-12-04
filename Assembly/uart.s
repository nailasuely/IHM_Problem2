@ Função para enviar um caractere pela UART0 
send_char:
    LDR R0, =0x01C28000    @ Endereço base do registrador UART0 
    LDR R1, [R0, #0x14]    @ Lê o registrador LSR para verificar se a FIFO está vazia
    TST R1, #0x20          @ Testa o bit 5 (Transmitter FIFO Empty)
    BEQ send_char          @ Se a FIFO não estiver vazia, aguarde

    LDR R1, [R0, #0x00]    @ Lê o registrador THR para enviar o caractere 
    BX LR

@ Função para receber um caractere pela UART0  
receive_char:
    LDR R0, =0x01C28000    @ Endereço base do registrador UART0 
    LDR R1, [R0, #0x14]    @ Lê o registrador LSR para verificar se há dados na FIFO 
    TST R1, #0x01          @ Testa o bit 0 (Receiver Data Ready) 
    BEQ receive_char       @ Se não houver dados, aguarde 

    LDR R1, [R0, #0x00]    @Lê o registrador RBR para receber o caractere  
    BX LR
