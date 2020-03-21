#include <stdlib.h>
#include <string.h>

#include "symbol_table.h"

#define SYMBOL_TABLE_SIZE	100

Symbol symbol_table[SYMBOL_TABLE_SIZE];
/* Make sure the symbol_table_index points to the next available symbol_table's slot */
int symbol_table_index = 0;
/* Make sure the current_address has the address of the next available symbol_table's slot
 * Basically, current_address = symbol_table_index * INT_BYTE_SIZE*/
int current_address = 0;
int current_depth = 0;

void init_symbol_table()
{
	memset(symbol_table, 0, SYMBOL_TABLE_SIZE * sizeof(*symbol_table));
}

Symbol *symbol_table_get_symbol(char *identifier)
{
	int i;
	for (i = 0; i < symbol_table_index; i++) {
		if (strcmp(symbol_table[i].identifier, identifier) == 0)
			return &(symbol_table[i]);
	}
	return NULL;
}

Symbol *symbol_table_add_symbol(char *identifier)
{
	if (symbol_table_index == SYMBOL_TABLE_SIZE) {
		return NULL;
	}	

	symbol_table[symbol_table_index].identifier	= strdup(identifier);
	symbol_table[symbol_table_index].address	= current_address;
	symbol_table[symbol_table_index].isInitialized	= 0;
	symbol_table[symbol_table_index].isConstant	= 0;
	symbol_table[symbol_table_index].depth		= current_depth;

	current_address += INT_BYTE_SIZE;

	return &(symbol_table[symbol_table_index++]);
}

Symbol *symbol_table_add_constant_symbol(char *identifier) 
{
	Symbol *v = symbol_table_add_symbol(identifier);
	
}

static void delete_current_depth()
{
	int i;

	/* We assume that the symbol table will be naturally sorted by increasing depth.
	 * Thus, deleting the current depth (the highest depth that is), means deleting
	 * the last symbols until reaching a smaller depth */
	
	for (i = symbol_table_index; (i > 0) && (symbol_table[i-1].depth == current_depth); i--) {
		/* NOTHING TO DO */
	}

	symbol_table_index = i;
	current_address = symbol_table_index * INT_BYTE_SIZE;
}

int symbol_table_increase_depth()
{
	return (++current_depth);
}

int symbol_table_decrease_depth()
{
	if (current_depth > 0) {
		delete_current_depth();
		return (--current_depth);
	}

	return -1;
}


