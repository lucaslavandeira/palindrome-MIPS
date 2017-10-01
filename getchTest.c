#define _POSIX_C_SOURCE 1
#include <stdio.h>
#include <zconf.h>
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
    FILE* archIn = fopen("in.txt", "r");
    char buffer[20];
    int fd = fileno(archIn);
    size_t pos = 0;
    int c = getch(fd, buffer, 20, &pos);
    while (c != EOF) {
        printf("%c", c);
        c = getch(fd, buffer, 20, &pos);
    }
    // printf("\n");
    fclose(archIn);
    return 0;
}
//------------------------------------------------------------------------------
