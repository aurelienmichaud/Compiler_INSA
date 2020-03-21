#ifndef _SYMBOL_TABLE_H
#define _SYMBOL_TABLE_H

#define INT_BYTE_SIZE	0x4

typedef struct _Symbol {

	char *identifier;
	int address;

	char isInitialized;
	char isConstant;

	int depth;

} Symbol;

void init_symbol_table();
Symbol *symbol_table_get_symbol(char *identifier);
Symbol *symbol_table_add_symbol(char *identifier);

int symbol_table_increase_depth();
int symbol_table_decrease_depth();

#endif /* _SYMBOL_TABLE_H */

