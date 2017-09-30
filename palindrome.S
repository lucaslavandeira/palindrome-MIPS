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

#ifndef FOR_COUNTER_POS
#define FOR_COUNTER_POS 52
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
.MACRO callGetch
    ##int c = getch(ifd, iBuffer, ibytes, &iPos);
    lw a0, IFD_POS($fp)  ## guardo en a0 el file descriptor de entrada
    lw a1, IBUFFER($fp)  ## guardo en a1 el buffer de entrada
    lw a2, IBYTES_POS($fp)  ## guardo en a2 el tamaño del buffer de entrada
    addu a3, $fp, IPOS  ## a3 = &pos
    la t9, getch
    jal ra, t9
    li t0, -2  ## t0 = -2
    beq v0, t0, returnError  ## if (c == -2) return ERROR
    sb v0, CARACTER_POS($fp)  ## guardo el caracter leido en la stack frame
.ENDM

.MACRO callPutch
    ##int s = putch(ifd, iBuffer, ibytes, &iPos, char);
    lw a0, OFD_POS($fp)  ## guardo en a0 el file descriptor de entrada
    lw a1, OBUFFER($fp)  ## guardo en a1 el buffer de entrada
    lw a2, OBYTES_POS($fp)  ## guardo en a2 el tamaño del buffer de entrada
    addu a3, $fp, OPOS  ## a3 = &pos
    lb t0, CARACTER_POS($fp)
    sb t0, 16($fp)  ## cargo la posicion de memoria
    la t9, putch
    jal ra, t9
    li t0, -1  ## t0 = -1
    beq v0, t0, returnError  ## if (s == -1) return ERROR
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
    ##}
    ##char* oBuffer = (char*) mymalloc(sizeof(char) * obytes);
    ##if (oBuffer == NULL) {
        ##free(word);
        ##free(iBuffer);
        ##return ERROR;
    ##}

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
            ##wordLen *= 2;
            ##word = (char*) realloc(word, wordLen);
            ##if (word == NULL) {
                ##free(word);
                ##free(iBuffer);
                ##free(oBuffer);
                ##return ERROR;
            ##}
            ##word[cur++] = c;
        ##} else {
            ##if (isCapicua(word, cur)) {
                ##for (int i = 0; i < cur; i++) {
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
    .text
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
    ## Verifico el error
    li t0, -1
    beq v0, t0, returnWord
    sw v0, WORD($fp)  ## guardo el buffer en el stackFrame

    ## char* iBuffer = (char*) malloc(iBytes);
    lw a0, IBYTES_POS($fp)  ## cargo a0 con el parametro de la funcion malloc
    la t9, mymalloc  ## cargo en t9 la direccion de la funcion mymalloc
    jal ra, t9
    ## Verifico el error
    li t0, -1
    beq v0, t0, returnIBuffer
    sw v0, IBUFFER($fp)  ## guardo el buffer en el stackFrame

    ## char* oBuffer = (char*) malloc(oBytes);
    lw a0, OBYTES_POS($fp)  ## cargo a0 con el parametro de la funcion malloc
    la t9, mymalloc  ## cargo en t9 la direccion de la funcion mymalloc
    jal ra, t9
    ## Verifico el error
    li t0, -1
    beq v0, t0, returnOBuffer
    sw v0, OBUFFER($fp)  ## guardo el buffer en el stackFrame

    li t0, 0  ## guardo cero en t0
    sw t0, IPOS($fp)  ## IPos = 0
    sw t0, OPOS($fp)  ## IPos = 0
    sw t0, CURSOR_POS($fp)  ## size_t cur = 0;
    callGetch
while:
    ## while (c != EOF)
    li t0, EOF
    lb t1, CARACTER_POS($fp)  ## t1 = c
    beq t1, t0, returnSuccess  ## if (c == EOF) sale del while
    ##--------------------------------------------------------------------------
    ## if (belongsToSpace(c) && cur >= wordLen)
    ##--------------------------------------------------------------------------
    ## bool belongs = belongsToSpace(c);
    lb a0, CARACTER_POS($fp)  ## t1 = c
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
    la t9, myrealloc
    jal ra, t9
    ## Verificar el error, es decir, if (word == NULL) return ERROR;
    li t7, -1
    beq v0, t1, returnError
    ##word[cur++] = c;
    lw t1, CURSOR_POS($fp)  ## t1 = cur
    addu t1, t1, 1   ## t1++
    sb t1, CURSOR_POS($fp)  ## c++
    lw t0, WORD($fp)
    addu t0, t0, t1  ## t0 = word+cur
    lb t1, CARACTER_POS($fp)  ## t1 = c
    sb t1, 0(t0)  ##  *(word+cur) = c
    j endWhile
else:
    ##if (isCapicua(word, cur))
    lw a0, WORD($fp)
    lw a1, CURSOR_POS($fp)
    la t9, isCapicua
    jal ra, t9
    ## true = 1; false = 0
    li t0, 0  ## t0 = false
    beq v0, t0, afterIf  ## if (isCapicua(word, cur) == false) saltea el if
    ##for (int i = 0; i < cur; i++)
    li t0, 0  ## int i = 0
    sw t0, FOR_COUNTER_POS($fp)  ## salvo el contador del for
    lw t1, CURSOR_POS($fp)  ## t1 = cur
for:
    lw t0, FOR_COUNTER_POS($fp)  ## t0 = i
    lw t1, CURSOR_POS($fp)  ## t1 = cur
    subu t3, t0, t1  ## t3 = i - cur
    bgez t3, afterIf  ## if i >= cur termino el for y salto a afterIf

    lw t3, WORD($fp)  ## t3 = word
    lw t0, FOR_COUNTER_POS($fp)  ## t0 = i
    addu t3, t0, t3  ## t3 = word + i
    lb t3, 0(t3)  ## t3 = *(word + i)
    sb t3, CARACTER_POS($fp)
    callPutch
    lw t0, FOR_COUNTER_POS($fp)  ## t0 = i
    addu t0, t0, 1  ## i++
    sw t0, FOR_COUNTER_POS($fp)  ## salvo el contador del for
    j for

afterIf:
    sw zero, CURSOR_POS($fp)  ##cur = 0;

endWhile:
    callGetch
    j while

returnError:
    li v0, -1  ## return -1; Error
    j return

returnSuccess:
    li v0, 0  ## return 0; Success
##------------------------------------------------------------------------------
## RETURN
##------------------------------------------------------------------------------
return:
    ## free(oBuffer)
    lw a0, OBUFFER($fp)  ## cargo a0 con el parametro de la funcion free
    la t9, myfree  ## cargo en t9 la direccion de la funcion mymalloc
    jal ra, t9
    ## falta verificar error en v0

returnOBuffer:
    ## free(iBuffer)
    lw a0, IBUFFER($fp)  ## cargo a0 con el parametro de la funcion free
    la t9, myfree  ## cargo en t9 la direccion de la funcion mymalloc
    jal ra, t9
    ## falta verificar error en v0

returnIBuffer:
    ## free(word);
    lw a0, WORD($fp)  ## cargo a0 con el parametro de la funcion free
    la t9, myfree  ## cargo en t9 la direccion de la funcion mymalloc
    jal ra, t9
    ## falta verificar error en v0

returnWord:
    lw gp, GP_POS(sp)
    lw $fp, FP_POS(sp)
    lw ra, RA_POS(sp)
    addu sp, sp, SF_SIZE
    jr ra
    .end palindrome
    .size palindrome,.-palindrome
##------------------------------------------------------------------------------
