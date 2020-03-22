#include <stdlib.h>
#include <string.h>

#include "symbol_table.h"

#define SYMBOL_TABLE_SIZE	100
#define TMP_SYMBOL_TABLE_SIZE	100
#define TMP_SYMBOL_TABLE_OFFSET	SYMBOL_TABLE_SIZE

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
	/* Search from the end of the symbol table to the start since it is naturally
	 * sorted by increasing depth, and we want to return the first corresponding
	 * symbol with the closest depth possible */
	for (i = symbol_table_index-1; i >= 0; i--) {
		if (strcmp(symbol_table[i].identifier, identifier) == 0)
			return &(symbol_table[i]);
	}

	return NULL;
}

int symbol_table_is_available(char *identifier)
{
	int i;
	for (i = symbol_table_index; (i > 0) && (symbol_table[i-1].depth == current_depth); i--) {
		if (strcmp(symbol_table[i-1].identifier, identifier) == 0)
			return 0;
	}

	return 1;
}

static void init_symbol(Symbol *s, char *identifier, int address, enum init_flag i, enum constant_flag c, int depth)
{
	if (s) {
		s->identifier		= identifier;
		s->address		= address;
		s->isInitialized	= i;
		s->isConstant		= c;
		s->depth		= depth;
	}
}

Symbol *symbol_table_add_symbol(char *identifier)
{
	if (symbol_table_index == SYMBOL_TABLE_SIZE) {
		return NULL;
	}	

	init_symbol(&(symbol_table[symbol_table_index]),
			strdup(identifier),
			current_address,
			UNINITIALIZED,
			NOT_CONSTANT,
			current_depth);

	current_address += INT_BYTE_SIZE;

	return &(symbol_table[symbol_table_index++]);
}


Symbol tmp_symbol_table[TMP_SYMBOL_TABLE_SIZE];

int tmp_symbol_table_index = 0;
/* Make sure the current_address has the address of the next available symbol_table's slot
 * Basically, current_address = symbol_table_index * INT_BYTE_SIZE*/
int tmp_current_address = TMP_SYMBOL_TABLE_OFFSET;

/* Add temporary variable: therefore no need for an identifier */
Symbol *symbol_table_add_tmp_symbol(void)
{
	if (tmp_symbol_table_index == TMP_SYMBOL_TABLE_SIZE) {
		return NULL;
	}	

	init_symbol(&(tmp_symbol_table[tmp_symbol_table_index]),
			NULL,
			tmp_current_address,
			UNINITIALIZED,
			NOT_CONSTANT,
			current_depth);

	tmp_current_address += INT_BYTE_SIZE;

	return &(tmp_symbol_table[tmp_symbol_table_index++]);
}

Symbol *symbol_table_add_constant_symbol(char *identifier, enum init_flag isInitialized) 
{
	Symbol *s = symbol_table_add_symbol(identifier);
	
	s->isConstant = CONSTANT;
	s->isInitialized = isInitialized;
}

void symbol_table_set_initialized(Symbol *s, enum init_flag isInitialized)
{
	if (s) { s->isInitialized = isInitialized; }
}

int symbol_table_is_initialized(Symbol *s)
{
	if (s) {
		return (s->isInitialized == INITIALIZED);
	}

	return -1;
}

int symbol_table_is_constant(Symbol *s)
{
	if (s) {
		return (s->isConstant == CONSTANT);
	}

	return -1;
}

Symbol *symbol_table_pop(void)
{
	if (tmp_symbol_table_index) {

		tmp_current_address -= INT_BYTE_SIZE;

		return &(tmp_symbol_table[--tmp_symbol_table_index]);
	}

	return NULL;
}

Symbol *symbol_table_peek(void)
{
	if (tmp_symbol_table_index)
		return &(tmp_symbol_table[tmp_symbol_table_index-1]);

	return NULL;
}

static void delete_current_depth(void)
{
	int i;

	/* We assume that the symbol table will be naturally sorted by increasing depth.
	 * Thus, deleting the current depth (the highest depth that is) means deleting
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


