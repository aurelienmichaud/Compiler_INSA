#ifndef _SYMBOL_TABLE_H
#define _SYMBOL_TABLE_H

enum symbol_type {
	BASIC_TYPE,
	BASIC_CONSTANT_TYPE,

	POINTER_TYPE,
	POINTER_CONSTANT_TYPE,

	POINTER_TO_CONSTANT_TYPE,
	POINTER_CONSTANT_TO_CONSTANT_TYPE

};

enum init_flag		{UNINITIALIZED,	INITIALIZED};

typedef struct _Symbol {

	char *identifier;
	int address;
	
	enum init_flag		isInitialized;
	enum symbol_type	type;

	int depth;

} Symbol;


void init_symbol_table();

Symbol *symbol_table_new_symbol(char *identifier, enum symbol_type st);

Symbol *symbol_table_get_symbol(char *identifier);
void symbol_table_set_constant(Symbol *s);

void symbol_table_set_initialized(Symbol *s, enum init_flag isInitialized);

int symbol_table_is_initialized(Symbol *s);
int symbol_table_is_constant(Symbol *s);
int symbol_table_is_pointer(Symbol *s);
int symbol_table_is_available(char *identifier);

int symbol_table_increase_depth();
int symbol_table_decrease_depth();

Symbol *symbol_table_add_tmp_symbol(void);

Symbol *symbol_table_pop(void);
Symbol *symbol_table_peek(void);

#endif /* _SYMBOL_TABLE_H */

