#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>
//------------------------------------------------------------------------------
// EXTERNAL FUNCTIONS
//------------------------------------------------------------------------------
extern bool isCapicua(const char* word, size_t size);
//------------------------------------------------------------------------------
// TEST FUNCTIONS
//------------------------------------------------------------------------------
bool testFunction(char* word, size_t len) {
    for (int i = 0; i < len; i++) {
        if (tolower((int) word[i]) != tolower((int) word[len - i - 1])) {
            return false;
        }
    }
    return true;
}
//------------------------------------------------------------------------------
// MAIN
//------------------------------------------------------------------------------
int main() {
    printf("Running isCapicua test......... ");
    char* msg[] = {"Aa", "a", "Somos", "somos", "hola", "No es capicua"};
    bool ref, test;
    size_t size = 6;
    bool itFailed = false;
    for (int i = 0; i < size; i++) {
        test = isCapicua(msg[i], strlen(msg[i]));
        ref = testFunction(msg[i], strlen(msg[i]));
        if (ref != test) {
            itFailed = true;
            printf("ERROR: Failed with string: %s\n", msg[i]);
        }
    }
    if (!itFailed) printf("OK\n");
    return 0;
}
//------------------------------------------------------------------------------
