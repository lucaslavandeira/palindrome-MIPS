#include <sys/syscall.h>
#include <mips/regdef.h>
##------------------------------------------------------------------------------
## DEFINITIONS
##------------------------------------------------------------------------------
#ifndef SF_SIZE
#define SF_SIZE 80
#endif

#ifndef RA_POS
#define RA_POS 76
#endif

#ifndef GP_POS
#define GP_POS 72
#endif

#ifndef FP_POS
#define FP_POS 68
#endif

#ifndef RETURN_VALUE_POS
#define RETURN_VALUE_POS 60
#endif

#ifndef FOR_COUNTER_POS
#define FOR_COUNTER_POS 56
#endif

#ifndef CARACTER_TO_WRITE_POS
#define CARACTER_TO_WRITE_POS 52
#endif

#ifndef CARACTER_TO_READ_POS
#define CARACTER_TO_READ_POS 48
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

#ifndef WORD_LEN_POS
#define WORD_LEN_POS 20
#endif

#ifndef IFD_POS
#define IFD_POS 80
#endif

#ifndef IBYTES_POS
#define IBYTES_POS 84
#endif

#ifndef OFD_POS
#define OFD_POS 88
#endif

#ifndef OBYTES_POS
#define OBYTES_POS 92
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

#ifndef ENTER
#define ENTER 10
#endif
##------------------------------------------------------------------------------
## CODIGO EQUIVALENTE EN C
##------------------------------------------------------------------------------
##int palindrome(int ifd, size_t ibytes, int ofd, size_t obytes) {
    ##size_t wordLen = 1024;
    ##char* word = (char*) mymalloc(sizeof(char) * wordLen);
    ##if (word == NULL) return ERROR;
    ##char* iBuffer = (char*) mymalloc(sizeof(char) * ibytes);
    ##if (iBuffer == NULL) {
        ##myfree(word);
        ##return ERROR;
    ##}
    ##char* oBuffer = (char*) mymalloc(sizeof(char) * obytes);
    ##if (oBuffer == NULL) {
        ##myfree(word);
        ##myfree(iBuffer);
        ##return ERROR;
    ##}
    ##size_t iPos = 0;
    ##size_t oPos = 0;
    ##size_t cur = 0;
    ##int c = getch(ifd, iBuffer, ibytes, &iPos);
    ##if (c == -2) {
        ##myfree(word);
        ##myfree(iBuffer);
        ##myfree(oBuffer);
        ##return ERROR;
    ##}

    ##while (c != EOF) {
        ##if (belongsToSpace((char) c)) {
            ##if (cur >= wordLen) {
                ##wordLen *= 2;
                ##word = (char*) myrealloc(word, wordLen);
                ##if (word == NULL) {
                    ##myfree(word);
                    ##myfree(iBuffer);
                    ##myfree(oBuffer);
                    ##return ERROR;
                ##}
            ##}
            ##word[cur] = (char) c;
            ##cur++;
        ##} else {
            ##if (isCapicua(word, cur)) {
                ##for (int i = 0; i < cur; i++) {
                    ##if (putch(ofd, oBuffer, obytes, &oPos, word[i]) == -1) {
                        ##myfree(word);
                        ##myfree(iBuffer);
                        ##myfree(oBuffer);
                        ##return ERROR;
                    ##}
                ##}
            ##}
            ##cur = 0;
        ##}
        ##c = getch(ifd, iBuffer, ibytes, &iPos);
        ##if (c == -2) {
            ##myfree(word);
            ##myfree(iBuffer);
            ##myfree(oBuffer);
            ##return ERROR;
        ##}
    ##}
    ##myfree(word);
    ##myfree(iBuffer);
    ##myfree(oBuffer);
    ##return SUCCESS;
##------------------------------------------------------------------------------
## MACROS
##------------------------------------------------------------------------------
.MACRO callGetch
    lw a0, IFD_POS($fp)  ## guardo en a0 el file descriptor de entrada
    lw a1, IBUFFER($fp)  ## guardo en a1 el buffer de entrada
    lw a2, IBYTES_POS($fp)  ## guardo en a2 el tamaño del buffer de entrada
    addu a3, $fp, IPOS  ## a3 = &pos
    la t9, getch
    jal ra, t9
    li t0, -2  ## t0 = -2
    beq v0, t0, returnError  ## if (c == -2) return ERROR
    sw v0, CARACTER_TO_READ_POS($fp)  ## guardo el caracter leido
.ENDM
.MACRO callPutch
    lw a0, OFD_POS($fp)  ## guardo en a0 el file descriptor de entrada
    lw a1, OBUFFER($fp)  ## guardo en a1 el buffer de entrada
    lw a2, OBYTES_POS($fp)  ## guardo en a2 el tamaño del buffer de entrada
    addu a3, $fp, OPOS  ## a3 = &pos
    lw t0, CARACTER_TO_WRITE_POS($fp)
    sb t0, 16($fp)  ## cargo la posicion de memoria
    la t9, putch
    jal ra, t9
    li t0, -1  ## t0 = -1
    beq v0, t0, returnError  ## if (s == -1) return ERROR
.ENDM
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
    sw t0, WORD_LEN_POS($fp)  ## guardo wordLen en el stackFrame

    ## char* word = (char*) malloc(wordLen);
    lw a0, WORD_LEN_POS($fp)  ## cargo a0 con el parametro de la funcion malloc
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

    sw zero, IPOS($fp)  ## IPos = 0
    sw zero, OPOS($fp)  ## OPos = 0
    sw zero, CURSOR_POS($fp)  ## size_t cur = 0;
    callGetch
