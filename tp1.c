#define _POSIX_C_SOURCE 1
#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <stdlib.h>
//------------------------------------------------------------------------------
// DEFINITIONS
//------------------------------------------------------------------------------
#define ERROR -1
#define SUCCESS 0
#define VERSION "0.1"
const char help_str[] = "Usage:\n"
        "  tp1 -h\n"
        "  tp1 -V\n"
        "  tp1 [options]\n"
        "Options:\n"
        "  -V, --version\tPrint version and quit.\n"
        "  -h, --help\tPrint this information.\n"
        "  -i, --input\tLocation of the input file.\n"
        "  -o, --output\tLocation of the output file.\n"
        "  -I, --ibuf-bytes\tbyte-count of the input buffer\n"
        "  -O, --obuf-bytes\tbyte-count of the output buffer\n"
        "Examples:\n"
        "  tp1 -i ~/input -o ~/output\n";
//------------------------------------------------------------------------------
// EXTERNAL FUNCTIONS
//------------------------------------------------------------------------------
extern int palindrome(int ifd, size_t ibytes, int ofd, size_t obytes);
//------------------------------------------------------------------------------
// EQUAL
//------------------------------------------------------------------------------
bool equal(const char* str1, const char* str2) {
    return strcmp(str1, str2) == 0;
}
//------------------------------------------------------------------------------
// ARG PARSE
//------------------------------------------------------------------------------
int argParse(int argc, char** argv, FILE** descriptors, size_t** ref) {
    int arg = 1;
    const int size = 12;
    const char* flags[] = {"-i", "-o", "-V", "-h", "--version", "--help",
                           "--input", "--output", "-I", "-O", "--ibuf-bytes",
                           "--obuf-bytes"};

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
                *ref[2] = 1;
                return SUCCESS;
            }
            if (equal(flag, "-V") || equal(flag, "--version")) {
                printf("tp1: version %s\n", VERSION);
                *ref[2] = 1;
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
            if ((equal(flag, "-I") || equal(flag, "--ibuf-bytes")) && !std) {
                *ref[0] = (size_t)atoi(argv[arg]);
            }
            if ((equal(flag, "-O") || equal(flag, "--obuf-bytes")) && !std) {
                *ref[1] = (size_t)atoi(argv[arg]);
            }
            flag = "nullStr";
        }
        arg++;
    }
    return SUCCESS;
}
//------------------------------------------------------------------------------
// MAIN
//------------------------------------------------------------------------------
int main(int argc, char** argv) {
    FILE* fdescriptors[2] = {stdin, stdout};
    size_t ibytes = 1, obytes = 1;
    size_t clean_exit = 0;
    size_t* ref[3] = {&ibytes, &obytes, &clean_exit};
    int s = argParse(argc, argv, fdescriptors, ref);
    if (s == ERROR) return 1;
    if (clean_exit) return 0;  // finalizacion limpia, cuando se usa -h o -V

    FILE* archIn = fdescriptors[0];
    FILE* archOut = fdescriptors[1];
    int fdIn = fileno(archIn);
    int fdOut = fileno(archOut);
    if (fdIn == -1 || fdOut == -1) return 1;

    if (palindrome(fdIn, ibytes, fdOut, obytes) == -1) {
        printf("palindrome returned -1\n");
        return 1;
    }
    if (archIn != stdin && fclose(archOut) == EOF) return 1;
    if (archOut != stdout && fclose(archOut) == EOF) return 1;
    return 0;
}
//------------------------------------------------------------------------------
