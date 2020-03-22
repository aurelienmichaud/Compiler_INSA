
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#include "symbol_table.h"

	#define ABORT_ON_ERROR1(MSG, VAR1)		\
		do {					\
			fprintf(stderr, "[!] ERROR: ");	\
			fprintf(stderr, MSG, VAR1);	\
			fprintf(stderr, "\n");		\
							\
			exit(1);			\
		} while(0)

	#define WARN1(MSG, VAR1)				\
		do {						\
			fprintf(stderr, "[*] WARNING: ");	\
			fprintf(stderr, MSG, VAR1);		\
			fprintf(stderr, "\n");			\
		} while(0)



	FILE* out;

	void init_output(FILE *f)
	{
		out = f;
	}


	#define asm_print0(__STRING__)					do { fprintf(out, __STRING__"\n"); } while(0)
	#define asm_print1(__STRING__, __VAR1__)			do { fprintf(out, __STRING__"\n", (__VAR1__)); } while(0)
	#define asm_print2(__STRING__, __VAR1__, __VAR2__)		do { fprintf(out, __STRING__"\n", (__VAR1__), (__VAR2__)); } while(0)
	#define asm_print3(__STRING__, __VAR1__, __VAR2__, __VAR3__)	do { fprintf(out, __STRING__"\n", (__VAR1__), (__VAR2__), (__VAR3__)); } while(0)

	#define asm_comment(__MSG__)					do { asm_print0("; "__MSG__); } while(0)
	#define asm_comment1(__MSG__, __VAR1__)				do { asm_print1("; "__MSG__, (__VAR1__)); } while(0)
	#define asm_comment2(__MSG__, __VAR1__, __VAR2__)		do { asm_print1("; "__MSG__, (__VAR1__), (__VAR2__)); } while(0)

	#define asm_AFC(__ADDRESS__, __VALUE__)			do { asm_print2("AFC @%d, 0x%x", (__ADDRESS__), (__VALUE__)); } while(0)

	#define asm_COP(__TO__, __FROM__)			do { asm_print2("COP @%d, @%d", (__TO__), (__FROM__)); } while(0)

	#define asm_ADD(__RESULT__, __ADDRESS1__, __ADDRESS2__)	do { asm_print3("ADD @%d, @%d, @%d", (__RESULT__), (__ADDRESS1__), (__ADDRESS2__)); } while(0)
	#define asm_MUL(__RESULT__, __ADDRESS1__, __ADDRESS2__)	do { asm_print3("MUL @%d, @%d, @%d", (__RESULT__), (__ADDRESS1__), (__ADDRESS2__)); } while(0)
	#define asm_SUB(__RESULT__, __ADDRESS1__, __ADDRESS2__)	do { asm_print3("SOU @%d, @%d, @%d", (__RESULT__), (__ADDRESS1__), (__ADDRESS2__)); } while(0)

	static inline void asm_push(int value)
	{
		Symbol *s = symbol_table_add_tmp_symbol();

		asm_AFC(s->address, value);
	}

	static inline void asm_push_from_address(int address)
	{
		Symbol *s = symbol_table_add_tmp_symbol();

		asm_COP(s->address, address);
	}

	static inline Symbol *asm_pop()
	{
		return symbol_table_pop();
	}

	int yydebug = 1; 

	extern int yylex();

	int yyerror(char *s) {
		printf("=== YYERROR ===\n");
		exit(1);
		return 1;
	}
%}


%union	{ 
		int integer_nb;
		float float_nb;
		char *string;
	}

%token
			tMAIN
			tPRINTF

	<string>	tIDENTIFIER

			tVOID
			tINT
			tFLOAT
			tDOUBLE
			tCHAR

			tLONG
			tSIGNED
			tUNSIGNED
			tSHORT
			tCONST

	<integer_nb> 	tINTEGER_NUMBER 
	<float_nb>	tFLOAT_NUMBER

			tIF
			tELSE
			tWHILE
			tSWITCH
			tFOR
			tDO

			tBREAK
			tCONTINUE
			tDEFAULT

			tRETURN

			tNEWLINE
			tSPACE

			tEQUAL

			tOP
			tCP
			tOCB
			tCCB
			tOB
			tCB

			tE_MARK
			tI_MARK

			tSEMI_C
			tCOMMA
			tCOLON

			tMUL
			tDIV
			tADD
			tSUB
			tMOD


%left tADD tSUB
%left tMUL tDIV tMOD

%type <integer_nb> EXPRESSION

%%

S : tVOID tMAIN tOP tCP BODY 
    ;

BODY : tOCB STATEMENT tCCB ;

STATEMENT :	/* NOTHING */		
		| tSEMI_C 
		| BODY STATEMENT
            	| DECLARATION tSEMI_C STATEMENT

		| EXPRESSION tSEMI_C STATEMENT

		| IF
		| ASSIGNMENT tSEMI_C STATEMENT

		| tRETURN EXPRESSION tSEMI_C STATEMENT
           	;
           

           
