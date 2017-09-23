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

#ifndef A0_AUX_POS
#define A0_AUX_POS STACK_FRAME_SIZE-24
#endif

#ifndef A1_AUX_POS
#define A1_AUX_POS A0_AUX_POS+4
#endif

#ifndef A2_AUX_POS
#define A2_AUX_POS A1_AUX_POS+4
#endif

#ifndef A3_AUX_POS
#define A3_AUX_POS A2_AUX_POS+4
#endif
#-------------------------------------------------------------------------------
    .text
    .abicalls
    .align 2
    .globl getch
    .ent getch

#int getch(int fd, char* buffer, size_t iBytes, size_t* pos) {
    #if (*pos == iBytes || pos == 0 || pos != -1) {
        #*pos = 0
        #int bytesRead = write(fd, buffer, iBytes);
        #if (bytesRead == -1) return -1;
        #if (bytesRead != iBytes) *pos = -1;
    #}
    #int c = buffer[*pos];
    #*pos++;
    #return c;
#}

getch:
    # Inicializacion del stack frame
    frame $fp, 10, ra
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
    # Redundante

    sll to, to, 2  # multiplico por 4 la posicion
    lw a1, BUFFER_POS($fp)  # Redundante pero provisorio
    addu a1, a1, to  # cargo en a1 la dir de mem de lo ocupado en Buffer[pos]
    lw v0, 0(a1)  # guardo en vo lo que esta guardado en buffer[pos]

    lw a3, POSITION_POS($fp)  # Redundante pero provisorio
    la t0, a3 # cargo el valor de la direccion de memoria de 'pos' en t0
    lw t0, 0(t0) # desreferencio el puntero y guardo el valor en t0
    addu to, to, 1  # incremento el valor de la posicion
    sw t0, 0(a3)  # guardo el incremento en la direccion de memoria de 'pos'

return:
    lw gp, GLOBAL_POINTER_POS(sp)
    lw $fp, FRAME_POINTER_POS(sp)
    lw ra, RETURN_POINTER_POS(sp)
    addu sp, sp, STACK_FRAME_SIZE
    jr ra

readFile:
    #---------------------------------------------------------------------------
    # *pos = 0
    lw a3, POSITION_POS($fp)  # Redundante pero provisorio
    la t0, a3 # cargo el valor de la direccion de memoria de 'pos' en t0
    lw t0, 0(t0) # desreferencio el puntero y guardo el valor en t0
    addu t0, ZERO, 0  # le guardo el valor 0  a 'pos'
    sw t0, 0(a3)  # guardo el nuevo valor en la direccion de memoria de 'pos'
    # *pos = 0
    #---------------------------------------------------------------------------
    li v0, SYS_read
    lw a0, FD_POS($fp)  # Redundante pero provisorio
    li, a0, a0
    lw a1, BUFFER_POS($fp)  # Redundante pero provisorio
    la a1, a1
    lw a2, IBYTES_POS($fp)  # Redundante pero provisorio
    li a2, a2
    SYSCALL
    bne a3, ZERO, ERROR  # si a3 !=0 sretorna error
    lw a2, IBYTES_POS($fp)  # Redundante pero provisorio
    bne v0, a2, END_READING
    j findValue  # salto a buscar el siguiente caracter

END_READING:
    lw a3, POSITION_POS($fp)  # Redundante pero provisorio
    la t0, a3 # cargo el valor de la direccion de memoria de 'pos' en t0
    lw t0, 0(t0) # desreferencio el puntero y guardo el valor en t0
    addu to, ZERO, -1  # pos = -1 significa no leer mas
    sw t0, 0(a3)  # guardo el nuevo valor en la direccion de memoria de 'pos'
    j findValue  # salto a buscar el siguiente caracter
ERROR:
    addu v0, ZERO, -1  # Guardo en v0 el valor -1 que representa error
    j return
    .end getch