#include <sys/syscall.h>
#include <mips/regdef.h>
##------------------------------------------------------------------------------
## DEFINITIONS
##------------------------------------------------------------------------------
#ifndef SF_SIZE
#define SF_SIZE 40
#endif

#ifndef RA_POS
#define RA_POS 32
#endif

#ifndef GP_POS
#define GP_POS 28
#endif

#ifndef FP_POS
#define FP_POS 24
#endif

#ifndef CARACTER_POS
#define CARACTER_POS 40
#endif
##------------------------------------------------------------------------------
## CODIGO EQUIVALENTE EN C
##------------------------------------------------------------------------------
## Del 97 al 122 estan las letras de a-z
## Del 65 al 90 estan las letras de A-Z
## Del 48 al 57 estan los numeros de 0-9
## '-' es 45
## '_' es 95
##char tolower(char c) {
    ## if (c >= 65 && c <= 90) {
        ## return c + 32;
    ##}
    ##return c;
##}
##------------------------------------------------------------------------------
## CODIGO EN MIPS
##------------------------------------------------------------------------------
    .text
    .abicalls
    .align 2
    .globl tolower
    .ent tolower
tolower:
    ##--------------------------------------------------------------------------
    ## FIN INICIALIZACION DEL STACK FRAME
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
    sw a0, CARACTER_POS($fp)
    ##--------------------------------------------------------------------------
    ## FIN INICIALIZACION DEL STACK FRAME
    ##--------------------------------------------------------------------------
    sw a0, CARACTER_POS($fp)  ## a0 = c
    ## if (c >= 65 && c <= 90) return c + 32
    li t0, 65
    subu t0, a0, t0  ## t0 = c - 65
    bltz t0, returnC  ## if (c - 65 < 0) sale del if
    li t0, 90
    subu t0, a0, t0  ## t0 = c - 90
    bgtz t0, returnC  ## if (c - 90 > 0) sale del if
    addu v0, a0, 32
    j return
returnC:
    move v0, a0
    j return
##------------------------------------------------------------------------------
## RETURN
##------------------------------------------------------------------------------
return:
    lw gp, GP_POS(sp)
    lw $fp, FP_POS(sp)
    lw ra, RA_POS(sp)
    addu sp, sp, SF_SIZE
    jr ra
    .end tolower
    .size tolower,.-tolower
##------------------------------------------------------------------------------
