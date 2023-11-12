.intel_syntax noprefix
.section .rodata


DATA_FILE:
	.string "<FILE>"
	.word 0

FORMAT:
	.string "%d\n"
	.word 0

.text

shared_mem:
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
	ret

.global main
main:

	// Calling convention for userland
	//	%rdi, %rsi, %rdx, %rcx, %r8 and %r9
	
	// MMAP data_file (rax)
	lea rdi, DATA_FILE[rip]
	call shared_mem
	
	// Put mmap addr in rbx
	mov rbx, rax
	xor rdx, rdx

	// Fix frame for printf
	push rcx

	// flush+reload
	.hot_loop:
		// Do flush
		clflush [rbx]
		
		// do_nothing()*eax
		//	forces us to wait.
		//	Not great, but using usleep introduced noise
		rdtsc
		mov esi, eax
		.wait_loop:
			rdtsc
			sub eax, esi
			cmp eax, 50000
			jle .wait_loop
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
		// Defined as cache hit if <200
		cmp eax, 230
		jle .is_one
		mov eax, 0
		jmp .is_after
		.is_one:
		// 200 instructions to simulate load
		// Keep us on track
		//mov eax, 200
		//.fake_load:
		//	nop
		//	sub eax, 1
		//	jnz .fake_load
		mov eax, 1
		.is_after:
		
		// Print result (1 or 0)
		lea rdi, FORMAT[rip] 
		mov esi, eax
		xor eax, eax
		call printf

		jmp .hot_loop
	ret
