#define _POSIX_C_SOURCE 1
#include <stdio.h>
#include <zconf.h>
//------------------------------------------------------------------------------
// EXTERNAL FUNCTIONS
//------------------------------------------------------------------------------
extern int putch(int fd, char* buffer, size_t oBytes, size_t* pos, char c);
//------------------------------------------------------------------------------
// TEST FUNCTIONS
//------------------------------------------------------------------------------
int putch2(int fd, char* buffer, size_t oBytes, size_t* pos, char c) {
    if (*pos == oBytes || c == EOF) {
        int sent = 0;
        ssize_t bytesSent;
        while (sent < *pos) {
            bytesSent = write(fd, buffer+sent, *pos-sent);
            if (bytesSent == -1) return -1;
            sent += bytesSent;
        }
        *pos = 0;
    }
    buffer[*pos] = c;
    (*pos)++;
    return 0;
}
//------------------------------------------------------------------------------
// MAIN
//------------------------------------------------------------------------------
int main(int argc, char** argv) {
    printf("Running putch test........... ");
    FILE* archIn = fopen("in.txt", "r");
    if (archIn == NULL) {
        printf("ERROR: fopen returned NULL\n");
        return 1;
    }
    int s = fseek(archIn, 0, SEEK_SET);
    if (s < 0) {
        printf("ERROR: fseek returned %d\n", s);
        return 1;
    }
    FILE* archOut = stdout;
    char buffer[20];
    int fd = fileno(archOut);
    size_t pos = 0;
    int c = getc(archIn);
    while (c != EOF) {
        if (putch(fd, buffer, 20, &pos, (char) c) == -1) {
            printf("ERROR: putch returned -1\n");
            return 1;
        }
        c = getc(archIn);
    }
    if (putch(fd, buffer, 20, &pos, '\n') == -1) {
        printf("ERROR: putch returned -1\n");
        return 1;
    }
    if (putch(fd, buffer, 20, &pos, (char)c) == -1) {
        printf("ERROR: putch returned -1\n");
        return 1;
    }

    if (fclose(archIn) == EOF) {
        printf("ERROR: fclose returned EOF\n");
        return 1;
    }
    return 0;
}
//------------------------------------------------------------------------------
