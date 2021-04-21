.PHONY: all clean all-w-lib all-wo-lib

all: clean test-wo-lib test-w-lib

test-wo-lib: add.o mul.o square.o test-wo-lib.o
	$(CC) -o ${@} ${^}
	./${@}

test-w-lib: libsquare.so test-w-lib.o
	$(CC) -o ${@} ${^} -ldl 
	./${@}

libsquare.so: square.o libmul.a
	gcc -shared -Wl,-soname=square -o ${@} ${^} 

%.o: %.c
	$(CC) -fPIC -rdynamic -o ${@} -c ${^}

clean: 
	rm -f *.o *.a *.so test-*-lib

libadd.a: add.o
	ar rcs ${@} ${^}
	ranlib ${@}

libmul.a: mul.o libadd.a
	ar rcs ${@} ${^}
	ranlib ${@}
