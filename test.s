.intel_syntax noprefix
.section .rodata
FILENAME:
	.string "/bin/whoami"

FORMAT:
	.string "%d\n"
	.word 0

.text

.global main
main:
	//%rdi, %rsi, %rdx, %rcx, %r8 and %r9
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
	// flush+reload
	.hot_loop:
		// Do flush
		//clflush [rbx]
		push rdx
		mov     edi, 10000
		call    usleep
		pop rdx
		xor rdx, rdx
		lfence
		nop
		// do_nothing()x100
		// get timestamp	
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
		
		push rbx
		lea rdi, FORMAT[rip] 
		mov esi, eax
		xor eax, eax
		call printf
		pop rbx
		jmp .hot_loop
	ret	
