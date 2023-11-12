#include<fcntl.h>
#include<stdio.h>
#include<sys/mman.h>
#include<unistd.h>
#include<stdlib.h>
#include<x86intrin.h>

#define PAGE_SIZE 4096
#define READ_SIZE 4096
#define DELAY 100000000

#define SHARED_FILE "/bin/sudo"
#define CLOCK_FILE "/bin/whoami"

void* mmap_file(char* filename){
	int fd;
	void* result;
        
	// Setup fd of shared_file and mmap
        fd = open(filename, O_RDONLY);	
	// mmap
	result = mmap(NULL,PAGE_SIZE,PROT_READ,MAP_SHARED,fd,0);
	close(fd);

	return result;
}

int main(int argc, char** argv){
	int fd, i, j, amount_read;
	unsigned long long t;
	void *shared_mapaddr, *clock_mapaddr;
	volatile int throw_away;
	char buffer[READ_SIZE];
	unsigned char c, clock_on;

        if(argc!=2){
                printf("Usage: %s data_file\n", argv[0]);
                return 1;
        }

	shared_mapaddr = mmap_file(SHARED_FILE);
	clock_mapaddr = mmap_file(CLOCK_FILE);

	// Open data_file
	fd = open(argv[1], O_RDONLY);

	clock_on = 0xF;

	usleep(10000); // Sleep before starting

	// Read until we read zero
	while( (amount_read = read(fd, buffer, READ_SIZE)) ){
		// Run through amount_read bytes
		for(i = 0; i<amount_read; i++){
			// Get byte
			c = buffer[i];
			// Transmit bit by bit
			for(j = 0; j<8; j++){
				t = __rdtsc(); 
				do{
					if(clock_on){
						throw_away = *((char*)clock_mapaddr);
					}
					if(c & 0x80){
						throw_away = *((char*)shared_mapaddr);
					}
				}while((__rdtsc()-t)<DELAY);
				// Next bit from data
				c = c << 1;
				// Flip clock
				if(clock_on) clock_on = 0;
				else clock_on = 0xF;
			}
		}
	}
}
