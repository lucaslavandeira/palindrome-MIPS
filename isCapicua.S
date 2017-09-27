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

#ifndef BUFFER_POS
#define BUFFER_POS 40
#endif

#ifndef LEN_POS
#define LEN_POS 44
#endif
##------------------------------------------------------------------------------
## MACROS
##------------------------------------------------------------------------------
##------------------------------------------------------------------------------
## CODIGO EQUIVALENTE EN C
##------------------------------------------------------------------------------
## Del 97 al 122 estan las letras de a-z
## Del 65 al 90 estan las letras de A-Z
## Del 48 al 57 estan los numeros de 0-9
## '-' es 45
## '_' es 95
##int stdinCapicua(const char* word, size_t len) {
    ## for (int i = 0; i < len; i++) {
        ##if (tolower(word[i) != tolower(word[len - i - 1])) {
                ##return false;
        ##}
    ##}
    ##return true;
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
    sw a0, BUFFER_POS($fp)
    sw a1, LEN_POS($fp)
    ##--------------------------------------------------------------------------
    ## FIN INICIALIZACION DEL STACK FRAME
    ##--------------------------------------------------------------------------
    li t0, zero  ## int i = 0
    lw a0, BUFFER_POS($fp)
    lw a1, LEN_POS($fp)
    ## for (int i = 0; i < len; i++)
for:
    subu t3, t0, a1  ## t3 = i - len
    bgez t3, returnTrue  ## if i >= len termino el for

    ##if (tolower(word[i]) != tolower(word[len-i-1])) return false
    ## if (c >= 65 && c <= 90) return true;
    
    addu t1, a0, t0  ##  t1 = buffer + i
    lw t1, 0(t1)  ## t1 = *(buffer + i)

    subu t2, a1, t0  ##  t2 = len -i
    subu t2, t2, 1  ##  t2 = len - i - 1
    addu t2, a0, t2  ##  t2 = buffer + len - i - 1
    lw t2, 0(t2)  ## t2 = *(buffer + len - i - 1)
    bne t1, t2, returnFalse

    addu t0, t0, 1  ## i++
    j for
returnTrue:
     li v0, 1  ## True = 1
     j return
returnFalse:
     li v0, 0  ## False = 0
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
