#include <stdio.h>
#include <string.h>
#include <ctype.h>
//------------------------------------------------------------------------------
// EXTERNAL FUNCTIONS
//------------------------------------------------------------------------------
extern char mytolower(char c);
//------------------------------------------------------------------------------
// MAIN
//------------------------------------------------------------------------------
int main() {
    printf("Running mytolower test.......");
    char msg[] = "ABCDEfghijK8907";
    size_t size = strlen(msg);
    for (int i = 0; i < size; i++) {
        if (tolower(msg[i]) != mytolower(msg[i])) {
            printf("failed at caracter: %c....ERROR\n", msg[i]);
        }
    }
    printf("OK\n");
    return 0;
}
//------------------------------------------------------------------------------
