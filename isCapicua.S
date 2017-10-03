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

#ifndef BUFFER_POS
#define BUFFER_POS 48
#endif

#ifndef LEN_POS
#define LEN_POS 52
#endif

#ifndef FOR_COUNTER_POS
#define FOR_COUNTER_POS 28
#endif

#ifndef FIRST_CARACTER_POS
#define FIRST_CARACTER_POS 24
#endif

#ifndef LAST_CARACTER_POS
#define LAST_CARACTER_POS 20
#endif
##------------------------------------------------------------------------------
## CODIGO EQUIVALENTE EN C
##------------------------------------------------------------------------------
## Del 97 al 122 estan las letras de a-z
## Del 65 al 90 estan las letras de A-Z
## Del 48 al 57 estan los numeros de 0-9
## '-' es 45
## '_' es 95
##bool isCapicua(const char* word, size_t len) {
    ## if (len == 0) return false;
    ## for (int i = 0; i < len; i++) {
        ##if (mytolower(word[i]) != mytolower(word[len - i - 1])) return false;
    ##}
    ##return true;
##}
##------------------------------------------------------------------------------
## CODIGO EN MIPS
##------------------------------------------------------------------------------
    .text
    .abicalls
    .align 2
    .globl isCapicua
    .ent isCapicua
isCapicua:
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
    lw a1, LEN_POS($fp)
    beq a1, zero, returnFalse  ## if (len == 0) return false;

    li t0, 0  ## int i = 0
    sw t0, FOR_COUNTER_POS($fp)  ## salvo el contador del for en la stackFrame
    lw a0, BUFFER_POS($fp)
    lw a1, LEN_POS($fp)
    ## for (int i = 0; i < len; i++)
for:
    lw t0, FOR_COUNTER_POS($fp)
    lw a1, LEN_POS($fp)
    subu t3, t0, a1  ## t3 = i - len
    bgez t3, returnTrue  ## if i >= len termino el for

    ##--------------------------------------------------------------------------
    ## tolower(word[i])
    ##--------------------------------------------------------------------------
    lw a0, BUFFER_POS($fp)  ## redundante pero provisorio
    lw t0, FOR_COUNTER_POS($fp)  ## redundante pero provisorio
    addu t1, a0, t0  ##  t1 = buffer + i
    lb t1, 0(t1)  ## t1 = *(buffer + i)
    sb t1, FIRST_CARACTER_POS($fp)  ## salvo el caracter en la stackFrame
    lb a0, FIRST_CARACTER_POS($fp)  ## cargo argumento de la funcion tolower
    la t9, tolower
    jal ra, t9
    sb v0, FIRST_CARACTER_POS($fp) ## salvo el caracter luego de la funcion
    ##--------------------------------------------------------------------------
    ## tolower(word[i])
    ##--------------------------------------------------------------------------

    ##--------------------------------------------------------------------------
    ## tolower(word[len-i-1]))
    ##--------------------------------------------------------------------------
    lw a1, LEN_POS($fp)  ## redundante pero provisorio
    lw t0, FOR_COUNTER_POS($fp)  ## redundante pero provisorio
    subu t2, a1, t0  ##  t2 = len -i
    subu t2, t2, 1  ##  t2 = len - i - 1
    lw a0, BUFFER_POS($fp)  ## redundante pero provisorio
    addu t2, a0, t2  ##  t2 = buffer + len - i - 1
    lb t2, 0(t2)  ## t2 = *(buffer + len - i - 1)
    sb t2, LAST_CARACTER_POS($fp)  ## salvo el caracter en la stackFrame
    lb a0, LAST_CARACTER_POS($fp)  ## cargo argumento de la funcion tolower
    la t9, tolower
    jal ra, t9
    sb v0, LAST_CARACTER_POS($fp)  ## salvo el caracter luego de la funcion
    ##--------------------------------------------------------------------------
    ## tolower(word[len-i-1]))
    ##--------------------------------------------------------------------------

    ##if (tolower(word[i]) != tolower(word[len-i-1])) return false
    lb t1, FIRST_CARACTER_POS($fp)  ## t1 = tolower(word[i])
    lb t2, LAST_CARACTER_POS($fp)  ## t2 = tolower(word[len-i-1]))
    bne t1, t2, returnFalse

    ## Es necesario ya que antes fue instanciada la funcion tolower
    ## y no hay garantia de que le valor en t0 haya permanecido
    lw t0, FOR_COUNTER_POS($fp)
    addu t0, t0, 1  ## i++
    sw t0, FOR_COUNTER_POS($fp)  ## salvo el nuevo valor
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
    .end isCapicua
    .size isCapicua,.-isCapicua
##------------------------------------------------------------------------------
