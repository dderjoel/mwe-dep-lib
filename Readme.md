# Problem
This is a MWE for [this SO Question]( https://stackoverflow.com/ )

## Situation
I hava a __static library__ `libadd.a`, which can add two numbers `int add(int, int);`.
I hava another __static library__ `libmul.a`, which can add multiply two numbers `int mul(int, int);` using a loop and calling add from `libadd.a`.
I have a __dynamic library__ `libsquare.so`, utilising `libmul.a` to be able to provide `int square(int);` (see `square.h`)

## Problem Desription

test-w-lib is a testprogram, which `dlopen`s `./libsquare.so`, gets the required symbol `square` and tries to execute it.
This fails, because the symbol `add` cannot be found (`in libsquare.so`). Fair.
`objdump`ing it reveals, that `libsquare.so` only has `square` and `mul` as code, and `add` only as `*UND*`.

## Questions

1. Why is that?
1. How can I have `libmul.a` and its dependencies (in this MWE: `libadd.a`) being statically linked into the shared object `libsquare.so`?


### Notes

Here is some interesting output

#### $ make test-wo-lib

```bash
$ make test-wo-lib

rm -f *.o *.a *.so test-*-lib
cc -fPIC -rdynamic -o add.o -c add.c
cc -fPIC -rdynamic -o mul.o -c mul.c
cc -fPIC -rdynamic -o square.o -c square.c
cc -fPIC -rdynamic -o test-wo-lib.o -c test-wo-lib.c
cc -o test-wo-lib add.o mul.o square.o test-wo-lib.o
./test-wo-lib
0^2 = 0 (check: 0)
1^2 = 1 (check: 1)
2^2 = 4 (check: 4)
3^2 = 9 (check: 9)
4^2 = 16 (check: 16)
5^2 = 25 (check: 25)
6^2 = 36 (check: 36)
7^2 = 49 (check: 49)
8^2 = 64 (check: 64)
9^2 = 81 (check: 81)
```

#### $ make test-w-lib
```bash
$ make test-w-lib

ar rcs libadd.a add.o
ranlib libadd.a
ar rcs libmul.a mul.o libadd.a
ranlib libmul.a
gcc -shared -Wl,-soname=square -o libsquare.so square.o libmul.a 
cc -fPIC -rdynamic -o test-w-lib.o -c test-w-lib.c
cc -o test-w-lib libsquare.so test-w-lib.o -ldl 
/usr/bin/ld: libsquare.so: undefined reference to `add'
collect2: error: ld returned 1 exit status
make: *** [Makefile:10: test-w-lib] Error 1
```


#### $ objdump -t libmul.a
```bash
$ objdump -t libmul.a

In archive libmul.a:

mul.o:     file format elf64-x86-64

SYMBOL TABLE:
0000000000000000 l    df *ABS*	0000000000000000 mul.c
0000000000000000 l    d  .text	0000000000000000 .text
0000000000000000 g     F .text	000000000000003b mul
0000000000000000         *UND*	0000000000000000 _GLOBAL_OFFSET_TABLE_
0000000000000000         *UND*	0000000000000000 add


In nested archive libadd.a:

add.o:     file format elf64-x86-64

SYMBOL TABLE:
0000000000000000 l    df *ABS*	0000000000000000 add.c
0000000000000000 l    d  .text	0000000000000000 .text
0000000000000000 g     F .text	0000000000000014 add
```

#### $ objdump -t libsquare.so
```bash
$ objdump -t libsquare.so

libsquare.so:     file format elf64-x86-64

SYMBOL TABLE:
0000000000000000 l    df *ABS*	0000000000000000              crtstuff.c
0000000000001050 l     F .text	0000000000000000              deregister_tm_clones
0000000000001080 l     F .text	0000000000000000              register_tm_clones
00000000000010c0 l     F .text	0000000000000000              __do_global_dtors_aux
0000000000004030 l     O .bss	0000000000000001              completed.0
0000000000003e08 l     O .fini_array	0000000000000000              __do_global_dtors_aux_fini_array_entry
0000000000001110 l     F .text	0000000000000000              frame_dummy
0000000000003e00 l     O .init_array	0000000000000000              __frame_dummy_init_array_entry
0000000000000000 l    df *ABS*	0000000000000000              square.c
0000000000000000 l    df *ABS*	0000000000000000              mul.c
0000000000000000 l    df *ABS*	0000000000000000              crtstuff.c
00000000000020a8 l     O .eh_frame	0000000000000000              __FRAME_END__
0000000000000000 l    df *ABS*	0000000000000000              
0000000000001170 l     F .fini	0000000000000000              _fini
0000000000004028 l     O .data	0000000000000000              __dso_handle
0000000000003e10 l     O .dynamic	0000000000000000              _DYNAMIC
0000000000002000 l       .eh_frame_hdr	0000000000000000              __GNU_EH_FRAME_HDR
0000000000004030 l     O .data	0000000000000000              __TMC_END__
0000000000004000 l     O .got.plt	0000000000000000              _GLOBAL_OFFSET_TABLE_
0000000000001000 l     F .init	0000000000000000              _init
0000000000000000  w      *UND*	0000000000000000              _ITM_deregisterTMCloneTable
0000000000000000         *UND*	0000000000000000              add
0000000000001119 g     F .text	000000000000001c              square
0000000000000000  w      *UND*	0000000000000000              __gmon_start__
0000000000001135 g     F .text	000000000000003b              mul
0000000000000000  w      *UND*	0000000000000000              _ITM_registerTMCloneTable
0000000000000000  w    F *UND*	0000000000000000              __cxa_finalize@GLIBC_2.2.5
```
