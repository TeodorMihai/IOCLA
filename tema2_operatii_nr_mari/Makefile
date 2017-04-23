CC = gcc
CFLAGS = -g -m32 -Wall
LDFLAGS = -g -m32 -Wall

.PHONY: all clean pack

all: calc

calc: main.o calc.o macro.o

main.o: main.c util.h

calc.o: calc.asm io.inc
	nasm -f elf32 $<

macro.o: macro.c

pack:
	zip -r iocla-tema2-submisie.zip main.c macro.c calc.asm io.inc util.h README Makefile

clean:
	-rm -fr calc
	-rm -fr *~
	-rm -fr *.o
