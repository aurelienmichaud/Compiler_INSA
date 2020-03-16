test: comp
	./a.out < sample.c

comp: y.tab.o lex.yy.o
	gcc -Wall y.tab.o lex.yy.o

y.tab.o: syntax.y
	#yacc --debug --verbose -d syntax.y
	yacc -d syntax.y
	gcc -c y.tab.c

lex.yy.o: lex_source.l
	lex lex_source.l
	gcc -c lex.yy.c

.PHONY: clean

clean:
	rm -f a.out y.tab.o y.tab.c lex.yy.c lex.yy.o
