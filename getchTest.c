#define _POSIX_C_SOURCE 1
#include <stdio.h>
#include <zconf.h>
#include <stdlib.h>
#include <stdbool.h>

//------------------------------------------------------------------------------
// EXTERNAL FUNCTIONS
//------------------------------------------------------------------------------
extern int getch(int fd, char* buffer, size_t oBytes, size_t* pos);
//------------------------------------------------------------------------------
// TEST FUNCTIONS
//------------------------------------------------------------------------------
int getch2(int fd, char* buffer, size_t iBytes, size_t* pos) {
    if (*pos == iBytes || *pos == 0) {
        *pos = 0;
        int received = 0;
        ssize_t bytesRead = -1;
        while (received < iBytes && bytesRead != 0) {
            bytesRead = read(fd, buffer+received, iBytes-received);
            if (bytesRead == -1) return -2;
            if (bytesRead == 0) buffer[received] = EOF;
            received += bytesRead;
        }
    }
    int c = buffer[*pos];
    (*pos)++;
    return c;
}
//------------------------------------------------------------------------------
// MAIN
//------------------------------------------------------------------------------
int main() {
    printf("Running getch Test............... ");
    FILE* archIn = fopen("in.txt", "r");
    if (archIn == NULL) {
        printf("fopen returned NULL\n");
        return 1;
    }
    fseek(archIn, 0, SEEK_SET);
    size_t size = 20;
    char* testBuffer = (char*) malloc(size);
    if (testBuffer == NULL) {
        printf("malloc returned NULL\n");
        return 1;
    }
    size_t counter = 0;
    char buffer[20];
    int fd = fileno(archIn);
    size_t pos = 0;
    int c = getch(fd, buffer, 20, &pos);
    if (c == -2) {
        printf("getch returned -2\n");
        return 1;
    }
    //--------------------------------------------------------------------------
    while (c != EOF) {
        testBuffer[counter] = (char)c;
        counter++;
        if (counter >= size) {
            size*=2;
            testBuffer = (char*) realloc(testBuffer, size);
            if (testBuffer == NULL) {
                printf("realloc returned NULL\n");
                return 1;
            }
        }
        c = getch(fd, buffer, 20, &pos);
        if (c == -2) {
            printf("getch returned -2\n");
            return 1;
        }
    }
    //--------------------------------------------------------------------------
    fseek(archIn, 0, SEEK_SET);
    c = getc(archIn);
    counter = 0;
    bool itFailed = false;
    while (c != EOF) {
        if (c != testBuffer[counter]) {
            itFailed = true;
            printf("ERROR: Failed at caracter: %c\n", c);
        }
        counter++;
        c = getc(archIn);
    }
    //--------------------------------------------------------------------------
    if (!itFailed) printf("OK\n");
    free(testBuffer);
    if (fclose(archIn) == EOF) {
        printf("fclose returned EOF\n");
        return 1;
    }
    return 0;
}
//------------------------------------------------------------------------------
