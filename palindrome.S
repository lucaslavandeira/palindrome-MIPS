#include <sys/syscall.h>
#include <mips/regdef.h>
##------------------------------------------------------------------------------
## DEFINITIONS
##------------------------------------------------------------------------------
#ifndef SF_SIZE
#define SF_SIZE 48
#endif

#ifndef RA_POS
#define RA_POS SF_SIZE-8
#endif

#ifndef GP_POS
#define GP_POS RA_POS-4
#endif

#ifndef FP_POS
#define FP_POS GP_POS-4
#endif

#ifndef IFD_POS
#define IFD_POS STACK_FRAME_SIZE
#endif

#ifndef IBYTES_POS
#define IBYTES_POS STACK_FRAME_SIZE+4
#endif

#ifndef OFD_POS
#define OFD_POS STACK_FRAME_SIZE+8
#endif

#ifndef OBYTES_POS
#define OBYTES_POS STACK_FRAME_SIZE+12
#endif
##------------------------------------------------------------------------------
## CODIGO EQUIVALENTE EN C
##------------------------------------------------------------------------------
##int palindrome(int ifd, size_t ibytes, int ofd, size_t obytes) {
    ##size_t wordLen = 1024;
    ##char* word = (char*) malloc(sizeof(char) * wordLen);
    ##if (word == NULL) return ERROR;
    ##char* iBuffer = (char*) malloc(sizeof(char) * ibytes);
    ##if (iBuffer == NULL) return ERROR;
    ##char* oBuffer = (char*) malloc(sizeof(char) * obytes);
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