#include <sys/syscall.h>
#include <mips/regdef.h>
##------------------------------------------------------------------------------
## DEFINITIONS
##------------------------------------------------------------------------------
#ifndef SF_SIZE
#define SF_SIZE 72
#endif

#ifndef RA_POS
#define RA_POS 68
#endif

#ifndef GP_POS
#define GP_POS 64
#endif

#ifndef FP_POS
#define FP_POS 60
#endif

#ifndef CARACTER_POS
#define CARACTER_POS 48
#endif

#ifndef CURSOR_POS
#define CURSOR_POS 44
#endif

#ifndef IPOS
#define IPOS 40
#endif

#ifndef OPOS
#define OPOS 36
#endif

#ifndef OBUFFER
#define OBUFFER 32
#endif

#ifndef IBUFFER
#define IBUFFER 28
#endif

#ifndef WORD
#define WORD 24
#endif

#ifndef CONSTANT_POS
#define CONSTANT_POS 20
#endif

#ifndef IFD_POS
#define IFD_POS 72
#endif

#ifndef IBYTES_POS
#define IBYTES_POS 76
#endif

#ifndef OFD_POS
#define OFD_POS 80
#endif

#ifndef OBYTES_POS
#define OBYTES_POS 84
#endif

#ifndef INITIAL_SIZE
#define INITIAL_SIZE 1024
#endif

#ifndef SIZE_OF_CHAR
#define SIZE_OF_CHAR 1
#endif

#ifndef EOF
#define EOF -1
#endif
##------------------------------------------------------------------------------
## MACROS DEFINITIONS
##------------------------------------------------------------------------------
.MACRO callMalloc ($argument)
    lw a0, $argument  ## cargo a0 con el parametro de la funcion malloc
    la t9, mymalloc  ## cargo en t9 la direccion de la funcion mymalloc
    jal ra, t9
.ENDM
##------------------------------------------------------------------------------
## CODIGO EQUIVALENTE EN C
##------------------------------------------------------------------------------
##int palindrome(int ifd, size_t ibytes, int ofd, size_t obytes) {
    ##size_t wordLen = 1024;
    ##char* word = (char*) mymalloc(sizeof(char) * wordLen);
    ##if (word == NULL) return ERROR;
    ##char* iBuffer = (char*) mymalloc(sizeof(char) * ibytes);
    ##if (iBuffer == NULL) {
        ##free(word);
        ##return ERROR;
    }
    ##char* oBuffer = (char*) mymalloc(sizeof(char) * obytes);
    ##if (oBuffer == NULL) {
        ##free(word);
        ##free(iBuffer);
        ##return ERROR;
    }

    ##memset(word, 0, word_len);
    ##size_t iPos = 0;
    ##size_t oPos = 0;
    ##int c = getch(ifd, iBuffer, ibytes, &iPos);
    ##if (c == -2) {
        ##free(word);
        ##free(iBuffer);
        ##free(oBuffer);
        ##return ERROR;
    ##}
    ##size_t cur = 0;

    ##while (c != EOF) {
        ##if (belongsToSpace(c) && cur >= wordLen) {
            ##word_len *= 2;
            ##word = (char*) realloc(word, wordLen);
            ##if (word == NULL) {
                ##free(word);
                ##free(iBuffer);
                ##free(oBuffer);
                ##return ERROR;
            ##}
            ##word[cur++] = c;
        ##} else {
            ##if (stdinCapicua(word, cur)) {
                ##for (int i = 0; i < curr; i++) {
                    ##if (putch(ofd, oBuffer, obytes, &oPos, word[i]) == -1) {
                        ##free(word);
                        ##free(iBuffer);
                        ##free(oBuffer);
                        ##return ERROR;
                    ##}
                ##}
            ##}
            ##memset(word, 0, word_len);
            ##cur = 0;
        ##}
        ##c = getch(ifd, word, ibytes, &iPos);
        ##if (c == -2) {
            ##free(word);
            ##free(iBuffer);
            ##free(oBuffer);
            ##return ERROR;
        ##}
    ##}
    ##free(word);
    ##free(iBuffer);
    ##free(oBuffer);
    ##return SUCCESS;
##}
##------------------------------------------------------------------------------
## CODIGO EN MIPS
##------------------------------------------------------------------------------
text
    .abicalls
    .align 2
    .globl palindrome
    .ent palindrome
