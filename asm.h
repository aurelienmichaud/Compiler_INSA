#ifndef _ASM_H_
#define _ASM_H_

#include <stdio.h>

#include "symbol_table.h"

FILE* out;
void init_output(FILE *output);

void display_asm_instruction_table(void);

void asm_ADD(int res_addr, int op1_addr, int op2_addr);
void asm_SUB(int res_addr, int op1_addr, int op2_addr);
void asm_MUL(int res_addr, int op1_addr, int op2_addr);

void asm_AFC(int to_addr, int value);
void asm_COP(int to_addr, int from_addr);

int asm_prepare_JMP();
int asm_JMP(int jmp_to_addr);

int asm_prepare_JMF(int condition_addr);
int asm_JMF(int condition_addr, int jmp_to_addr);

void asm_INF(int res_addr, int op1_addr, int op2_addr);
void asm_SUP(int res_addr, int op1_addr, int op2_addr);
void asm_EQU(int res_addr, int op1_addr, int op2_addr);

void asm_PRI(int addr);

void asm_STORE(int op1_addr, int op2_addr);
void asm_LOAD(int op1_addr, int op2_addr);

/* Extra functions to simulate a stackpile for temporary variables
 * during arithmetic operations.
 * Behind the scene are just calls to the symbol_table library 
 * to create and delete temporary variables */
void asm_push(int value);

void asm_push_from_address(int address);
void asm_push_address(int address);
void asm_push_from_pointer_address(int address);

Symbol *asm_pop();

void asm_update_jmp(int jmp_instruction_index, int line_index);
int asm_get_next_line();

void asm_comment(int line_nb, char *comment);
void asm_comment_now(char *comment);

#endif /* _ASM_H_ */
