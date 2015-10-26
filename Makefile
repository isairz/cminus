#
# Makefile for C-Minus
# Gnu C Version
# K. Louden 2/3/98
#
# Modified by Seongjun Kim, 2015

CC = gcc

CFLAGS = -Wall -g

OBJS = cminus.tab.o lex.yy.o main.o util.o symtab.o analyze.o code.o cgen.o

cminus: $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o cminus

main.o: main.c globals.h util.h scan.h analyze.h cgen.h
	$(CC) $(CFLAGS) -c main.c

util.o: util.c util.h globals.h
	$(CC) $(CFLAGS) -c util.c

symtab.o: symtab.c symtab.h
	$(CC) $(CFLAGS) -c symtab.c

analyze.o: analyze.c globals.h symtab.h analyze.h
	$(CC) $(CFLAGS) -c analyze.c

code.o: code.c code.h globals.h
	$(CC) $(CFLAGS) -c code.c

cgen.o: cgen.c globals.h symtab.h code.h cgen.h
	$(CC) $(CFLAGS) -c cgen.c

lex.yy.o: cminus.l scan.h util.h globals.h
	flex -o lex.yy.c cminus.l
	$(CC) $(CFLAGS) -c lex.yy.c

cminus.tab.o: cminus.y globals.h
	bison -d cminus.y
	$(CC) $(CFLAGS) -c cminus.tab.c

clean:
	-rm cminus
	-rm cminus.tab.c
	-rm cminus.tab.h
	-rm lex.yy.c
	-rm $(OBJS)

test: cminus
	-./cminus test.cm

all: cminus
