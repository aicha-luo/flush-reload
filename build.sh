#!/bin/sh

CLOCK_FILE="/bin/whoami"
DATA_FILE="/bin/sudo"

mkdir -p ./bin
mkdir -p ./tmp

sed 's@<FILE>@'"$CLOCK_FILE"'@' receiver.s > ./tmp/clock_receiver.s
gcc -o ./bin/clock_receiver ./tmp/clock_receiver.s

sed 's@<FILE>@'"$DATA_FILE"'@' receiver.s > ./tmp/data_receiver.s
gcc -o ./bin/data_receiver ./tmp/data_receiver.s

# Transmits both data/clock
gcc -g -o ./bin/transmitter transmitter.c
