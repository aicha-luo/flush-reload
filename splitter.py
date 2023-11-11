#!/bin/python3

import sys

if len(sys.argv) != 2:
    print("Usage:",sys.argv[0],"combined_file")
    sys.exit(1)

is_clock = False
with open(sys.argv[1]) as combined, open("clock", "w") as clock, open("data", "w") as data:
    for line in combined:
        if is_clock:
            clock.write(line)
        else:
            data.write(line)

        is_clock = not is_clock
