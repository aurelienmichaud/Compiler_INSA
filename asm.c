#include <stdio.h>

#include "asm.h"

/*
#define asm_print(__STRING__)					do { fprintf(out, (__STRING__)); } while(0)
#define asm_printl0(__STRING__)					do { fprintf(out, __STRING__"\n"); } while(0)
#define asm_printl1(__STRING__, __VAR1__)			do { fprintf(out, __STRING__"\n", (__VAR1__)); } while(0)
#define asm_printl2(__STRING__, __VAR1__, __VAR2__)		do { fprintf(out, __STRING__"\n", (__VAR1__), (__VAR2__)); } while(0)
#define asm_printl3(__STRING__, __VAR1__, __VAR2__, __VAR3__)	do { fprintf(out, __STRING__"\n", (__VAR1__), (__VAR2__), (__VAR3__)); } while(0)
*/

/*
#define asm_AFC(__ADDRESS__, __VALUE__)			do { asm_print2("AFC @%d, 0x%x", (__ADDRESS__), (__VALUE__)); } while(0)

#define asm_COP(__TO__, __FROM__)			do { asm_print2("COP @%d, @%d", (__TO__), (__FROM__)); } while(0)

#define asm_ADD(__RESULT__, __ADDRESS1__, __ADDRESS2__)	do { asm_print3("ADD @%d, @%d, @%d", (__RESULT__), (__ADDRESS1__), (__ADDRESS2__)); } while(0)
#define asm_MUL(__RESULT__, __ADDRESS1__, __ADDRESS2__)	do { asm_print3("MUL @%d, @%d, @%d", (__RESULT__), (__ADDRESS1__), (__ADDRESS2__)); } while(0)
#define asm_SUB(__RESULT__, __ADDRESS1__, __ADDRESS2__)	do { asm_print3("SOU @%d, @%d, @%d", (__RESULT__), (__ADDRESS1__), (__ADDRESS2__)); } while(0)
*/

typedef enum _instruction_opcode {
	ADD,
	SUB,
	MUL,

	AFC,
	COP,
	JMF,
	
	NB_OF_INSTRUCTIONS
} instruction_opcode;


typedef struct {

	instruction_opcode opcode;	
	int op1;
	int op2;
	int op3;

} ASM_instruction;

#define ASM_INSTRUCTION_TABLE_SIZE	1024

ASM_instruction asm_instruction_table[ASM_INSTRUCTION_TABLE_SIZE];

int asm_instruction_table_index = 0;

static inline ASM_instruction *get_next_instruction_slot()
{
	return &(asm_instruction_table[asm_instruction_table_index++]);
}

void display_asm_instruction_table(void)
{
	int i;
	for (i = 0; i < asm_instruction_table_index; i++) {

		ASM_instruction *ins = &asm_instruction_table[i];
		switch (ins->opcode) {

			case ADD:
				fprintf(out, "ADD %d, %d, %d\n", ins->op1, ins->op2, ins->op3);
				break;
			case SUB:
				fprintf(out, "SUB %d, %d, %d\n", ins->op1, ins->op2, ins->op3);
				break;
			case MUL:
				fprintf(out, "MUL %d, %d, %d\n", ins->op1, ins->op2, ins->op3);
				break;

			case AFC:
				fprintf(out, "AFC %d, %d\n", ins->op1, ins->op2);
				break;
			case COP:
				fprintf(out, "COP %d, %d\n", ins->op1, ins->op2);
				break;
			case JMF:
				fprintf(out, "JMF %d, %d\n", ins->op1, ins->op2);
				break;
	
			default:
				break;
		}
	}
}


/*
static inline void asm_print(char *str)
{
	fprintf(out, str);
}

static inline void asm_print1(char *str, int var1)
{
	fprintf(out, str, var1);
}

static inline void asm_print2(char *str, int var1, int var2)
{
	fprintf(out, str, var1, var2);
}

static inline void asm_print3(char *str, int var1, int var2, int var3)
{
	fprintf(out, str, var1, var2, var3);
}
*/




void asm_ADD(int res_addr, int op1_addr, int op2_addr)
{
	//asm_print3("ADD @%d, @%d, @%d", res_addr, op1_addr, op2_addr);

	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= ADD;
	i->op1			= res_addr;
	i->op2			= op1_addr;
	i->op3			= op2_addr;
}

void asm_SUB(int res_addr, int op1_addr, int op2_addr)
{
	//asm_print3("SOU @%d, @%d, @%d", res_addr, op1_addr, op2_addr);

	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= SUB;
	i->op1			= res_addr;
	i->op2			= op1_addr;
	i->op3			= op2_addr;
}

void asm_MUL(int res_addr, int op1_addr, int op2_addr)
{
	//asm_print3("MUL @%d, @%d, @%d", res_addr, op1_addr, op2_addr);

	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= MUL;
	i->op1			= res_addr;
	i->op2			= op1_addr;
	i->op3			= op2_addr;
}



void asm_AFC(int to_addr, int value)
{
	//asm_print2("AFC @%d, 0x%x", to_addr, value);

	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= AFC;
	i->op1			= to_addr;
	i->op2			= value;
}

void asm_COP(int to_addr, int from_addr)
{
	//asm_print2("COP @%d, @%d", to_addr, from_addr);

	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= COP;
	i->op1			= to_addr;
	i->op2			= from_addr;
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

