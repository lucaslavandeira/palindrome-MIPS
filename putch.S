#include <sys/syscall.h>
#include <mips/regdef.h>
#-------------------------------------------------------------------------------
# DEFINITIONS
#-------------------------------------------------------------------------------
#ifndef STACK_FRAME_SIZE
#define STACK_FRAME_SIZE 48
#endif

#ifndef RETURN_POINTER_POS
#define RETURN_POINTER_POS STACK_FRAME_SIZE-8
#endif

#ifndef GLOBAL_POINTER_POS
#define GLOBAL_POINTER_POS RETURN_POINTER_POS-4
#endif

#ifndef FRAME_POINTER_POS
#define FRAME_POINTER_POS FRAME_POINTER_POS-4
#endif

#ifndef FD_POS
#define FD_POS STACK_FRAME_SIZE
#endif

#ifndef BUFFER_POS
#define BUFFER_POS STACK_FRAME_SIZE+4
#endif

#ifndef IBYTES_POS
#define IBYTES STACK_FRAME_SIZE+8
#endif

#ifndef POSITION_POS
#define POSITION_POS STACK_FRAME_SIZE+12
#endif

#ifndef CHAR_POS
#define CHAR_POS STACK_FRAME_SIZE+16
#endif

#ifndef EOF
#define EOF -1
#endif
#-------------------------------------------------------------------------------
# CODIGO EQUIVALENTE EN C
#-------------------------------------------------------------------------------
#int putch(int fd, char* buffer, size_t oBytes, size_t* pos, char c) {
    #if (*pos == oBytes || c == EOF) {
        #*pos = 0
        int sent = 0, bytesSent;
        #while (sent < oBytes) {
            #bytesSent = write(fd, buffer+sent, oBytes-sent);
            #if (bytesSent == -1) return -1;
            #sent += bytesSent;
        #}
    #}
    #buffer[*pos] = c;
    #*pos++;
    #return sent;
#}
#-------------------------------------------------------------------------------
# CODIGO EN MIPS
#-------------------------------------------------------------------------------
    .text
    .abicalls
    .align 2
    .globl putch
    .ent putch
putch:
    #---------------------------------------------------------------------------
    # Inicializacion del stack frame
    #---------------------------------------------------------------------------
    frame $fp, 10, ra
    .set	noreorder
    .cpload t9
    .set	reorder
    subu sp, sp, STACK_FRAME_SIZE
    .cprestore GLOBAL_POINTER_POS
    sw $fp, FRAME_POINTER_POS(sp)
    sw ra, RETURN_POINTER_POS(sp)
    move $fp, sp
    sw a0, FD_POS($fp)  # file descriptor
    sw a1, BUFFER_POS($fp)  # buffer
    sw a2, IBYTES_POS($fp)  # capacidad maxima del buffer
    sw a3, POSITION_POS($fp)  # position actual de escritura del buffer
    sw a4, CHAR_POS($fp)  # caracter a escribir
    #---------------------------------------------------------------------------
    # Fin de la inicializacion del stack frame
    #---------------------------------------------------------------------------
    #if (*pos == oBytes || c == EOF)

    lw a3, POSITION_POS($fp)  # Redundante pero provisorio
    la t0, a3 # cargo el valor de la direccion de memoria de la posicion en t0
    lw t0, 0(t0) # desreferencio el puntero y guardo el valor en t0
    # t0 = *pos
    lw a2, IBYTES_POS($fp)  # Redundante pero provisorio
    # a2 = oBytes
    beq a2, t0, readFile  # if (*pos == iBytes) writeFile
    beq t0, ZERO, readFile  # if (*pos == 0) writeFile
