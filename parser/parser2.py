#!/bin/python3

import sys

last_was_one = False

if len(sys.argv) != 4:
    print("Usage:",sys.argv[0], "data", "raw")
    sys.exit(1)

def read_data(filename):
    '''
    Filename should be a file with newline delimited numbers
    '''
    data_array = []

    with open(filename) as file:
        # Read and split by newline
        data = file.read().split("\n")
        # Convert to nums
        data = [int(line) for line in data[:-1]]
        
        # Run through all numbers
        for i in range(len(data)):
            num = data[i]
            # If 1, add to list
            if num:
                data_array.append(1)
            else:
                # If zero, check if 1s present both before and ahead
                #   Used for smoothing
                back_min = max(i-100,0)
                back = sum(data[back_min:i])
                forward = sum(data[i:i+100])
                
                if back and forward:
                    data_array.append(1)
                else:
                    data_array.append(0)
    
    return data_array

def clock_bounds(data_array):
    bounds = []
    last = data_array[0]

    for i in range(len(data_array)):
        num = data_array[i]
        if num != last:
            if len(bounds) == 0:
                last = num
                bounds.append(i)
            elif i-bounds[-1] > 7100:
                last = num
                bounds.append(i)
    return bounds

def get_bits(bounds, data_signal):
    bits = []

    for i in range(len(bounds)-1):
        low  = bounds[i]
        high = bounds[i+1]
        size = high-low

        s = sum(data_signal[low:high])
        if s > (size/2):
            bits.append(1)
        else:
            bits.append(0)

    return bits

def write_bits(bit_string, filename):
    with open(filename, "wb") as outfile:
        raw_bytes = [bit_string[i:i+8] for i in range(0,len(bit_string)-8,8)]
        for b in raw_bytes:
            b = int(b,2)
            # Don't print zero bytes
            if not b:
                continue
            outfile.write(b.to_bytes(1, byteorder="big"))

clock_signal = read_data(sys.argv[1])
data_signal  = read_data(sys.argv[2])

bounds = clock_bounds(clock_signal)

last = 0
for b in bounds:
    print(last, b, b-last, sum(data_signal[last:b]))
    last = b

bits = get_bits(bounds, data_signal)

bit_string = ""
for bit in bits:
    bit_string += str(bit)
write_bits(bit_string, sys.argv[3])
