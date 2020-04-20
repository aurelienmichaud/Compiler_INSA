
test: comp
	./a.out < sample.c

comp: asm.o symbol_table.o y.tab.o lex.yy.o
	gcc -Wall asm.o symbol_table.o y.tab.o lex.yy.o

y.tab.o: syntax.y
	#yacc --debug --verbose -d syntax.y
	yacc -d syntax.y
	gcc -c y.tab.c

symbol_table.o: symbol_table.c symbol_table.h
	gcc -c symbol_table.c

asm.o: asm.c asm.h
	gcc -c asm.c

lex.yy.o: lex_source.l
	lex lex_source.l
	gcc -c lex.yy.c

printf:  printf_y_tab lex.yy.o
	gcc -Wall y.tab.o lex.yy.o

printf_y_tab:
	yacc --debug --verbose -d syntax_printf.y
	#yacc -d syntax_printf.y
	gcc -c y.tab.c

.PHONY: clean

clean:
	rm -f a.out asm.o symbol_table.o y.tab.o y.tab.c y.tab.h* y.output lex.yy.c lex.yy.o lex_source.o lex_source.c