while:
    ## while (c != EOF)
    li t0, EOF
    lw t1, CARACTER_TO_READ_POS($fp)  ## t1 = c
    beq t1, t0, returnSuccess  ## if (c == EOF) sale del while
    ##--------------------------------------------------------------------------
    ## if (belongsToSpace(c))
    ##--------------------------------------------------------------------------
    ## bool belongs = belongsToSpace(c);
    lw a0, CARACTER_TO_READ_POS($fp)  ## t1 = c
    la t9, belongsToSpace
    jal ra, t9
    ## true = 1; false = 0
    li t0, 0  ## t0 = false
    beq v0, t0, else  ## if (belongsToSpace(c) == false) sale del if
    ##--------------------------------------------------------------------------
    ## if (cur >= wordLen)
    ##--------------------------------------------------------------------------
    lw t0, CURSOR_POS($fp)  ## t0 = cur
    lw t1, WORD_LEN_POS($fp)  ## t1 = wordLen
    subu t0, t0, t1  ## t0 = cur - wordLen
    bltz t0, beforeElse   ## if (cur - wordLen < 0) sale del if
    ##--------------------------------------------------------------------------
    ##wordLen *= 2;
    lw t1, WORD_LEN_POS($fp)  ## t1 = wordLen
    sll t1, t1, 1  ## t1 = wordLen*2
    sw t1, WORD_LEN_POS($fp)  ## wordLen *= 2
    ##word = (char*) realloc(word, wordLen);
    lw a0, WORD($fp)
    lw a1, WORD_LEN_POS($fp)
    la t9, myrealloc
    jal ra, t9
    ## Verificar el error, es decir, if (word == NULL) return ERROR;
    li t0, -1
    beq v0, t0, returnError
    sw v0, WORD($fp);

beforeElse:
    ## word[cur] = c;
    lw t1, CURSOR_POS($fp)  ## t1 = cur
    lw t0, WORD($fp)
    addu t0, t0, t1  ## t0 = word + cur
    lw t1, CARACTER_TO_READ_POS($fp)  ## t1 = c
    sb t1, 0(t0)  ##  *(word+cur) = c

    ## cur++;
    lw t1, CURSOR_POS($fp)  ## t1 = cur
    addu t1, t1, 1   ## t1++
    sw t1, CURSOR_POS($fp)  ## c++
    j endWhile

else:
    ##--------------------------------------------------------------------------
    ##if (isCapicua(word, cur))
    ##--------------------------------------------------------------------------
    lw a0, WORD($fp)
    lw a1, CURSOR_POS($fp)
    la t9, isCapicua
    jal ra, t9
    ## true = 1; false = 0
    li t0, 0  ## t0 = false
    beq v0, t0, afterIf  ## if (isCapicua(word, cur) == false) saltea el if
    ##for (int i = 0; i < cur; i++)
    sw zero, FOR_COUNTER_POS($fp)  ## i = 0
for:
    lw t0, FOR_COUNTER_POS($fp)  ## t0 = i
    lw t1, CURSOR_POS($fp)  ## t1 = cur
    subu t3, t0, t1  ## t3 = i - cur
    bgez t3, endFor  ## if i >= cur termino el for y salto a afterIf

    lw t3, WORD($fp)  ## t3 = word
    lw t0, FOR_COUNTER_POS($fp)  ## t0 = i
    addu t3, t0, t3  ## t3 = word + i
    lb t3, 0(t3)  ## t3 = *(word + i)
    sb t3, CARACTER_TO_WRITE_POS($fp)
    callPutch
    lw t0, FOR_COUNTER_POS($fp)  ## t0 = i
    addu t0, t0, 1  ## i++
    sw t0, FOR_COUNTER_POS($fp)  ## salvo el contador del for
    j for
endFor:
    la t0, ENTER
    sb t0, CARACTER_TO_WRITE_POS($fp)
    callPutch

afterIf:
    sw zero, CURSOR_POS($fp)  ##cur = 0;

endWhile:
    callGetch
    j while

returnError:
    li t0, -1  ## return -1; Error
    sw t0, RETURN_VALUE_POS($fp)
    j return

returnSuccess:
    lb t0, CARACTER_TO_READ_POS($fp)
    sb t0, CARACTER_TO_WRITE_POS($fp)
    callPutch
    li t0, 0  ## return Success
    sw t0, RETURN_VALUE_POS($fp)
##------------------------------------------------------------------------------
## RETURN
##------------------------------------------------------------------------------
return:
    ## myfree(oBuffer)
    lw a0, OBUFFER($fp)  ## cargo a0 con el parametro de la funcion myfree
    la t9, myfree  ## cargo en t9 la direccion de la funcion mymalloc
    jal ra, t9

returnOBuffer:
    ## myfree(iBuffer)
    lw a0, IBUFFER($fp)  ## cargo a0 con el parametro de la funcion myfree
    la t9, myfree  ## cargo en t9 la direccion de la funcion mymalloc
    jal ra, t9

returnIBuffer:
    ## myfree(word);
    lw a0, WORD($fp)  ## cargo a0 con el parametro de la funcion myfree
    la t9, myfree  ## cargo en t9 la direccion de la funcion mymalloc
    jal ra, t9

returnWord:
    lw v0, RETURN_VALUE_POS($fp)  ## return v0
    lw gp, GP_POS(sp)
    lw $fp, FP_POS(sp)
    lw ra, RA_POS(sp)
    addu sp, sp, SF_SIZE
    jr ra
    .end palindrome
    .size palindrome,.-palindrome
##-----------------------------------------------------------------------------
