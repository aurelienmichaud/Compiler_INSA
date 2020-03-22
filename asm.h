#ifndef _ASM_H_
#define _ASM_H_

#include <stdio.h>

#include "symbol_table.h"

FILE* out;
void init_output(FILE *output);

void asm_ADD(int res_addr, int op1_addr, int op2_addr);
void asm_SUB(int res_addr, int op1_addr, int op2_addr);
void asm_MUL(int res_addr, int op1_addr, int op2_addr);

void asm_AFC(int to_addr, int value);
void asm_COP(int to_addr, int from_addr);

void asm_push(int value);

void asm_push_from_address(int address);

Symbol *asm_pop();

void asm_comment(char *msg);
void asm_comment1(char *msg, int var1);
void asm_comment2(char *msg, int var1, int var2);

#endif /* _ASM_H_ */
