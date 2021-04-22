.PHONY: all clean test-w-lib test-wo-lib test-w-libmul
.PRECIOUS: libsquare.so 


all: clean test-wo-lib test-w-lib

test-wo-lib: add.o mul.o square.o test-wo-lib.o
	$(CC) -o ${@} ${^}
	./${@}

test-w-lib: test-w-lib.o libsquare.so
	$(CC) -o ${@} ${<} -ldl 
	./${@}

test-w-libmul: test-w-libmul.o libmul.a
	$(CC) -o ${@} ${<} libmul.a
	./${@}

libsquare.so: square.o libmul.a
	rm -rf libmul; 	mkdir libmul; cd libmul; ar x ../libmul.a
	gcc -shared -Wl,-soname=square -o ${@} ${<} libmul/*.o

%.o: %.c
	$(CC) -fPIC -rdynamic -o ${@} -c ${^}

clean: 
	rm -f *.o *.a *.so test-*-lib

libadd.a: add.o
	ar rcs ${@} ${^}
	ranlib ${@}

libmul.a: mul.o libadd.a
	rm -rf libadd; mkdir libadd; cd libadd; ar x ../libadd.a
	ar rcs ${@} ${<} ./libadd/*.o
	ranlib ${@}
