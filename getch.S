#include <mips/regdef.h>
#include <sys/syscall.h>
##------------------------------------------------------------------------------
## DEFINITIONS
##------------------------------------------------------------------------------
#ifndef STACK_FRAME_SIZE
#define STACK_FRAME_SIZE 44
#endif

#ifndef RETURN_POINTER_POS
#define RETURN_POINTER_POS 40
#endif

#ifndef GLOBAL_POINTER_POS
#define GLOBAL_POINTER_POS 36
#endif

#ifndef FRAME_POINTER_POS
#define FRAME_POINTER_POS 32
#endif

#ifndef BYTES_READ_POS
#define BYTES_READ_POS 24
#endif

#ifndef WHILE_COUNTER_POS
#define WHILE_COUNTER_POS 20
#endif

#ifndef POSITION_POS
#define POSITION_POS 56
#endif

#ifndef IBYTES_POS
#define IBYTES_POS 52
#endif

#ifndef BUFFER_POS
#define BUFFER_POS 48
#endif

#ifndef FD_POS
#define FD_POS 44
#endif

#ifndef ERROR_VALUE
#define ERROR_VALUE -2
#endif

#ifndef EOF
#define EOF -1
#endif
##------------------------------------------------------------------------------
## CODIGO EQUIVALENTE EN C
##------------------------------------------------------------------------------
##int getch(int fd, char* buffer, size_t iBytes, size_t* pos) {
    ##if (*pos == iBytes || *pos == 0) {
        ##*pos = 0;
        ##int received = 0;
        ##ssize_t bytesRead = -1;
        ##while (received < iBytes && bytesRead != 0) {
            ##bytesRead = read(fd, buffer+received, iBytes-received);
            ##if (bytesRead == -1) return -2;
            ##if (bytesRead == 0) buffer[received] = EOF;
            ##received += bytesRead;
        ##}
    ##}
    ##int c = buffer[*pos];
    ##(*pos)++;
    ##return c;
##}
##------------------------------------------------------------------------------
## CODIGO EN MIPS
##------------------------------------------------------------------------------
    .text
    .abicalls
    .align 2
    .globl getch
    .ent getch
getch:
    ##--------------------------------------------------------------------------
    ## INICIALIZACION DEL STACK FRAME
    ##--------------------------------------------------------------------------
    .frame $fp, STACK_FRAME_SIZE, ra
    .set noreorder
    .cpload t9
    .set reorder
    subu sp, sp, STACK_FRAME_SIZE
    .cprestore GLOBAL_POINTER_POS
    sw $fp, FRAME_POINTER_POS(sp)
    sw ra, RETURN_POINTER_POS(sp)
    move $fp, sp
    sw a0, FD_POS($fp)
    sw a1, BUFFER_POS($fp)
    sw a2, IBYTES_POS($fp)
    sw a3, POSITION_POS($fp)
    ##--------------------------------------------------------------------------
    ## FIN INICIALIZACION DEL STACK FRAME
    ##--------------------------------------------------------------------------
    ## if (*pos == iBytes || *pos == 0)
    lw a3, POSITION_POS($fp)  ## a3 = &pos;
    lw t0, 0(a3)  ## t0 = *pos;
    lw a2, IBYTES_POS($fp) ## a2 = iBytes;
    beq a2, t0, readFile  # if (*pos == iBytes) readFile
    beq t0, zero, readFile  # if (*pos == 0) readFile

findValue:
    ## int c = buffer[*pos];
    lw a3, POSITION_POS($fp)  ## a3 = &pos;
    lw t0, 0(a3)  ## t0 = *pos;
    lw a1, BUFFER_POS($fp)  ## a1 = buffer
    addu a1, a1, t0  # a1 = Buffer+pos
    lb v0, 0(a1)  # v0 = *(Buffer+pos)

    ## *pos++;
    lw a3, POSITION_POS($fp)  ## a3 = &pos;
    lw t0, 0(a3)  ## t0 = *pos;
    addu t0, t0, 1  # t0 = *pos++;
    sw t0, 0(a3)  ## *pos++;

return:
    lw gp, GLOBAL_POINTER_POS(sp)
    lw $fp, FRAME_POINTER_POS(sp)
    lw ra, RETURN_POINTER_POS(sp)
    addu sp, sp, STACK_FRAME_SIZE
    jr ra
    .end getch
    .size getch,.-getch

