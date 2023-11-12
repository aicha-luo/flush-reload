# Flush+Reload

Simple demo
```
# Edit <FILE> in simple_receiver.s
gcc simple_receiver.s
# Open the choosen file while collecting data
./a.out > data
# Ctrl+C to end
./show_graph.py < data
```

Build
```
./build.sh
```

Run
```
(./bin/clock_receiver > clock &); (./bin/data_receiver > data&); ./bin/transmitter sample
```

Parse
```
./parser/parser2.py clock data raw
```

Graph (debug)
```
./show_graph.py < clock
```
