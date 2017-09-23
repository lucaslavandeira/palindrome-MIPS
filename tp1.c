<<<<<<< HEAD
=======
#define _POSIX_C_SOURCE 1 // Necesario para la función fileno
>>>>>>> 16417634e7e1a1b730745b216929de4b95f7e9ec
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
<<<<<<< HEAD
#define VERSION "0.2"
const char help_str[] = "Usage:\n"
        "  tp0 -h\n"
        "  tp0 -V\n"
        "  tp0 [options]\n"
=======
#define VERSION "dev"

const char help_str[] = "Usage:\n"
        "  tp1 -h\n"
        "  tp1 -V\n"
        "  tp1 [options]\n"
>>>>>>> 16417634e7e1a1b730745b216929de4b95f7e9ec
        "Options:\n"
        "  -V, --version\tPrint version and quit.\n"
        "  -h, --help\tPrint this information.\n"
        "  -i, --input\tLocation of the input file.\n"
        "  -o, --output\tLocation of the output file.\n"
<<<<<<< HEAD
        "Examples:\n"
        "  tp0 -i ~/input -o\n";
#define SPACE_SIZE 65
#define SPACE_INDEX 123
#define EMPTY (-1)
const char ENTER = '\n';
char space[SPACE_SIZE];
int spaceIndex[SPACE_INDEX];
extern int palindrome(int ifd, size_t ibytes, int ofd, size_t obytes);
//------------------------------------------------------------------------------
// CHARGE SPACE
//------------------------------------------------------------------------------
// Del 97 al 122 estan las letras de a-z
// Del 65 al 90 estan las letras de A-Z
// Del 48 al 57 estan los numeros de 0-9
// '-' es 45
// '_' es 95
void chargeSpace() {
    int pos = 0;
    for (int i = 0; i < SPACE_INDEX; i++) spaceIndex[i] = EMPTY;
    //--------------------------------------------------------------------------
    for (int i = 97; i <= 122; i++) {
        space[pos] = (char)i;
        spaceIndex[i] = pos;
        pos++;
    }
    //--------------------------------------------------------------------------
    for (int i = 65; i <= 90; i++) {
        space[pos] = (char)i;
        spaceIndex[i] = pos;
        pos++;
    }
    //--------------------------------------------------------------------------
    for (int i = 48; i <= 57; i++) {
        space[pos] = (char)i;
        spaceIndex[i] = pos;
        pos++;
    }
    //--------------------------------------------------------------------------
    // incluyo el guion medio
    pos++;
    space[pos] = '-';
    spaceIndex[45] = pos;
    //--------------------------------------------------------------------------
    // incluyo el guion bajo
    pos++;
    space[pos] = '_';
    spaceIndex[95] = pos;
}
//------------------------------------------------------------------------------
// BELONGS TO SPACE
//------------------------------------------------------------------------------
bool belongsToSpace(int aChar) {
    if (aChar >= SPACE_INDEX) return false;
    return spaceIndex[aChar] != EMPTY;
}
=======
        "  -I, --ibuf-bytes\tByte-count of the input buffer."
        "  -O, --obuf-bytes\tByte-count of the output buffer."
        "Examples:\n"
        "  tp1 -i ~/input -o\n";
>>>>>>> 16417634e7e1a1b730745b216929de4b95f7e9ec
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
<<<<<<< HEAD
                printf("tp0: version %s\n", VERSION);
=======
                printf("tp1: version %s\n", VERSION);
>>>>>>> 16417634e7e1a1b730745b216929de4b95f7e9ec
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
<<<<<<< HEAD
//------------------------------------------------------------------------------
// MAIN
//------------------------------------------------------------------------------
int main(int argc, char** argv) {
    FILE* fdescriptors[2] = {stdin, stdout};
    int clean_exit = 0;
    if (argParse(argc, argv, fdescriptors, &clean_exit) == ERROR) return 1;
    if (clean_exit) return 0;  // finalizacion limpia, cuando se usa -h o -V
    chargeSpace();

    FILE* archIn = fdescriptors[0];
    FILE* archOut = fdescriptors[1];
    int fdIn = fileno(archIn);
    int fdOut = fileno(archOut);
    if (fdIn == -1 || fdOut == -1) return 1;

    size_t ibytes = 0, obytes = 0;
    if (palindrome(fdIn, ibytes, fdOut, obytes) < 0) return 1;

    if (readStdin(fdescriptors[1]) == ERROR) return 1;
    if (fdescriptors[1] != stdout && fclose(fdescriptors[1]) == EOF) return 1;
    if (fdescriptors[0] != stdin && fclose(fdescriptors[0]) == EOF) return 1;
    return 0;
}
//------------------------------------------------------------------------------
=======

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

>>>>>>> 16417634e7e1a1b730745b216929de4b95f7e9ec