#-------------------------------------------------------------------------------
# WRITE VALUE
#-------------------------------------------------------------------------------
writeValue:
    lw a3, POSITION_POS($fp)  # Redundante pero provisorio
    la t0, a3 # cargo el valor de la direccion de memoria de la 'pos' en t0
    lw t0, 0(t0) # desreferencio el puntero y guardo el valor en t0
    # t0 = *pos

    # buffer[+pos];
    lw a1, BUFFER_POS($fp)  # Redundante pero provisorio a1 = buffer
    addu a1, a1, t0  # cargo en a1 la dir de mem de lo ocupado en Buffer[pos]
    # a1 = buffer + pos
    lw a4, CHAR_POS($fp)  # Redundante pero provisorio a4 = c
    sb a4, 0(a1)  # Escribo en buffer[pos] el caracter recibido buffer[pos] = c

    # *pos++;
    lw a3, POSITION_POS($fp)  # Redundante pero provisorio
    la t0, a3 # cargo el valor de la direccion de memoria de 'pos' en t0
    lw t0, 0(t0) # desreferencio el puntero y guardo el valor en t0
    addu t0, t0, 1  # incremento el valor de la posicion
    sw t0, 0(a3)  # guardo el incremento en la direccion de memoria de 'pos'

    li v0, ZERO  # return 0
#-------------------------------------------------------------------------------
# RETURN
#-------------------------------------------------------------------------------
return:
    lw gp, GLOBAL_POINTER_POS(sp)
    lw $fp, FRAME_POINTER_POS(sp)
    lw ra, RETURN_POINTER_POS(sp)
    addu sp, sp, STACK_FRAME_SIZE
    jr ra
    .end putch
    .size putch,.-putch
#-------------------------------------------------------------------------------
# WRITE FILE
#-------------------------------------------------------------------------------
writeFile:
    # Aca desreferencio pos, y le guardo cero, y luego hago que la posicion
    # de memoria de pos a apunte a ese nuevo valor
    #---------------------------------------------------------------------------
    # *pos = 0
    lw a3, POSITION_POS($fp)  # Redundante pero provisorio
    la t0, a3 # cargo el valor de la direccion de memoria de 'pos' en t0
    lw t0, 0(t0) # desreferencio el puntero y guardo el valor en t0
    addu t0, ZERO, 0  # le guardo el valor 0  a 'pos'
    sw t0, 0(a3)  # guardo el nuevo valor en la direccion de memoria de 'pos'
    # *pos = 0
    #---------------------------------------------------------------------------
    li t1, ZERO  # int sent = 0
    lw a2, IBYTES_POS($fp)  # Redundante pero provisorio  a2 = oBytes
while:
    # Aca pregunto si la condicion del while es falsa. De serlo sigo
    # con la parte de escribir el siguiente caracter del buffer, es decir,
    #con la parte del codigo llamada writeValue
    # t1 = sent;   a2 = oBytes
    subu t2, t1, a2  # t2 = sent - oBytes
    bgez t2, findValue  # if (received >= iBytes) sale del while

    # Aca llamo al SYSCALL del write
    li v0, SYS_write
    lw a0, FD_POS($fp)  # Redundante pero provisorio
    lw a1, BUFFER_POS($fp)  # Redundante pero provisorio
    addu a1, a1, t1  # buffer+sent
    lw a2, IBYTES_POS($fp)  # Redundante pero provisorio
    SYSCALL
    #---------------------------------------------------------------------------
    # VERIFICACION DE ERRORES DE WRITE
    #---------------------------------------------------------------------------
    bne a3, ZERO, ERROR  # si a3 !=0 retorna error

    # write retorna su valor en el registro v0. Entonces si v0 es -1 quiere
    # decir que hubo un error.
    adu t3, ZERO, -1  # t3 = -1
    beq v0, t3, ERROR  # si vo == -1 retorna error

    # Actualizo la posicion del buffer para que pueda seguir escribiendo sobre
    # el en la parte restante
    addu t1, t1, v0  #  sent += bytesSent;
    #---------------------------------------------------------------------------
    # FIN VERIFICACION DE ERRORES DE WRITE
    #---------------------------------------------------------------------------
    j while
ERROR:
    addu v0, ZERO, -1  # Guardo en v0 el valor -1 que representa error
    j return
#-------------------------------------------------------------------------------