palindrome:
    ##--------------------------------------------------------------------------
    ## Inicializacion del stack frame
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
    sw a0, IFD_POS($fp)  # file descriptor
    sw a1, IBYTES_POS($fp)  # buffer
    sw a2, OFD_POS($fp)  # position actual de escritura del buffer
    sw a3, OBYTES_POS($fp)  # capacidad maxima del buffer
    ##--------------------------------------------------------------------------
    ## FIN Inicializacion del stack frame
    ##--------------------------------------------------------------------------
    li t0, INITIAL_SIZE  ##size_t wordLen = 1024;
    sw t0, CONSTANT_POS($fp)  ## guardo wordLen en el stackFrame

    ## char* word = (char*) malloc(wordLen);
    lw a0, CONSTANT_POS($fp)  ## cargo a0 con el parametro de la funcion malloc
    la t9, mymalloc  ## cargo en t9 la direccion de la funcion mymalloc
    jal ra, t9
    ## falta verificar error en v0
    sw v0, WORD($fp)  ## guardo el buffer en el stackFrame

    ## char* iBuffer = (char*) malloc(iBytes);
    lw a0, IBYTES_POS($fp)  ## cargo a0 con el parametro de la funcion malloc
    la t9, mymalloc  ## cargo en t9 la direccion de la funcion mymalloc
    jal ra, t9
    ## falta verificar error en v0
    sw v0, IBUFFER($fp)  ## guardo el buffer en el stackFrame

    ## char* oBuffer = (char*) malloc(oBytes);
    lw a0, OBYTES_POS($fp)  ## cargo a0 con el parametro de la funcion malloc
    la t9, mymalloc  ## cargo en t9 la direccion de la funcion mymalloc
    jal ra, t9
    ## falta verificar error en v0
    sw v0, OBUFFER($fp)  ## guardo el buffer en el stackFrame

    addu t0, zero, 0  ## guardo cero en t0
    sw t0, IPOS($fp)  ## IPos = 0
    sw t0, OPOS($fp)  ## IPos = 0
    sw t0, CURSOR_POS($fp)  ## size_t cur = 0;

    ##int c = getch(ifd, iBuffer, ibytes, &iPos);
    lw a0, IFD($fp)  ## guardo en a0 el file descriptor de entrada
    lw a1, IBUFFER($fp)  ## guardo en a1 el buffer de entrada
    lw a2, IBYTES($fp)  ## guardo en a2 el tamaño del buffer de entrada
    la a3, IPOS  ## guardo en a3 la posicion de memoria de la pos de lectura
    la t9, getch
    jal ra, t9
    addu t0, zero, -2  ## t0 = -2
    beq v0, t0, return  ## if (c == -2) return ERROR

    sb v0, CARACTER_POS($fp)  ## guardo el caracter leido en la stack frame

    ##while (c != EOF)
    li t0, EOF
    lb t1, CARACTER_POS($fp)  ## t1 = c
    beq t1, t0, return  ## if (C == EOF) sale del while
    ##--------------------------------------------------------------------------
    ## if (belongsToSpace(c) && cur >= wordLen)
    ##--------------------------------------------------------------------------
    ## bool belongs = belongsToSpace(c);
    lw a0, CARACTER_POS($fp)  ## t1 = c
    la t9, belongsToSpace
    jal ra, t9
    ## true = 1; false = 0
    li t0, 0  ## t0 = false
    beq v0, t0, else  ## if (belongsToSpace(c) == false) sale del if
    lw t0, CURSOR_POS($fp)  ## t0 = cur
    lw t1, CONSTANT_POS($fp)  ## t1 = wordLen
    subu t0, t0, t1  ## t0 = cur - wordLen
    bltz t0, else   ## if (cur - wordLen < 0) sale del if
    ##--------------------------------------------------------------------------
    ##wordLen *= 2;
    lw t1, CONSTANT_POS($fp)  ## t1 = wordLen
    sll t1, t1, 1  ## t1 = wordLen*2
    sw t1, CONSTANT_POS($fp)  ## wordLen *= 2
    ##word = (char*) realloc(word, wordLen);
    lw a0, WORD($fp)
    lw a1, CONSTANT_POS($fp)
    la t9, realloc
    jal ra, t9
    ## falta verificar el error, es decir, if (word == NULL)
    ##word[cur++] = c;
    lb t1, CARACTER_POS($fp)  ## t1 = c
    addu t1, t1, 1  ## t1++
    sw t1, CARACTER_POS($fp)  ## c++
    lw t0, WORD($fp)
    addu t0, t0, t1  ## t0 = word+cur
    lb t1, CARACTER_POS($fp)  ## t1 = c
    sb t1, 0(t0)  ##  *(word+cur) = c
else:
##------------------------------------------------------------------------------
## RETURN
##------------------------------------------------------------------------------
return:
    ## free(word
    lw a0, WORD($fp)  ## cargo a0 con el parametro de la funcion free
    la t9, mymalloc  ## cargo en t9 la direccion de la funcion mymalloc
    jal ra, t9
    ## falta verificar error en v0

    ## free(iBuffer)
    lw a0, IBUFFER($fp)  ## cargo a0 con el parametro de la funcion free
    la t9, mymalloc  ## cargo en t9 la direccion de la funcion mymalloc
    jal ra, t9
    ## falta verificar error en v0

    ## free(oBuffer)
    lw a0, OBUFFER($fp)  ## cargo a0 con el parametro de la funcion free
    la t9, mymalloc  ## cargo en t9 la direccion de la funcion mymalloc
    jal ra, t9
    ## falta verificar error en v0

    lw gp, GP_POS(sp)
    lw $fp, FP_POS(sp)
    lw ra, RA_POS(sp)
    addu sp, sp, SF_SIZE
    jr ra
    .end palindrome
    .size palindrome,.-palindrome
##------------------------------------------------------------------------------
