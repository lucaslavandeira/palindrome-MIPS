#include <sys/syscall.h>
#include <mips/regdef.h>
#ifndef SF_SIZE
#define SF_SIZE 48
#endif

#ifndef RA_POS
#define RA_POS SF_SIZE-8
#endif

#ifndef GP_POS
#define GP_POS RA_POS-4
#endif

#ifndef FP_POS
#define FP_POS GP_POS-4
#endif

#ifndef IFD_POS
#define IFD_POS STACK_FRAME_SIZE
#endif

#ifndef IBYTES_POS
#define IBYTES STACK_FRAME_SIZE+4
#endif

#ifndef OFD_POS
#define OFD_POS STACK_FRAME_SIZE+8
#endif

#ifndef OBYTES_POS
#define OBYTES STACK_FRAME_SIZE+12
#endif
