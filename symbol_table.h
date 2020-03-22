#ifndef _SYMBOL_TABLE_H
#define _SYMBOL_TABLE_H

#define INT_BYTE_SIZE	0x4

enum init_flag		{UNINITIALIZED,	INITIALIZED};
enum constant_flag 	{NOT_CONSTANT,	CONSTANT};

typedef struct _Symbol {

	char *identifier;
	int address;

	enum init_flag		isInitialized;
	enum constant_flag	isConstant;

	int depth;

} Symbol;

void init_symbol_table();
Symbol *symbol_table_get_symbol(char *identifier);
Symbol *symbol_table_add_symbol(char *identifier);
Symbol *symbol_table_add_constant_symbol(char *identifier, enum init_flag isInitialized);

void symbol_table_set_initialized(Symbol *s, enum init_flag isInitialized);

Symbol *symbol_table_add_tmp_symbol(void);

Symbol *symbol_table_pop(void);
Symbol *symbol_table_peek(void);

int symbol_table_is_initialized(Symbol *s);
int symbol_table_is_constant(Symbol *s);
int symbol_table_is_available(char *identifier);

int symbol_table_increase_depth();
int symbol_table_decrease_depth();

#endif /* _SYMBOL_TABLE_H */

