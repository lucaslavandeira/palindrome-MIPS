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
## MACROS DEFINITIONS
##------------------------------------------------------------------------------
##------------------------------------------------------------------------------
## CODIGO EQUIVALENTE EN C
##------------------------------------------------------------------------------
## Del 97 al 122 estan las letras de a-z
## Del 65 al 90 estan las letras de A-Z
## Del 48 al 57 estan los numeros de 0-9
## '-' es 45
## '_' es 95
##bool belongsToSpace(char c) {
    ## if (c >= 97 && c <= 122) return true;
    ## if (c >= 65 && c <= 90) return true;
    ## if (c >= 48 && c <= 57) return true;
    ## if (c == 45 || c == 95) return true;
    ## return false;
##}
##------------------------------------------------------------------------------
## CODIGO EN MIPS
##------------------------------------------------------------------------------
text
    .abicalls
    .align 2
    .globl belongsToSpace
    .ent belongsToSpace
belongsToSpace:
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
    ## if (c >= 97 && c <= 122) return true;
    lw a0, CARACTER_POS($fp)  ## a0 = c
    li t0, 97
    subu t0, a0, t0  ## t0 = c - 97
    bltz t0, uppercaseIf  ## if (c - 97 < 0) sale del if
    li t0, 122
    subu t0, a0, t0  ## t0 = c - 122
    bgtz t0, uppercaseIf  ## if (c - 122 > 0) sale del if
    li v0, 1  ## return true
    j return
uppercaseIf:
    ## if (c >= 65 && c <= 90) return true;
    lw a0, CARACTER_POS($fp)  ## a0 = c
    li t0, 65
    subu t0, a0, t0  ## t0 = c - 65
    bltz t0, numbersIf  ## if (c - 65 < 0) sale del if
    li t0, 90
    subu t0, a0, t0  ## t0 = c - 65
    bgtz t0, numbersIf  ## if (c - 65 > 0) sale del if
    li v0, 1  ## return true
    j return
numbersIf:
    ## if (c >= 48 && c <= 57) return true;
    lw a0, CARACTER_POS($fp)  ## a0 = c
    li t0, 48
    subu t0, a0, t0  ## t0 = c - 48
    bltz t0, scriptIf  ## if (c - 48 < 0) sale del if
    li t0, 57
    subu t0, a0, t0  ## t0 = c - 57
    bgtz t0, scriptIf  ## if (c - 57 > 0) sale del if
    li v0, 1  ## return true
    j return
scriptIf:
    ## if (c == 45 || c == 95) return true
    lw a0, CARACTER_POS($fp)  ## a0 = c
    li t0, 45
    beq a0, t0, returnTrue  ## if (c == 45)
    li t0, 95
    beq a0, t0, returnTrue  ## if (c == 95)

    ## return false
    li v0, 0  ## False = 0
    j return

returnTrue:
     li v0, 1  ## True = 1
##------------------------------------------------------------------------------
## RETURN
##------------------------------------------------------------------------------
return:
    lw gp, GP_POS(sp)
    lw $fp, FP_POS(sp)
    lw ra, RA_POS(sp)
    addu sp, sp, SF_SIZE
    jr ra
    .end belongsToSpace
    .size belongsToSpace,.-belongsToSpace
##------------------------------------------------------------------------------
