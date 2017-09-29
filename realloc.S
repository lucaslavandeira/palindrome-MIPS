#include <sys/syscall.h>
#include <mips/regdef.h>
##------------------------------------------------------------------------------
## DEFINITIONS
##------------------------------------------------------------------------------
#ifndef SF_SIZE
#define SF_SIZE 48
#endif

#ifndef RA_POS
#define RA_POS 40
#endif

#ifndef GP_POS
#define GP_POS 36
#endif

#ifndef FP_POS
#define FP_POS 32
#endif

#ifndef POINTER_POS
#define POINTER_POS 20
#endif

#ifndef NEW_SIZE_POS
#define NEW_SIZE_POS 24
#endif

#ifndef NEW_POINTER_POS
#define NEW_POINTER_POS 28
#endif
##------------------------------------------------------------------------------
## CODIGO EQUIVALENTE EN C
##------------------------------------------------------------------------------
##void* realloc(void* pointer, size_t newSize) {
    ##void* aux = malloc(newSize);
    ##if (aux == null) return null;
    ##*aux = *pointer;
    ##free(pointer);
    ##return aux;
##}
##------------------------------------------------------------------------------
## CODIGO EN MIPS
##------------------------------------------------------------------------------
    .text
    .abicalls
    .align 2
    .globl realloc
    .ent realloc
realloc:
    ##--------------------------------------------------------------------------
    ## INICIALIZACION DEL STACK FRAME
    ##--------------------------------------------------------------------------
    .frame $fp, SF_SIZE, ra
    .set noreorder
    .cpload t9
    .set reorder
    subu sp, sp, SF_SIZE
    .cprestore GP_POS
    sw $fp, FP_POS(sp)
    sw ra, RA_POS(sp)
    move $fp, sp
    sw a0, POINTER_POS($fp)  ## salvo el puntero a realocalizar
    sw a1, NEW_SIZE_POS($fp)  ## salvo el nuevo tamaño
    ##--------------------------------------------------------------------------
    ## FIN INICIALIZACION DEL STACK FRAME
    ##--------------------------------------------------------------------------
    lw a0, NEW_SIZE_POS($fp)  ## a1 = newSize
    la t9, mymalloc
    jal ra, t9
    li t0, -1
    beq v0, t0, return
    sw v0, NEW_POINTER_POS($fp)  ## salvo el nuevo espacio reservado
    lw t0, NEW_POINTER_POS($fp)  ## t0 = aux;
    lw t1, POINTER_POS($fp)  ## t1 = pointer;
    lw t1, 0(t1)  ## t1 = *pointer;
    sw t1, 0(t0)  ## *aux = *pointer;
    sw t0, NEW_POINTER_POS($fp)  ## salvo el espacio ya reasignado.
    la t9, myfree
    jal ra, t9
    lw v0, NEW_POINTER_POS($fp)  ## return aux; v0 = aux;
##------------------------------------------------------------------------------
## RETURN
##------------------------------------------------------------------------------
return:
    lw gp, GP_POS(sp)
    lw $fp, FP_POS(sp)
    lw ra, RA_POS(sp)
    addu sp, sp, SF_SIZE
    jr ra
    .end realloc
    .size realloc,.-realloc
##------------------------------------------------------------------------------
