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

	STORE,
	LOAD,
	
	NB_OF_INSTRUCTIONS
} instruction_opcode;


#define JMP_NOT_FINISHED	0
#define JMP_FINISHED		0


#define ADDRESS_SYMBOL_STR_BOOLEAN	1
#define ADDRESS_SYMBOL_STR		"@"
#define LINE_NB				0
#define COMMENTS			0

#define DEBUG

#ifdef DEBUG
# undef ADDRESS_SYMBOL_STR_BOOLEAN
# define ADDRESS_SYMBOL_STR_BOOLEAN	1
# undef LINE_NB
# define LINE_NB			1
# undef COMMENTS
# define COMMENTS			1
#endif

#define ASM_INSTRUCTION_TABLE_SIZE	1024

typedef struct {

	instruction_opcode opcode;	
	int op1;
	int op2;
	int op3;

} ASM_instruction;

ASM_instruction asm_instruction_table[ASM_INSTRUCTION_TABLE_SIZE];

int asm_instruction_table_index = 0;

static inline ASM_instruction *get_next_instruction_slot()
{
	if (asm_instruction_table_index < ASM_INSTRUCTION_TABLE_SIZE)
		return &(asm_instruction_table[asm_instruction_table_index++]);
	return NULL;
}

/* Allows us to define comments in between each asm
 * instruction line, printed if #define COMMENTS 1 */
#define ASM_COMMENT_TABLE_SIZE	ASM_INSTRUCTION_TABLE_SIZE

typedef struct {
	int line_nb;
	char *comment;
} ASM_comment;

ASM_comment asm_comment_table[ASM_COMMENT_TABLE_SIZE];
int asm_comment_table_index = 0;

static inline ASM_comment *get_next_comment_slot()
{
	if (asm_comment_table_index < ASM_COMMENT_TABLE_SIZE)
		return &(asm_comment_table[asm_comment_table_index++]);
	return NULL;
}

void display_asm_instruction_table(void)
{
	int i;
	int comments_index = 0;
	for (i = 0; i < asm_instruction_table_index; i++) {

		ASM_instruction *ins = &asm_instruction_table[i];

		char line_nb[10] = "";
		char *address_symbol = "";
#if LINE_NB
		snprintf(line_nb, 10, "%3d: ", i);
#endif
#if ADDRESS_SYMBOL_STR_BOOLEAN
		address_symbol = ADDRESS_SYMBOL_STR;
#endif

#if COMMENTS
		while (i == asm_comment_table[comments_index].line_nb) {
			fprintf(out, "\x1B[01;33m; %s\n\x1B[0m", asm_comment_table[comments_index].comment);
			if (comments_index < asm_comment_table_index)
				comments_index++;
			else
				break;
		}
#endif

		switch (ins->opcode) {
			
			case ADD:
				fprintf(out, "%sADD %s%d, %s%d, %s%d\n", line_nb, address_symbol, ins->op1, address_symbol, ins->op2, address_symbol, ins->op3);
				break;
			case SOU:
				fprintf(out, "%sSOU %s%d, %s%d, %s%d\n", line_nb, address_symbol, ins->op1, address_symbol, ins->op2, address_symbol, ins->op3);
				break;
			case MUL:
				fprintf(out, "%sMUL %s%d, %s%d, %s%d\n", line_nb, address_symbol, ins->op1, address_symbol, ins->op2, address_symbol, ins->op3);
				break;


			case AFC:
				fprintf(out, "%sAFC %s%d, %d\n", line_nb, address_symbol, ins->op1, ins->op2);
				break;
			case COP:
				fprintf(out, "%sCOP %s%d, %s%d\n", line_nb, address_symbol, ins->op1, address_symbol, ins->op2);
				break;


			case JMF:
				fprintf(out, "%sJMF %s%d, %d\n", line_nb, address_symbol, ins->op1, ins->op2);
				break;
			case JMP:
				fprintf(out, "%sJMP %d\n", line_nb, ins->op2);
				break;


			case INF:
				fprintf(out, "%sINF %s%d, %s%d, %s%d\n", line_nb, address_symbol, ins->op1, address_symbol, ins->op2, address_symbol, ins->op3);
				break;
			case SUP:
				fprintf(out, "%sSUP %s%d, %s%d, %s%d\n", line_nb, address_symbol, ins->op1, address_symbol, ins->op2, address_symbol, ins->op3);
				break;
			case EQU:
				fprintf(out, "%sEQU %s%d, %s%d, %s%d\n", line_nb, address_symbol, ins->op1, address_symbol, ins->op2, address_symbol, ins->op3);
				break;


			case PRI:
				fprintf(out, "%sPRI %s%d\n", line_nb, address_symbol, ins->op1);
				break;

			case STORE:
				fprintf(out, "%sSTORE %s%d, %s%d\n", line_nb, address_symbol, ins->op1, address_symbol, ins->op2);
				break;
			case LOAD:
				fprintf(out, "%sLOAD %s%d, %s%d\n", line_nb, address_symbol, ins->op1, address_symbol, ins->op2);
				break;
	
			default:
				break;
		}
	}
}



void asm_ADD(int res_addr, int op1_addr, int op2_addr)
{
	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= ADD;
	i->op1			= res_addr;
	i->op2			= op1_addr;
	i->op3			= op2_addr;
}

void asm_SUB(int res_addr, int op1_addr, int op2_addr)
{
	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= SOU;
	i->op1			= res_addr;
	i->op2			= op1_addr;
	i->op3			= op2_addr;
}

void asm_MUL(int res_addr, int op1_addr, int op2_addr)
{
	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= MUL;
	i->op1			= res_addr;
	i->op2			= op1_addr;
	i->op3			= op2_addr;
}



void asm_AFC(int to_addr, int value)
{
	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= AFC;
	i->op1			= to_addr;
	i->op2			= value;
}

void asm_COP(int to_addr, int from_addr)
{
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

void asm_STORE(int addr1, int addr2)
{
	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= STORE;
	i->op1			= addr1;
	i->op2			= addr2;
}

void asm_LOAD(int addr1, int addr2)
{
	ASM_instruction *i = get_next_instruction_slot();

	i->opcode	 	= LOAD;
	i->op1			= addr1;
	i->op2			= addr2;
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

void asm_push_address(int address)
{
	Symbol *s = symbol_table_add_tmp_symbol();

	asm_AFC(s->address, address);
}

void asm_push_from_pointer_address(int address)
{
	Symbol *s = symbol_table_add_tmp_symbol();

	asm_LOAD(s->address, address);
}

Symbol *asm_pop()
{
	return symbol_table_pop();
}

void asm_comment_now(char *comment)
{
	asm_comment(asm_get_next_line(), comment);
}

void asm_comment(int line_nb, char *comment)
{
	ASM_comment *c = get_next_comment_slot();

	c->line_nb = line_nb;
	c->comment = comment;
}

