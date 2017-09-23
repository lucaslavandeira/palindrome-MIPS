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
#-------------------------------------------------------------------------------
# CODIGO EQUIVALENTE EN C
#-------------------------------------------------------------------------------
#int getch(int fd, char* buffer, size_t iBytes, size_t* pos) {
    #if (*pos == iBytes || *pos == 0 || pos != -1) {
        #*pos = 0
        int received = 0, bytesRead;
        #while (received < iBytes && pos != -1) {
            #bytesRead = read(fd, buffer+received, iBytes-received);
            #if (bytesRead == -1) return -1;
            #if (bytesRead == 0) *pos = -1;
            #received += bytesRead;
        #}
    #}
    #int c = buffer[*pos];
    #*pos++;
    #return c;
#}
#-------------------------------------------------------------------------------
    .text
    .abicalls
    .align 2
    .globl getch
    .ent getch
getch:
    # Inicializacion del stack frame
    frame $fp, STACK_FRAME_SIZE, ra
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
    # Fin de la inicializacion del stack frame

    # verifico si el buffer esta vacio a ya lo lei todo
    lw a3, POSITION_POS($fp)  # Redundante pero provisorio
    la t0, a3 # cargo el valor de la direccion de memoria de la posicion en t0
    lw t0, 0(t0) # desreferencio el puntero y guardo el valor en t0
    lw a2, IBYTES_POS($fp)  # Redundante pero provisorio
    beq a2, t0, readFile  # if (*pos == iBytes) readFile
    beq a2, ZERO, readFile  # if (*pos == 0) readFile
    addu t0, ZERO, -1;  # Guardo -1 en t0
    bne a2, t0, readFile # if (*pos != -1)

findValue:

    lw a3, POSITION_POS($fp)  # Redundante pero provisorio
    la t0, a3 # cargo el valor de la direccion de memoria de la 'pos' en t0
    lw t0, 0(t0) # desreferencio el puntero y guardo el valor en t0

    # int c = buffer[+pos];
    lw a1, BUFFER_POS($fp)  # Redundante pero provisorio
    addu a1, a1, t0  # cargo en a1 la dir de mem de lo ocupado en Buffer[pos]
    lb v0, 0(a1)  # guardo en vo lo que esta guardado en buffer[pos]

    # *pos++;
    lw a3, POSITION_POS($fp)  # Redundante pero provisorio
    la t0, a3 # cargo el valor de la direccion de memoria de 'pos' en t0
    lw t0, 0(t0) # desreferencio el puntero y guardo el valor en t0
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
    li t1, ZERO  # int received = 0
    lw a2, IBYTES_POS($fp)  # Redundante pero provisorio
while:
    # Como el while contiene un 'and' si alguno es falso sale de la condicion

    # Aca pregunto si la primera condicion del while es falsa. De serlo sigo
    # con la parte de leer el siguiente caracter del buffer, es decir, con la
    # parte del codigo llamada findValue
    subu t2, t1,  a2  # t2 = received - iBytes
    bgez t2, findValue  # if (received >= iBytes) sale del while


    # Aca pregunto si la segunda condicion del while es falsa. De serlo sigo
    # con la parte de leer el siguiente caracter del buffer, es decir, con la
    # parte del codigo llamada findValue
    lw a3, POSITION_POS($fp)  # Redundante pero provisorio
    la t0, a3 # cargo el valor de la direccion de memoria de 'pos' en t0
    lw t0, 0(t0) # desreferencio el puntero y guardo el valor en t0
    adu t3, ZERO, -1  # Guardo -1 en t3
    beq t0, t3, findValue  # if (*pos == 1) sale del while

    # Aca llamo al SYSCALL del write
    li v0, SYS_read
    lw a0, FD_POS($fp)  # Redundante pero provisorio
    li, a0, a0
    lw a1, BUFFER_POS($fp)  # Redundante pero provisorio
    addu a1, a1, t1  # buffer+received
    la a1, a1
    lw a2, IBYTES_POS($fp)  # Redundante pero provisorio
    li a2, a2
    SYSCALL
    # Verificacion de errores

    bne a3, ZERO, ERROR  # si a3 !=0 retorna error

    # write retorna su valor en el registro v0. Entonces si v0 es -1 quiere
    # decir que hubo un error.
    adu t3, ZERO, -1  # Guardo -1 en t3
    beq v0, t3, ERROR  # si vo == -1 retorna error


    # write retorna su valor en el registro v0. Entonces si v0 es 0 quiere
    # decir que detecto el EOF
    lw a2, IBYTES_POS($fp)  # Redundante pero provisorio
    beq v0, ZERO, END_READING

    # Actualizo la posicion del buffer para que pueda seguir escribiendo sobre
    # el en la parte restante
    addu t1, t1, v0  #  received += bytesRead;
    j while

END_READING:  # *pos = -1
    # Aca hago que la variable pos valga -1ya que significa que no debo ler mas
    # porque lo mas probable es que haya pedido iBytes al sistema operativo
    # y me haya delvuelto menos porque llego al EOF. Es decir solo restaban
    # leer menos que iBytes del archivo de entrada y entonces el loop no va a
    # buclear hasta recorrer iBytes sino que detecto el EOF y el buffer no
    # va a estar lleno

    lw a3, POSITION_POS($fp)  # Redundante pero provisorio
    la t0, a3 # cargo el valor de la direccion de memoria de 'pos' en t0
    lw t0, 0(t0) # desreferencio el puntero y guardo el valor en t0
    addu to, ZERO, -1  # *pos = -1 significa no leer mas
    sw t0, 0(a3)  # guardo el nuevo valor en la direccion de memoria de 'pos'
    j findValue  # salto a buscar el siguiente caracter
ERROR:
    addu v0, ZERO, -1  # Guardo en v0 el valor -1 que representa error
    j return
#-------------------------------------------------------------------------------