#include <mips/regdef.h>
#include <sys/syscall.h>
##------------------------------------------------------------------------------
## DEFINITIONS
##------------------------------------------------------------------------------
#ifndef STACK_FRAME_SIZE
#define STACK_FRAME_SIZE 68
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

#ifndef FD_POS
#define FD_POS 48
#endif

#ifndef BUFFER_POS
#define BUFFER_POS 52
#endif

#ifndef IBYTES_POS
#define IBYTES_POS 56
#endif

#ifndef POSITION_POS
#define POSITION_POS 60
#endif

#ifndef ERROR_VALUE
#define ERROR_VALUE -2
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
##int getch(int fd, char* buffer, size_t iBytes, ssize_t* pos) {
    ##if ((*pos == iBytes || *pos == 0)) {
        ##*pos = 0
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
    ##*pos++;
    ##return c;
##}
##------------------------------------------------------------------------------
    .text
    .abicalls
    .align 2
    .globl getch
    .ent getch
getch:
    ##--------------------------------------------------------------------------
    ## Inicializacion del stack frame
    ##--------------------------------------------------------------------------
    .frame $fp, STACK_FRAME_SIZE, ra
    .set	noreorder
    .cpload t9
    .set	reorder
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
    ## Fin de la inicializacion del stack frame
    ##--------------------------------------------------------------------------

    ## verifico si el buffer esta vacio a ya lo lei todo
    ## if (*pos == iBytes || *pos == 0)
    dereferencePosTot0  # t0 = *pos
    lw a2, IBYTES_POS($fp)  # Redundante pero provisorio
    ## t0 = *pos;
    ## a2 = iBytes;
    beq a2, t0, readFile  # if (*pos == iBytes) readFile
    beq t0, zero, readFile  # if (*pos == 0) readFile

findValue:
    dereferencePosTot0  # t0 = *pos
    ## int c = buffer[+pos];
    lw a1, BUFFER_POS($fp)  # Redundante pero provisorio
    addu a1, a1, t0  # a1 = Buffer+pos
    lb v0, 0(a1)  # v0 = *(Buffer+pos)

    ## *pos++;
    dereferencePosTot0  # t0 = *pos
    addu t0, t0, 1  # incremento el valor de la posicion
    sw t0, 0(a3)  # guardo el incremento en la direccion de memoria de 'pos'

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
    dereferencePosTot0  # t0 = *pos
    addu t0, zero, 0  # le guardo el valor 0  a 'pos'
    sw t0, 0(a3)  # guardo el nuevo valor en la direccion de memoria de 'pos'
    ## *pos = 0
    ##--------------------------------------------------------------------------
    li t1, 0  # int received = 0 , t1 = received
    lw a2, IBYTES_POS($fp)  # Redundante pero provisorio
    li v0, -1  ## bytesRead = -1
while:
    ## while (received < iBytes && bytesRead != 0)
    ## Como el while contiene un 'and' si alguno es falso sale de la condicion

    ## Aca pregunto si la primera condicion del while es falsa. De serlo sigo
    ## con la parte de leer el siguiente caracter del buffer, es decir, con la
    ## parte del codigo llamada findValue
    subu t2, t1,  a2  # t2 = received - iBytes
    bgez t2, findValue  # if (received >= iBytes) sale del while

    ## Aca pregunto si la segunda condicion del while es falsa. De serlo sigo
    ## con la parte de leer el siguiente caracter del buffer, es decir, con la
    ## parte del codigo llamada findValue
    beq v0, zero, findValue  # if (bytesRead == 0) sale del while

    ## Aca llamo al SYSCALL del read
    li v0, SYS_read
    lw a0, FD_POS($fp)  # Redundante pero provisorio
    lw a1, BUFFER_POS($fp)  # Redundante pero provisorio
    addu a1, a1, t1  # buffer+received
    lw a2, IBYTES_POS($fp)  # Redundante pero provisorio
    subu a2, a2, t1  ## iBytes-received
    SYSCALL
    ##--------------------------------------------------------------------------
    ## VERIFICACION DE ERRORES DE READ
    ##--------------------------------------------------------------------------
    bne a3, zero, ERROR  # si a3 !=0 retorna error

    ## read retorna su valor en el registro v0. Entonces si v0 es -1 quiere
    ## decir que hubo un error.
    addu t3, zero, -1  # Guardo -1 en t3
    beq v0, t3, ERROR  # si vo == -1 retorna error

    ## read retorna su valor en el registro v0. Entonces si v0 es 0 quiere
    ## decir que detecto el EOF
    ##if (bytesRead == 0) buffer[received] = EOF;
    beq v0, zero, END_READING

    ## Actualizo la posicion del buffer para que pueda seguir leyendo sobre
    ## el en la parte restante
    addu t1, t1, v0  #  received += bytesRead;
    ##--------------------------------------------------------------------------
    ## FIN VERIFICACION DE ERRORES DE READ
    ##--------------------------------------------------------------------------
    j while

END_READING:  ## buffer[received] = EOF; - t1 = received
    lw a1, BUFFER_POS($fp)  # Redundante pero provisorio
    addu a1, a1, t1  ## a1 = buffer+received
    ## t0 = *(buffer+received)
    lw t0, 0(a1)  ## desreferencio el puntero y guardo el valor en t0
    addu t0, zero, EOF
    sw t0, 0(a1)  ## buffer[received] = EOF;
    addu t1, t1, v0  #  received += bytesRead;
    j findValue  # salto a buscar el siguiente caracter
ERROR:
    addu v0, zero, ERROR_VALUE  # Guardo en v0 el valor ERROR_VALUE
    j return
##------------------------------------------------------------------------------
