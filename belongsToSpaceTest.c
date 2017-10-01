#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
//------------------------------------------------------------------------------
// EXTERNAL FUNCTIONS
//------------------------------------------------------------------------------
extern bool belongsToSpace(char c);
//------------------------------------------------------------------------------
// TEST FUNCTION
//------------------------------------------------------------------------------
// Del 97 al 122 estan las letras de a-z
// Del 65 al 90 estan las letras de A-Z
// Del 48 al 57 estan los numeros de 0-9
// '-' es 45
// '_' es 95
bool testFunction(char c) {
    if (c >= 97 && c <= 122) return true;
    if (c >= 65 && c <= 90) return true;
    if (c >= 48 && c <= 57) return true;
    if (c == 45 || c == 95) return true;
    return false;
}
//------------------------------------------------------------------------------
// MAIN
//------------------------------------------------------------------------------
int main() {
    printf("Running belongsToSpace test....... ");
    char msg[] = "1234hola como estas Todo bien <<<<<>>>>>+++*  hola+";
    const size_t size = strlen(msg);
    bool ref, test;
    for (size_t i = 0; i < size; i++) {
        ref = testFunction(msg[i]);
        test = belongsToSpace(msg[i]);
        if (test != ref) {
            printf("ERROR: Failed at caracter: %c\n", msg[i]);
        }
    }
    printf("OK\n");
}
//------------------------------------------------------------------------------
