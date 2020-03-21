test: comp
	./a.out < sample.c

comp: symbol_table.o y.tab.o lex.yy.o
	gcc -Wall symbol_table.o y.tab.o lex.yy.o

y.tab.o: syntax.y
	#yacc --debug --verbose -d syntax.y
	yacc -d syntax.y
	gcc -c y.tab.c

symbol_table.o: symbol_table.c symbol_table.h
	gcc -c symbol_table.c

lex.yy.o: lex_source.l
	lex lex_source.l
	gcc -c lex.yy.c

.PHONY: clean

clean:
	rm -f a.out symbol_table.o y.tab.o y.tab.c lex.yy.c lex.yy.o
