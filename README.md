# Flush+Reload

```
gcc -masm=intel flush_reload.s
./a.out
```

Then in another tab

```
while :; do whoami; done
```

Running whoami in another tab should make the wait time for memory access go down.
