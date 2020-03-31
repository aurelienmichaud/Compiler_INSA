#include <stdio.h>

#include "asm.h"


typedef enum _instruction_opcode {
	ADD,
	MUL,
	SOU,
	DIV,

	COP,
	AFC,
	JMP,
	JMF,

	INF,
	SUP,
	EQU,

	PRI,
	
	NB_OF_INSTRUCTIONS
} instruction_opcode;


#define JMP_NOT_FINISHED	0
#define JMP_FINISHED		0

typedef struct {

	instruction_opcode opcode;	
	int op1;
	int op2;
	int op3;

} ASM_instruction;

#define ASM_INSTRUCTION_TABLE_SIZE	1024
#define DEBUG	1

ASM_instruction asm_instruction_table[ASM_INSTRUCTION_TABLE_SIZE];

int asm_instruction_table_index = 0;

static inline ASM_instruction *get_next_instruction_slot()
{
	if (asm_instruction_table_index < ASM_INSTRUCTION_TABLE_SIZE)
		return &(asm_instruction_table[asm_instruction_table_index++]);
	return NULL;
}

void display_asm_instruction_table(void)
{
	int i;
	for (i = 0; i < asm_instruction_table_index; i++) {

		ASM_instruction *ins = &asm_instruction_table[i];

		char str[10];
		snprintf(str, 10, "%3d: ", i);

		switch (ins->opcode) {
			
			case ADD:
				fprintf(out, "%sADD %d, %d, %d\n", (DEBUG ? str : ""), ins->op1, ins->op2, ins->op3);
				break;
			case SOU:
				fprintf(out, "%sSOU %d, %d, %d\n", (DEBUG ? str : ""), ins->op1, ins->op2, ins->op3);
				break;
			case MUL:
				fprintf(out, "%sMUL %d, %d, %d\n", (DEBUG ? str : ""), ins->op1, ins->op2, ins->op3);
				break;


			case AFC:
				fprintf(out, "%sAFC %d, %d\n", (DEBUG ? str : ""), ins->op1, ins->op2);
				break;
			case COP:
				fprintf(out, "%sCOP %d, %d\n", (DEBUG ? str : ""), ins->op1, ins->op2);
				break;


			case JMF:
				fprintf(out, "%sJMF %d, %d\n", (DEBUG ? str : ""), ins->op1, ins->op2);
				break;
			case JMP:
				fprintf(out, "%sJMP %d\n", (DEBUG ? str : ""), ins->op2);
				break;


			case INF:
				fprintf(out, "%sINF %d, %d, %d\n", (DEBUG ? str : ""), ins->op1, ins->op2, ins->op3);
				break;
			case SUP:
				fprintf(out, "%sSUP %d, %d, %d\n", (DEBUG ? str : ""), ins->op1, ins->op2, ins->op3);
				break;
			case EQU:
				fprintf(out, "%sEQU %d, %d, %d\n", (DEBUG ? str : ""), ins->op1, ins->op2, ins->op3);
				break;


			case PRI:
				fprintf(out, "%sPRI %d\n", (DEBUG ? str : ""), ins->op1);
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

	i->opcode	 	= SOU;
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

int asm_prepare_JMP()
{
	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= JMP;
	/*i->op1		= condition_addr; simple jmp is condition-less*/
	/*i->op2		= unknown for now;*/
	i->op3			= JMP_NOT_FINISHED;

	return (asm_instruction_table_index - 1);
}

int asm_JMP(int jmp_to_addr)
{
	//asm_print2("COP @%d, @%d", to_addr, from_addr);

	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= JMP;
	/*i->op1		= condition_addr; simple jmp is condition-less*/
	i->op2			= jmp_to_addr;
	i->op3			= JMP_FINISHED;

	return (asm_instruction_table_index - 1);
}

int asm_prepare_JMF(int condition_addr)
{
	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= JMF;
	i->op1			= condition_addr;
	/*i->op2		= unknown for now;*/
	i->op3			= JMP_NOT_FINISHED;

	return (asm_instruction_table_index - 1);
}

int asm_JMF(int condition_addr, int jmp_to_addr)
{
	//asm_print2("COP @%d, @%d", to_addr, from_addr);

	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= JMF;
	i->op1			= condition_addr;
	i->op2			= jmp_to_addr;
	i->op3			= JMP_FINISHED;

	return (asm_instruction_table_index - 1);
}

void asm_INF(int res_addr, int op1_addr, int op2_addr)
{
	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= INF;
	i->op1			= res_addr;
	i->op2			= op1_addr;
	i->op3			= op2_addr;
}

void asm_SUP(int res_addr, int op1_addr, int op2_addr)
{
	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= SUP;
	i->op1			= res_addr;
	i->op2			= op1_addr;
	i->op3			= op2_addr;
}

void asm_EQU(int res_addr, int op1_addr, int op2_addr)
{
	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= EQU;
	i->op1			= res_addr;
	i->op2			= op1_addr;
	i->op3			= op2_addr;
}

void asm_PRI(int addr)
{
	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= PRI;
	i->op1			= addr;
}

void asm_update_jmp(int jmp_instruction_index, int line_offset)
{
	ASM_instruction *i = &(asm_instruction_table[jmp_instruction_index]);

	i->op2	= line_offset;
	i->op3	= JMP_FINISHED;
}

int asm_get_next_line()
{
	return asm_instruction_table_index;
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

