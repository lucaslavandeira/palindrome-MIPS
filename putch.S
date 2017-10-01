#include <sys/syscall.h>
#include <mips/regdef.h>
##------------------------------------------------------------------------------
## DEFINITIONS
##------------------------------------------------------------------------------
#ifndef STACK_FRAME_SIZE
#define STACK_FRAME_SIZE 40
#endif

#ifndef RETURN_POINTER_POS
#define RETURN_POINTER_POS 36
#endif

#ifndef GLOBAL_POINTER_POS
#define GLOBAL_POINTER_POS 32
#endif

#ifndef FRAME_POINTER_POS
#define FRAME_POINTER_POS 28
#endif

#ifndef WHILE_COUNTER_POS
#define WHILE_COUNTER_POS 20
#endif

#ifndef CHAR_POS
#define CHAR_POS 56
#endif

#ifndef POSITION_POS
#define POSITION_POS 52
#endif

#ifndef OBYTES_POS
#define OBYTES_POS 48
#endif

#ifndef BUFFER_POS
#define BUFFER_POS 44
#endif

#ifndef FD_POS
#define FD_POS 40
#endif

#ifndef EOF
#define EOF -1
#endif
##------------------------------------------------------------------------------
## MACROS DEFINITIONS
##------------------------------------------------------------------------------
.MACRO dereferencePosTot0
    lw a3, POSITION_POS($fp)  ## Redundante pero provisorio
    lw t0, 0(a3)  ## desreferencio el puntero y guardo el valor en t0
.ENDM
##------------------------------------------------------------------------------
## CODIGO EQUIVALENTE EN C
##------------------------------------------------------------------------------
##int putch(int fd, char* buffer, size_t oBytes, size_t* pos, char c) {
    ##if (*pos == oBytes || c == EOF) {
        ##int sent = 0;
        ##ssize_t bytesSent;
        ##while (sent < *pos) {
            ##bytesSent = write(fd, buffer+sent, *pos-sent);
            ##if (bytesSent == -1) return -1;
            ##sent += bytesSent;
        ##}
        ##*pos = 0
    ##}
    ##buffer[*pos] = c;
    ##*pos++;
    ##return 0;
##}
##------------------------------------------------------------------------------
## CODIGO EN MIPS
##------------------------------------------------------------------------------
    .text
    .abicalls
    .align 2
    .globl putch
    .ent putch
putch:
    ##--------------------------------------------------------------------------
    ## Inicializacion del stack frame
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

    sw a0, FD_POS($fp)  # file descriptor
    sw a1, BUFFER_POS($fp)  # buffer
    sw a2, OBYTES_POS($fp)  # capacidad maxima del buffer
    sw a3, POSITION_POS($fp)  # position actual de escritura del buffer
    lw t7, CHAR_POS($fp)  # caracter a escribir
    sb t7, CHAR_POS($fp)  # caracter a escribir
    ##--------------------------------------------------------------------------
    ## FIN Inicializacion del stack frame
    ##--------------------------------------------------------------------------
    ##if (*pos == oBytes || c == EOF)
    dereferencePosTot0  # t0 = *pos
    ## t0 = *pos
    lw a2, OBYTES_POS($fp)  # Redundante pero provisorio
    ## a2 = oBytes
    beq a2, t0, writeFile  # if (*pos == oBytes) writeFile
    lb t7, CHAR_POS($fp)   # Redundante pero provisorio t7 = c
    li t0, EOF
    beq t7, t0, writeFile  # if (*pos == 0) writeFile
##------------------------------------------------------------------------------
## WRITE VALUE
##------------------------------------------------------------------------------
writeValue:
    dereferencePosTot0  # t0 = *pos

    ## buffer[+pos];
    lw a1, BUFFER_POS($fp)  # a1 = buffer
    addu a1, a1, t0  # a1 = buffer + pos;
    lb t7, CHAR_POS($fp)  # t7 = c
    sb t7, 0(a1)  # *(buffer + pos) = c

    ## *pos++;
    dereferencePosTot0  # t0 = *pos
    addu t0, t0, 1  # incremento el valor de la posicion
    lw a3, POSITION_POS($fp)  # a3 = &pos;
    sw t0, 0(a3)  # *pos++;

    li v0, 0  # return 0
##------------------------------------------------------------------------------
## RETURN
##------------------------------------------------------------------------------
return:
    lw gp, GLOBAL_POINTER_POS(sp)
    lw $fp, FRAME_POINTER_POS(sp)
    lw ra, RETURN_POINTER_POS(sp)
    addu sp, sp, STACK_FRAME_SIZE
    jr ra
    .end putch
    .size putch,.-putch
##------------------------------------------------------------------------------
## WRITE FILE
##------------------------------------------------------------------------------
writeFile:
    li t1, 0  # int sent = 0
    sw t1, WHILE_COUNTER_POS($fp)  ## salvo los bytes enviados en stack frame
while:
    ## Aca pregunto si la condicion del while es falsa. De serlo sigo
    ## con la parte de escribir el siguiente caracter del buffer, es decir,
    ## con la parte del codigo llamada writeValue
    ## while (sent < *pos)
    dereferencePosTot0  # t0 = *pos
    lw t1, WHILE_COUNTER_POS($fp)  ## t1 = sent;
    subu t2, t1, t0  # t2 = sent - *pos
    bgez t2, afterWhile  # if (sent - *pos >= 0) sale del while

    ## Aca llamo al SYSCALL del write
    li v0, SYS_write
    lw a0, FD_POS($fp)  # Redundante pero provisorio
    lw a1, BUFFER_POS($fp)  # Redundante pero provisorio
    lw t1, WHILE_COUNTER_POS($fp)  ## t1 = sent;
    addu a1, a1, t1  # buffer+sent
    dereferencePosTot0  # t0 = *pos
    move a2, t0  # a2 = *pos
    lw t1, WHILE_COUNTER_POS($fp)  ## t1 = sent;
    subu a2, a2, t1  ##  a2 = *pos - sent
    SYSCALL
    ##--------------------------------------------------------------------------
    ## VERIFICACION DE ERRORES DE WRITE
    ##--------------------------------------------------------------------------
    bne a3, zero, ERROR  # si a3 != 0 retorna error

    ## write retorna su valor en el registro v0. Entonces si v0 es -1 quiere
    ## decir que hubo un error.
    li t3, -1  # t3 = -1
    beq v0, t3, ERROR  # si vo == -1 retorna error

    ## Actualizo la posicion del buffer para que pueda seguir escribiendo sobre
    ## el en la parte restante
    lw t1, WHILE_COUNTER_POS($fp)  ## t1 = sent;
    addu t1, t1, v0
    sw t1, WHILE_COUNTER_POS($fp)  ##  #  sent += bytesSent;
    ##--------------------------------------------------------------------------
    ## FIN VERIFICACION DE ERRORES DE WRITE
    ##--------------------------------------------------------------------------
    j while

afterWhile:
    ## Aca desreferencio pos, y le guardo cero, y luego hago que la posicion
    ## de memoria de pos a apunte a ese nuevo valor
    ## *pos = 0
    li t0, 0  # t0 = 0
    lw a3, POSITION_POS($fp)  # a3 = &pos;
    sw t0, 0(a3)  # *pos = 0
    j writeValue

ERROR:
    li v0, -1  # Guardo en v0 el valor -1 que representa error
    j return
##------------------------------------------------------------------------------
