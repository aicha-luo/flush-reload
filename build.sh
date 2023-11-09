#!/bin/sh

mkdir -p ./bin
gcc -o ./bin/receiver receiver.s
gcc -g -o ./bin/transmitter transmitter.c
