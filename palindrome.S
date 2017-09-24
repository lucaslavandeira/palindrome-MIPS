#include <sys/syscall.h>
#include <mips/regdef.h>
#-------------------------------------------------------------------------------
# DEFINITIONS
#-------------------------------------------------------------------------------
#ifndef STACK_FRAME_SIZE
#define STACK_FRAME_SIZE 48
#endif

#ifndef RETURN_POINTER_POS
#define RETURN_POINTER_POS STACK_FRAME_SIZE-8
#endif

#ifndef GLOBAL_POINTER_POS
#define GLOBAL_POINTER_POS RETURN_POINTER_POS-4
#endif

#ifndef FRAME_POINTER_POS
#define FRAME_POINTER_POS FRAME_POINTER_POS-4
#endif

#ifndef IFD_POS
#define IFD_POS STACK_FRAME_SIZE
#endif

#ifndef IBYTES_POS
#define IBYTES STACK_FRAME_SIZE+4
#endif

#ifndef OFD_POS
#define OFD_POS STACK_FRAME_SIZE+8
#endif

#ifndef OBYTES_POS
#define OBYTES STACK_FRAME_SIZE+12
#endif
#-------------------------------------------------------------------------------
# CODIGO EQUIVALENTE EN C
#-------------------------------------------------------------------------------
#int palindrome(int ifd, size_t ibytes, int ofd, size_t obytes) {
    #size_t wordLen = 1024;
    #char* word = (char*) malloc(sizeof(char) * wordLen);
    #if (word == NULL) return ERROR;
    #char* iBuffer = (char*) malloc(sizeof(char) * ibytes);
    #if (iBuffer == NULL) return ERROR;
    #char* oBuffer = (char*) malloc(sizeof(char) * obytes);
    #if (oBuffer == NULL) return ERROR;

    #memset(word, 0, word_len);
    #size_t iPos = 0;
    #int c = getch(ifd, word, ibytes, &iPos);
    #if (c == -1) {
        #free(word);
        #free(iBuffer);
        #free(oBuffer);
        #return ERROR;
    #}
    #size_t cur = 0;

    #while (c != EOF) {
        #if (belongsToSpace(c) && cur >= wordLen) {
            #word_len *= 2;
            #word = (char*) realloc(word, wordLen);
            #if (word == NULL) {
                #free(word);
                #free(iBuffer);
                #free(oBuffer);
                #return ERROR;
            #}
            #word[cur++] = c;
        #} else {
            #if (stdinCapicua(word, cur)) {
                #for (int i = 0; i < curr; i++) {
                    #if (putch(ofd, oBuffer, obytes, word[i]) == -1) {
                        #free(word);
                        #free(iBuffer);
                        #free(oBuffer);
                        #return ERROR;
                    #}
                #}
            #}
            #memset(word, 0, word_len);
            #cur = 0;
        #}
        #c = getch(ifd, word, ibytes, &iPos);
        #if (c == -1) {
            #free(word);
            #free(iBuffer);
            #free(oBuffer);
            #return ERROR;
        #}
    #}
    #free(word);
    #free(iBuffer);
    #free(oBuffer);
    #return SUCCESS;
#}
#-------------------------------------------------------------------------------
# CODIGO EN MIPS
#-------------------------------------------------------------------------------