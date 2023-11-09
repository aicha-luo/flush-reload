#include<fcntl.h>
#include<stdio.h>
#include<sys/mman.h>
#include<unistd.h>
#include<time.h>
#include<stdlib.h>
#include<x86intrin.h>

#define PAGE_SIZE 4096
#define READ_SIZE 4096
#define DELAY 100000000
//#define DELAY 1000000000

int main(int argc, char** argv){
	int fd, c, i, j, amount_read;
	unsigned long long t;
	time_t sys_time;
	void *mapaddr;
	volatile int throw_away;
	char buffer[READ_SIZE];
	volatile char* random_heap;

        if(argc!=3){
                printf("Usage: %s shared_file data_file\n", argv[0]);
                return 1;
        }

        // Setup fd of shared_file and mmap
        fd = open(argv[1], O_RDONLY);
	
	// mmap
	mapaddr = mmap(NULL,PAGE_SIZE,PROT_READ,MAP_SHARED,fd,0);
	close(fd);

	// Open data_file
	fd = open(argv[2], O_RDONLY);

	random_heap = (char*)malloc(1);

	// Read until we read zero
	while( (amount_read = read(fd, buffer, READ_SIZE)) ){
		// Run through amount_read bytes
		for(i = 0; i<amount_read; i++){
			// Get byte
			c = buffer[i];
			// Get time
			sys_time = time(0);
			// Transmit bit by bit
			for(j = 0; j<8; j++){
				t = __rdtsc(); 
				do{
					if(c & 0x1){
						throw_away = *((char*)mapaddr);
					}
				}while((__rdtsc()-t)<DELAY);
				c = c >> 1;
			}
		}
	}
}
