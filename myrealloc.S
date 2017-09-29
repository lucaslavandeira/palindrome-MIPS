#include <sys/syscall.h>
#include <mips/regdef.h>
##------------------------------------------------------------------------------
## DEFINITIONS
##------------------------------------------------------------------------------
#ifndef SF_SIZE
#define SF_SIZE 48
#endif

#ifndef RA_POS
#define RA_POS 44
#endif

#ifndef GP_POS
#define GP_POS 40
#endif

#ifndef FP_POS
#define FP_POS 36
#endif

#ifndef FOR_COUNTER_POS
#define FOR_COUNTER_POS 20
#endif

#ifndef POINTER_POS
#define POINTER_POS 24
#endif

#ifndef NEW_SIZE_POS
#define NEW_SIZE_POS 28
#endif

#ifndef NEW_POINTER_POS
#define NEW_POINTER_POS 32
#endif
##------------------------------------------------------------------------------
## CODIGO EQUIVALENTE EN C
##------------------------------------------------------------------------------
##void* realloc(void* pointer, size_t newSize) {
    ## char* aux = (char*) mymalloc(newSize);
    ## if (aux == null) return null;
    ## for (size_t i = 0; i < newSize; i++) aux[i] = ((char*) pointer)[i];
    ## free(pointer);
    ## return (char*) aux;
##}
##------------------------------------------------------------------------------
## CODIGO EN MIPS
##------------------------------------------------------------------------------
    .text
    .abicalls
    .align 2
    .globl myrealloc
    .ent myrealloc
myrealloc:
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
    lw a0, NEW_SIZE_POS($fp)  ## a0 = newSize
    la t9, mymalloc
    jal ra, t9
    li t0, -1
    beq v0, t0, return
    sw v0, NEW_POINTER_POS($fp)  ## salvo el nuevo espacio reservado
    li t0, 0  ## i = 0;
    sw t0, FOR_COUNTER_POS($fp)  ## salvo el contador del for
for:
    lw t1, NEW_SIZE_POS($fp)  ## t1 = newSize
    lw t0, FOR_COUNTER_POS($fp)  ## t0 = i
    subu t1, t0, t1  ## t1 = i - newSize
    bgez t1, continue  ## if (i >= newSize) sale del for

    lw t0, FOR_COUNTER_POS($fp)  ## t0 = i
    lw t1, NEW_POINTER_POS($fp)  ## t1 = aux;
    lw t2, POINTER_POS($fp)  ## t2 = pointer;
    addu t1, t1, t0  ## t1 = aux + i
    addu t2, t2, t0  ## t2 = pointer + i
    lb t2, 0(t2)  ## t2 = *(pointer + i)
    sb t2, 0(t1)  ## *(aux + i) = *(pointer + i)

    lw t0, FOR_COUNTER_POS($fp)  ## t0 = i
    addu t0, t0, 1
    sw t0, FOR_COUNTER_POS($fp)  ## salvo el contador del for
    j for

continue:
    lw a0, POINTER_POS($fp) ## free(pointer);
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
    .end myrealloc
    .size myrealloc,.-myrealloc
##------------------------------------------------------------------------------