EXPRESSION :	EXPRESSION tADD EXPRESSION
			{ 
				Symbol *op2 = asm_pop();
				Symbol *op1 = symbol_table_peek();

				asm_ADD(op1->address, op1->address, op2->address);

				asm_comment("Addition");
			}

		| EXPRESSION tSUB EXPRESSION
			{ 
				Symbol *op2 = asm_pop();
				Symbol *op1 = symbol_table_peek();

				asm_SUB(op1->address, op1->address, op2->address);
			}
                
		| EXPRESSION tMUL EXPRESSION
			{ 
				Symbol *op2 = asm_pop();
				Symbol *op1 = symbol_table_peek();

				asm_MUL(op1->address, op1->address, op2->address);
			}

		| EXPRESSION tDIV EXPRESSION
			{ 
			}

		| EXPRESSION tMOD EXPRESSION
			{ 
			}
                
                
		| FUNCTION_CALL
			{
			}  


		| tINTEGER_NUMBER
			{ 
				$$ = $1;
				asm_push($$);
			}

		| tFLOAT_NUMBER
			{ 
				$$ = $1;
			}

		| tIDENTIFIER
			{
				Symbol *s = symbol_table_get_symbol($1);

				if (s == NULL) {
					ABORT_ON_ERROR1("Undeclared symbol '%s'", $1);
					/*v = add_var($1);*/
				}

				/* $1 is actually yylval.string */
				free(yylval.string);
				
				/* For now we return the id only because we needed to return an integer number */
				$$ = s->address;
				
				asm_push_from_address(s->address);
			}
		;
           
FUNCTION_ARGS :	/* NOTHING */ 
		| EXPRESSION
		| EXPRESSION tCOMMA FUNCTION_ARGS_NOT_EMPTY
		;
 
FUNCTION_ARGS_NOT_EMPTY :	EXPRESSION
				| EXPRESSION tCOMMA FUNCTION_ARGS_NOT_EMPTY
				;
           
PRINTF :	tPRINTF tOP FUNCTION_ARGS_NOT_EMPTY tCP
			{
			}
		;
             
 
             
FUNCTION_CALL :	PRINTF
		| tIDENTIFIER tOP FUNCTION_ARGS tCP
			{
			}
		;
           
TYPE :	tINT
	| tFLOAT
	| tDOUBLE
	| tCHAR
	;
           

DECLARATION_AND_ASSIGNMENT :	TYPE tIDENTIFIER tEQUAL EXPRESSION
					{
						if (!symbol_table_is_available($2)) {
							ABORT_ON_ERROR1("Declaration of the already declared symbol '%s'", $2);
						}

						Symbol *s = symbol_table_add_symbol($2);
						symbol_table_set_initialized(s, INITIALIZED);

						Symbol *expr = asm_pop();

						asm_COP(s->address, expr->address);
						asm_comment1("Declaration & assignment of '%s'", $2);
					}
				| tCONST TYPE tIDENTIFIER tEQUAL EXPRESSION
					{
						if (!symbol_table_is_available($3)) {
							ABORT_ON_ERROR1("Declaration of the already declared symbol '%s'", $3);
						}

						Symbol *s = symbol_table_add_constant_symbol($3, INITIALIZED);

						Symbol *expr = asm_pop();

						asm_COP(s->address, expr->address);
						asm_comment1("Declaration & assignment of constant '%s'", $3);
					}
				;
       
DECLARATION :	DECLARATION_AND_ASSIGNMENT
		| TYPE tIDENTIFIER
			{
				if (!symbol_table_is_available($2)) {
					ABORT_ON_ERROR1("Declaration of the already declared symbol '%s'", $2);
				}

				Symbol *s = symbol_table_add_symbol($2);
				symbol_table_set_initialized(s, UNINITIALIZED);
			}
		| tCONST TYPE tIDENTIFIER
			{
				if (!symbol_table_is_available($3)) {
					ABORT_ON_ERROR1("Declaration of the already declared symbol '%s'", $3);
				}

				Symbol *s = symbol_table_add_constant_symbol($3, UNINITIALIZED);

				WARN1("Symbol '%s' declared with 'const' class not initialized", $3);
			}
		;

ASSIGNMENT :	tIDENTIFIER tEQUAL EXPRESSION
			{
				Symbol *s = symbol_table_get_symbol($1);

				if (s == NULL) {
					ABORT_ON_ERROR1("Undeclared symbol '%s'", $1);

				} else if (!symbol_table_is_constant(s)) {
					Symbol *expr = asm_pop();
					asm_COP(s->address, expr->address);

				} else {
					ABORT_ON_ERROR1("Symbol '%s' declared with 'const' class is not mutable", $1);
				}

				asm_comment1("Assignment of '%s'", $1);
			}
		;


IF :	tIF tOP EXPRESSION tCP BODY
		{
		}
              
%%

int main(void)
{
	init_output(stdout);
	init_symbol_table();

	yylval.string = NULL;

	yyparse();
}

