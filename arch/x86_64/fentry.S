/* argument passing: %rdi, %rsi, %rdx, %rcx, %r8, %r9 */
/* return value: %rax */
/* callee saved: %rbx, %rbp, %rsp, %r12-r15 */
/* stack frame (with -pg): return addr = 8(%rbp), prev fp = 0(%rbp) */
/* stack frame (with -fentry): return addr = (%rsp), prev fp = 8(%rsp) */

.globl __fentry__
__fentry__:
	pushq %rdi
	pushq %rsi
	pushq %rdx
	pushq %rcx
	pushq %r8
	pushq %r9
	pushq %rax

	/* child ip */
	movq 56(%rsp), %rsi
	/* parent ip */
	movq 64(%rsp), %rdi

	call mcount_entry
	cmpq $0, %rax
	jne 1f

	/* hijack return address */
	movabs $fentry_return@GOTOFF, %rdx
	lea _GLOBAL_OFFSET_TABLE_(%rip), %rcx
	add %rcx, %rdx
	movq %rdx, 64(%rsp)
1:
	popq %rax
	popq %r9
	popq %r8
	popq %rcx
	popq %rdx
	popq %rsi
	popq %rdi
	retq

.type __fentry__, @function
.size __fentry__, .-__fentry__


fentry_return:
	pushq %rax
	pushq %rax

	/* returns original parent address */
	call mcount_exit

	movq %rax, 8(%rsp)
	popq %rax
	retq

.type fentry_return, @function
.size fentry_return, .-fentry_return