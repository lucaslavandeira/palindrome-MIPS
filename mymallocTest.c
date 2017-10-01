#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
//------------------------------------------------------------------------------
// EXTERNAL FUNCTIONS
//------------------------------------------------------------------------------
extern void* mymalloc(size_t size);
extern void myfree(void* pointer);
extern void* myrealloc(void* pointer, size_t newSize);
//------------------------------------------------------------------------------
// TEST FUNCTION
//------------------------------------------------------------------------------
/*void* myrealloc(void* pointer, size_t newSize) {
    char* aux = (char*) mymalloc(newSize);
    if (aux == NULL) return NULL;
    for (size_t i = 0; i < newSize; i++) aux[i] = ((char*) pointer)[i];
    myfree(pointer);
    return (void*) aux;
}*/
//------------------------------------------------------------------------------
// MAIN
//------------------------------------------------------------------------------
int main() {
    const size_t size = 20;
    size_t* buffer =  (size_t*) mymalloc(sizeof(size_t) * size);
    if (!buffer) {
        printf("function mymalloc returned NULL: ....ERROR\n");
        return 1;
    }
    for (size_t i = 0; i < size; i++) buffer[i] = i;
    printf("function mymalloc success: ....OK\n");
    size_t* aux =  (size_t*) myrealloc(buffer, sizeof(size_t) * 2 * size);
    if (!aux) {
        printf("function realloc returned NULL: ....ERROR\n");
        myfree(buffer);
        return 1;
    }
    buffer = aux;
    for (size_t i = size; i < 2 * size; i++) buffer[i] = i;
    myfree(buffer);
    printf("function realloc success: ....OK\n");
    return 0;
}
//------------------------------------------------------------------------------
