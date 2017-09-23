#define _POSIX_C_SOURCE 1 // Necesario para la función fileno
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>
#include <stdlib.h>
#include <signal.h>
//------------------------------------------------------------------------------
// DEFINITIONS
//------------------------------------------------------------------------------
#define ERROR 1
#define SUCCESS 0
#define VERSION "dev"

const char help_str[] = "Usage:\n"
        "  tp1 -h\n"
        "  tp1 -V\n"
        "  tp1 [options]\n"
        "Options:\n"
        "  -V, --version\tPrint version and quit.\n"
        "  -h, --help\tPrint this information.\n"
        "  -i, --input\tLocation of the input file.\n"
        "  -o, --output\tLocation of the output file.\n"
        "  -I, --ibuf-bytes\tByte-count of the input buffer."
        "  -O, --obuf-bytes\tByte-count of the output buffer."
        "Examples:\n"
        "  tp1 -i ~/input -o\n";
//------------------------------------------------------------------------------
// EQUAL
//------------------------------------------------------------------------------
bool equal(const char* str1, const char* str2) {
    return strcmp(str1, str2) == 0;
}
//------------------------------------------------------------------------------
// ARG PARSE
//------------------------------------------------------------------------------
int argParse(int argc, char** argv, FILE** descriptors, int* clean_exit) {
    int arg = 1;
    const int size = 8;
    const char* flags[] = {"-i", "-o", "-V", "-h", "--version", "--help",
                           "--input", "--output"};

    bool std;
    char* flag = "";
    bool isFlagNull;
    while (arg < argc) {
        isFlagNull = true;
        if (argv[arg][0] == '-') {
            for (int i = 0; i < size; i++) {
                if (strcmp(argv[arg], flags[i]) == 0) {
                    flag = argv[arg];
                    isFlagNull = false;
                    break;
                }
            }

            if (equal(flag, "-h") || equal(flag, "--help")) {
                printf("%s\n", help_str);
                *clean_exit = 1;
                return SUCCESS;
            }
            if (equal(flag, "-V") || equal(flag, "--version")) {
                printf("tp1: version %s\n", VERSION);
                *clean_exit = 1;
                return SUCCESS;
            }
            if (isFlagNull) {
                printf("Invalid argument: %s\n", argv[arg]);
                descriptors[0] = NULL;
                return ERROR;
            }
        } else {
            std = equal(argv[arg], "-");
            if ((equal(flag, "-i") || equal(flag, "--input")) && !std) {
                descriptors[0] = fopen(argv[arg], "r");
                if (descriptors[0] == NULL) return ERROR;
            } else if ((equal(flag, "-o") || equal(flag, "--output")) && !std) {
                descriptors[1] = fopen(argv[arg], "w");
                if (descriptors[1] == NULL) return ERROR;
            }
            flag = "nullStr";
        }
        arg++;
    }
    return SUCCESS;
}

int main(int argc, char** argv) {
    FILE* fpointers[2];
    int fdescriptors[2];
    int clean_exit = 0;
    if(argParse(argc, argv, fpointers, &clean_exit) == ERROR) {
        return ERROR;
    }

    if (clean_exit) {
        return SUCCESS;
    }

    for (int i = 0; i < 2; ++i) {
        fdescriptors[i] = fileno(fpointers[i]);
        if (fdescriptors[i] < 0) {
            return ERROR;
        }
    }
    return SUCCESS;
}

