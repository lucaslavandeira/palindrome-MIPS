#include <sys/syscall.h>
#include <mips/regdef.h>
##------------------------------------------------------------------------------
## DEFINITIONS
##------------------------------------------------------------------------------
#define MYMALLOC_SIGNATURE 0xdeadbeef

#ifndef PROT_READ
#define PROT_READ 0x01
#endif

#ifndef PROT_WRITE
#define PROT_WRITE 0x02
#endif

#ifndef MAP_PRIVATE
#define MAP_PRIVATE 0x02
#endif

#ifndef MAP_ANON
#define MAP_ANON 0x1000
#endif
##------------------------------------------------------------------------------
## MY MALLOC
##------------------------------------------------------------------------------
	.text
	.align	2
	.globl	mymalloc
	.ent	mymalloc
mymalloc:
    ##--------------------------------------------------------------------------
    ## Inicializacion del stack frame
    ##--------------------------------------------------------------------------
	subu sp, sp, 56
	sw ra, 48(sp)
	sw $fp, 44(sp)
	sw a0, 40(sp)  # Temporary: original allocation size.
	sw a0, 36(sp)  # Temporary: actual allocation size.
	li t0, -1
	sw t0, 32(sp)  # Temporary: return value (defaults to -1).
#if 0
	sw a0, 28(sp)  # Argument building area (#8?).
	sw a0, 24(sp)  # Argument building area (#7?).
	sw a0, 20(sp)  # Argument building area (#6).
	sw a0, 16(sp)  # Argument building area (#5).
	sw a0, 12(sp)  # Argument building area (#4, a3).
	sw a0,  8(sp)  # Argument building area (#3, a2).
	sw a0,  4(sp)  # Argument building area (#2, a1).
	sw a0,  0(sp)  # Argument building area (#1, a0).
#endif
	move $fp, sp
    ##--------------------------------------------------------------------------
    ## FIN Inicializacion del stack frame
    ##--------------------------------------------------------------------------
	# Adjust the original allocation size to a 4-byte boundary.
	lw	t0, 40(sp)
	addiu t0, t0, 3
	and	t0, t0, 0xfffffffc
	sw	t0, 40(sp)

	# Increment the allocation size by 12 units, in order to 
	# make room for the allocation signature, block size and
	# trailer information.
	lw t0, 40(sp)
	addiu t0, t0, 12
	sw t0, 36(sp)

	# mmap(0, sz, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANON, -1, 0)
	li v0, SYS_mmap
	li a0, 0
	lw a1, 36(sp)
	li a2, PROT_READ|PROT_WRITE
	li a3, MAP_PRIVATE|MAP_ANON

	# According to mmap(2), the file descriptor 
	# must be specified as -1 when using MAP_ANON.
	li t0, -1
	sw t0, 16(sp)

	# Use a trivial offset.
	li t0, 0
	sw t0, 20(sp)

	# XXX TODO.
	sw zero, 24(sp)
	sw zero, 28(sp)

	# Excecute the syscall, save the return value.
	syscall
	sw v0, 32(sp)
	beqz v0, mymalloc_return

	# Success. Check out the allocated pointer.
	lw t0, 32(sp)
	li t1, MYMALLOC_SIGNATURE
	sw t1, 0(t0)

	# The actual allocation size goes right after the signature.
	lw t0, 32(sp)
	lw t1, 36(sp)
	sw t1,  4(t0)

	# Trailer information.
	lw t0, 36(sp) # t0: actual allocation size.
	lw t1, 32(sp) # t1: Pointer.
	addu t1, t1, t0 # t1 now points to the trailing 4-byte area.
	xor	t2, t0, MYMALLOC_SIGNATURE
	sw	t2, -4(t1)

	# Increment the result pointer.
	lw t0, 32(sp)
	addiu t0, t0, 8
	sw t0, 32(sp)

mymalloc_return:
	# Restore the return value.
	lw v0, 32(sp)
	# Destroy the stack frame.
	move sp, $fp
	lw ra, 48(sp)
	lw $fp, 44(sp)
	addu sp, sp, 56
	j ra
	.end mymalloc
##------------------------------------------------------------------------------
## MY FREE
##------------------------------------------------------------------------------
	.globl myfree
	.ent myfree
myfree:
	subu sp, sp, 40
	sw ra, 32(sp)
	sw $fp, 28(sp)
	sw a0, 24(sp)  # Temporary: argument pointer.
	sw a0, 20(sp)  # Temporary: actual mmap(2) pointer.
	move $fp, sp

	# Calculate the actual mmap(2) pointer.
	lw	t0, 24(sp)
	subu t0, t0, 8
	sw t0, 20(sp)

	# XXX Sanity check: the argument pointer must be checked
	# in before we try to release the memory block.
	# First, check the allocation signature.
	lw	t0, 20(sp) # t0: actual mmap(2) pointer.
	lw	t1, 0(t0)
	bne	t1, MYMALLOC_SIGNATURE, myfree_die

	# Second, check the memory block trailer.
	lw t0, 20(sp) # t0: actual mmap(2) pointer.
	lw t1, 4(t0)  # t1: actual mmap(2) block size.
	addu t2, t0, t1 # t2: trailer pointer.
	lw t3, -4(t2)
	xor	t3, t3, t1
	bne	t3, MYMALLOC_SIGNATURE, myfree_die

	# All checks passed. Try to free this memory area.
	li v0, SYS_munmap
	lw a0, 20(sp) # a0: actual mmap(2) pointer.
	lw a1, 4(a0)  # a1: actual allocation size.
	syscall

	# Bail out if we cannot unmap this memory block.
	bnez v0, myfree_die

	# Success.
	j myfree_return

myfree_die:
	# Generate a segmentation fault by writing to the first
	# byte of the address space (a.k.a. the NULL pointer).
	sw t0, 0(zero)

myfree_return:
	# Destroy the stack frame.
	move sp, $fp
	lw ra, 32(sp)
	lw $fp, 28(sp)
	addu sp, sp, 40
	j ra
	.end myfree
##------------------------------------------------------------------------------
