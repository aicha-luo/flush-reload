#!/bin/python3

'''
Create graph of flush+reload data,
taking data from stdin,
in the form of newline delimited numbers
'''

import matplotlib.pyplot as plt
import sys

# Hold multiple x values
xs = []

# Hold multiple y values
ys = []

xc = 0
for line in sys.stdin:
    tokens = line.split(",")

    try:
        x = xc
        y = float(tokens[0])
    except:
        print("Invalid line",line)
        sys.exit()
    
    xs.append(x)
    ys.append(y)

    xc += 1
# Set title to second command argument
if len(sys.argv) > 1:
    plt.title(sys.argv[1])

plt.plot(xs,ys)
plt.show()
