#include <sys/syscall.h>
#include <mips/regdef.h>
##------------------------------------------------------------------------------
## DEFINITIONS
##------------------------------------------------------------------------------
#ifndef SF_SIZE
#define SF_SIZE 40
#endif

#ifndef RA_POS
#define RA_POS 36
#endif

#ifndef GP_POS
#define GP_POS 32
#endif

#ifndef FP_POS
#define FP_POS 28
#endif

#ifndef IFD_POS
#define IFD_POS 40
#endif

#ifndef IBYTES_POS
#define IBYTES_POS 44
#endif

#ifndef OFD_POS
#define OFD_POS 48
#endif

#ifndef OBYTES_POS
#define OBYTES_POS 52
#endif

#ifndef INITIAL_SIZE
#define INITIAL_SIZE 1024
#endif
##------------------------------------------------------------------------------
## CODIGO EQUIVALENTE EN C
##------------------------------------------------------------------------------
##int palindrome(int ifd, size_t ibytes, int ofd, size_t obytes) {
    ##size_t wordLen = 1024;
    ##char* word = (char*) mymalloc(sizeof(char) * wordLen);
    ##if (word == NULL) return ERROR;
    ##char* iBuffer = (char*) mymalloc(sizeof(char) * ibytes);
    ##if (iBuffer == NULL) return ERROR;
    ##char* oBuffer = (char*) mymalloc(sizeof(char) * obytes);
    ##if (oBuffer == NULL) return ERROR;

    ##memset(word, 0, word_len);
    ##size_t iPos = 0;
    ##int c = getch(ifd, word, ibytes, &iPos);
    ##if (c == -1) {
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
                    ##if (putch(ofd, oBuffer, obytes, word[i]) == -1) {
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
        ##if (c == -1) {
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
    .set	noreorder
    .cpload t9
    .set	reorder
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
    ## Inicializacion del stack frame
    ##--------------------------------------------------------------------------

return:
    lw gp, GP_POS(sp)
    lw $fp, FP_POS(sp)
    lw ra, RA_POS(sp)
    addu sp, sp, SF_SIZE
    jr ra
    .end palindrome
    .size palindrome,.-palindrome
##------------------------------------------------------------------------------
