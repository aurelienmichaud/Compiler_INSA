#include <stdio.h>

#include "asm.h"

#define asm_print(__STRING__)					do { fprintf(out, (__STRING__)); } while(0)
#define asm_print0(__STRING__)					do { fprintf(out, __STRING__"\n"); } while(0)
#define asm_printl1(__STRING__, __VAR1__)			do { fprintf(out, __STRING__"\n", (__VAR1__)); } while(0)
#define asm_printl2(__STRING__, __VAR1__, __VAR2__)		do { fprintf(out, __STRING__"\n", (__VAR1__), (__VAR2__)); } while(0)
#define asm_printl3(__STRING__, __VAR1__, __VAR2__, __VAR3__)	do { fprintf(out, __STRING__"\n", (__VAR1__), (__VAR2__), (__VAR3__)); } while(0)

#define _asm_comment(__MSG__)					do { fprintf(out, "; %s\n", (__MSG__)); } while(0)

/*
#define asm_AFC(__ADDRESS__, __VALUE__)			do { asm_print2("AFC @%d, 0x%x", (__ADDRESS__), (__VALUE__)); } while(0)

#define asm_COP(__TO__, __FROM__)			do { asm_print2("COP @%d, @%d", (__TO__), (__FROM__)); } while(0)

#define asm_ADD(__RESULT__, __ADDRESS1__, __ADDRESS2__)	do { asm_print3("ADD @%d, @%d, @%d", (__RESULT__), (__ADDRESS1__), (__ADDRESS2__)); } while(0)
#define asm_MUL(__RESULT__, __ADDRESS1__, __ADDRESS2__)	do { asm_print3("MUL @%d, @%d, @%d", (__RESULT__), (__ADDRESS1__), (__ADDRESS2__)); } while(0)
#define asm_SUB(__RESULT__, __ADDRESS1__, __ADDRESS2__)	do { asm_print3("SOU @%d, @%d, @%d", (__RESULT__), (__ADDRESS1__), (__ADDRESS2__)); } while(0)
*/

void asm_ADD(int res_addr, int op1_addr, int op2_addr)
{
	asm_printl3("ADD @%d, @%d, @%d", res_addr, op1_addr, op2_addr);
}

void asm_SUB(int res_addr, int op1_addr, int op2_addr)
{
	asm_printl3("SOU @%d, @%d, @%d", res_addr, op1_addr, op2_addr);
}

void asm_MUL(int res_addr, int op1_addr, int op2_addr)
{
	asm_printl3("MUL @%d, @%d, @%d", res_addr, op1_addr, op2_addr);
}



void asm_AFC(int to_addr, int value)
{
	asm_printl2("AFC @%d, 0x%x", to_addr, value);
}

void asm_COP(int to_addr, int from_addr)
{
	asm_printl2("COP @%d, @%d", to_addr, from_addr);
}

void asm_comment(char *msg)
{
	_asm_comment(msg);
}

void init_output(FILE *f)
{
	out = f;
}

void asm_push(int value)
{
	Symbol *s = symbol_table_add_tmp_symbol();

	asm_AFC(s->address, value);
}

void asm_push_from_address(int address)
{
	Symbol *s = symbol_table_add_tmp_symbol();

	asm_COP(s->address, address);
}

Symbol *asm_pop()
{
	return symbol_table_pop();
}

