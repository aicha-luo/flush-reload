#!/bin/sh

mkdir -p ./bin

gcc -o ./bin/receiver receiver.s

# Transmits both data/clock
gcc -O2 -o ./bin/transmitter transmitter.c
