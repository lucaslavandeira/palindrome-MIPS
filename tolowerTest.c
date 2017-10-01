#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
//------------------------------------------------------------------------------
// DEFINITIONS
//------------------------------------------------------------------------------
#define ERROR 1
#define SUCCESS 0
#define VERSION "0.2"
const char help_str[] = "Usage:\n"
        "  tp1 -h\n"
        "  tp1 -V\n"
        "  tp1 [options]\n"
        "Options:\n"
        "  -V, --version\tPrint version and quit.\n"
        "  -h, --help\tPrint this information.\n"
        "  -i, --input\tLocation of the input file.\n"
        "  -o, --output\tLocation of the output file.\n"
        "Examples:\n"
        "  tp0 -i ~/input -o\n";
//------------------------------------------------------------------------------
// EXTERNAL FUNCTIONS
//------------------------------------------------------------------------------
extern char tolower(char c);
//------------------------------------------------------------------------------
// MAIN
//------------------------------------------------------------------------------
int main(int argc, char** argv) {
    char msg[] = "ABCDEfghijK8907";
    size_t size = strlen(msg);
    for (int i = 0; i < size; i++) {
        printf("tolower(msg[%d]): %c\n", i, tolower(msg[i]));
    }
    return 0;
}
//------------------------------------------------------------------------------