readFile:
    ## Aca desreferencio pos, y le guardo cero, y luego hago que la posicion
    ## de memoria de pos a apunte a ese nuevo valor
    ##--------------------------------------------------------------------------
    ## *pos = 0
    li t0, 0
    lw a3, POSITION_POS($fp)
    sw t0, 0(a3)
    ##--------------------------------------------------------------------------
    li t1, 0  ## int received = 0;
    sw t1, WHILE_COUNTER_POS($fp)  ## salvo los bytes recibidos en stack frame
    li t0, -1
    sw t0, BYTES_READ_POS($fp)  ## int bytesRead = -1;
while:
    ## while (received < iBytes && bytesRead != 0)
    ## Como el while contiene un 'and' si alguno es falso sale de la condicion

    ## Aca pregunto si la primera condicion del while es falsa. De serlo sigo
    ## con la parte de leer el siguiente caracter del buffer, es decir, con la
    ## parte del codigo llamada findValue
    ##--------------------------------------------------------------------------
    ## if (received - iBytes >= 0) sale del while
    ##--------------------------------------------------------------------------
    lw t1, WHILE_COUNTER_POS($fp)  ## t1 = received
    lw a2, IBYTES_POS($fp)  # a2 = iBytes
    subu t2, t1, a2  # t2 = received - iBytes
    bgez t2, findValue  # if (received - iBytes >= 0) sale del while
    ##--------------------------------------------------------------------------
    ## if (bytesRead == 0) sale del while
    ##--------------------------------------------------------------------------
    ## Aca pregunto si la segunda condicion del while es falsa. De serlo sigo
    ## con la parte de leer el siguiente caracter del buffer, es decir, con la
    ## parte del codigo llamada findValue
    lw t0, BYTES_READ_POS($fp)  ## t0 = bytesRead
    beq t0, zero, findValue  ## if (bytesRead == 0) sale del while

    ## Aca llamo al SYSCALL del read
    li v0, SYS_read
    lw a0, FD_POS($fp)  # a0 = fd
    lw a1, BUFFER_POS($fp)  # a1 = buffer
    lw t1, WHILE_COUNTER_POS($fp)  ## t1 = received
    addu a1, a1, t1  # a1 = buffer+received
    lw a2, IBYTES_POS($fp)  # a2 = iBytes
    lw t1, WHILE_COUNTER_POS($fp)  ## t1 = received
    subu a2, a2, t1  ## a2 = iBytes-received
    SYSCALL
    sw v0, BYTES_READ_POS($fp)  ## salvo los bytes leidos
    ##--------------------------------------------------------------------------
    ## VERIFICACION DE ERRORES DE READ
    ##--------------------------------------------------------------------------
    bne a3, zero, ERROR  # si a3 !=0 retorna error

    ## read retorna su valor en el registro v0. Entonces si v0 es -1 quiere
    ## decir que hubo un error.
    li t3, -1  # Guardo -1 en t3
    lw t0, BYTES_READ_POS($fp)   ## t0 = bytesRead;
    beq t0, t3, ERROR  # si t0 == -1 retorna error
    ##--------------------------------------------------------------------------
    ## FIN VERIFICACION DE ERRORES DE READ
    ##--------------------------------------------------------------------------
    ## read retorna su valor en el registro v0. Entonces si v0 es 0 quiere
    ## decir que detecto el EOF
    ##if (bytesRead == 0) buffer[received] = EOF;
    lw t0, BYTES_READ_POS($fp)  ## t0 = bytesRead;
    beq t0, zero, END_READING

endWhile:
    ## Actualizo la posicion del buffer para que pueda seguir leyendo sobre
    ## el en la parte restante
    lw t1, WHILE_COUNTER_POS($fp)  ## t1 = received
    lw t0, BYTES_READ_POS($fp)   ## t0 = bytesRead;
    addu t1, t1, t0  #  received += bytesRead;
    sw t1, WHILE_COUNTER_POS($fp)  ## received += bytesRead;
    j while

END_READING:
    ##--------------------------------------------------------------------------
    ## buffer[received] = EOF;
    ##--------------------------------------------------------------------------
    lw a1, BUFFER_POS($fp)  # a1 = buffer
    lw t1, WHILE_COUNTER_POS($fp)  ## t1 = received
    addu a1, a1, t1  ## a1 = buffer+received
    li t0, EOF
    sw t0, 0(a1)  ## *(buffer+received) = EOF;
    j endWhile

ERROR:
    li v0, ERROR_VALUE  # Guardo en v0 el valor ERROR_VALUE
    j return
##------------------------------------------------------------------------------
