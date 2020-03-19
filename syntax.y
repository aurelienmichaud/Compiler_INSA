
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#define ABORT_ON_ERROR1(MSG, VAR1)	\
		do {				\
			printf("[*] ERROR: ");	\
			printf(MSG, VAR1);	\
			printf("\n");		\
						\
			exit(1);		\
		} while(0)

	#define	push_from_addr(A)	do { printf("push [%d]\n", (A)); } while(0)
	#define	push(A)			do { printf("push %d\n", (A)); } while(0)

	#define pop_to_addr(A)		do { printf("pop [%d]", (A)); } while(0)
	#define pop()			do { printf("pop\n"); } while(0)

	#define call(Label)		do { printf("call %s\n", Label); } while(0)

	#define cmp(A, B)		do { printf("cmp %d, %d\n", (A), (B)); } while(0)

	#define print(ADDR)		do { printf("pri %d\n", (ADDR)); } while(0)

	#define VAR_TABLE_SIZE	100
	#define INT_BYTE_SIZE	0x4


	int yydebug = 1; 

	extern int yylex();

	int yyerror(char *s) {
		printf("=== YYERROR ===\n");
		exit(1);
		return 1;
	}

	typedef struct _Variable {
		int id;
		char *identifier;	
		int address;

	} Variable;

	Variable vars[VAR_TABLE_SIZE];
	int vars_index = 0;
	int current_address = 0;

	Variable *get_var(char *identifier) {
		int i;
		for (i = 0; i < vars_index; i++) {
			if (strcmp(vars[i].identifier, identifier) == 0)
				return &(vars[i]);
		}
		return NULL;
	}

	Variable *add_var(char *identifier) {
		if (vars_index == VAR_TABLE_SIZE) {
			return NULL;
		}	

		vars[vars_index].identifier	= strdup(identifier);
		vars[vars_index].id		= vars_index;
		vars[vars_index].address	= current_address;

		current_address += INT_BYTE_SIZE;

		return &(vars[vars_index++]);
	}

	void init() {
		memset(vars, 0, VAR_TABLE_SIZE * sizeof(*vars));
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
        { printf("[MAIN]\n"); }
    ;

BODY : tOCB STATEMENT tCCB ;

STATEMENT :	/* NOTHING */		
		| tSEMI_C 
		| BODY STATEMENT
            	| DECLARATION tSEMI_C STATEMENT
			{ printf("[DECLARATION]\n"); }

		| EXPRESSION tSEMI_C STATEMENT
			{ printf("[EXPRESSION tSEMI_C]\n"); }

		| IF

		| tRETURN EXPRESSION tSEMI_C STATEMENT
			{ printf("[RETURN]\n"); }
           	;
           

           
EXPRESSION :	EXPRESSION tADD EXPRESSION
			{ 
				printf("add [esp+0x4], [esp]\n");
				pop();
			}

		| EXPRESSION tSUB EXPRESSION
			{ 
				printf("sub [esp+0x4], [esp]\n");
				pop();
			}
                
		| EXPRESSION tMUL EXPRESSION
			{ 
				printf("mul [esp+0x4], [esp]\n");
				pop();
			}

		| EXPRESSION tDIV EXPRESSION
			{ 
				printf("div [esp+0x4], [esp]\n");
				pop();
			}

		| EXPRESSION tMOD EXPRESSION
			{ 
				printf("mod [esp+0x4], [esp]\n");
				pop();
			}
                
                
		| FUNCTION_CALL
			{
				/*printf("[FUNCTION_CALL]\n");*/
			}  


		| tINTEGER_NUMBER
			{ 
				$$ = $1;
				/*printf("[INTEGER_NUMBER = %d]\n", $$);*/
				push($$);
			}

		| tFLOAT_NUMBER
			{ 
				$$ = $1;
				printf("[FLOAT_NUMBER = %f]\n", $$);
			}

		| tIDENTIFIER
			{
				Variable *v = get_var($1);

				if (v == NULL) {
					ABORT_ON_ERROR1("Unknown identifier '%s'", $1);
					/*v = add_var($1);*/
				}

				/* $1 is actually yylval.string */
				free(yylval.string);
				
				/* For now we return the id only because we needed to return an integer number */
				$$ = v->address;
				
				printf("[IDENTIFIER = %s]\n", v->identifier);
				push_from_addr(v->address);
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
				call($1);
			}
		;
           
TYPE :	tINT
	| tFLOAT
	| tDOUBLE
	| tCHAR
	;
           
/*
ASSIGNMENT :	tIDENTIFIER tEQUAL EXPRESSION
			{
				Variable *v = get_var($1);

				printf("[ASSIGNMENT]\n");
				pop_to_addr(v->address);
			}
		;
*/

DECLARATION_AND_ASSIGNMENT :	TYPE tIDENTIFIER tEQUAL EXPRESSION
					{
						Variable *v = add_var($2);
						pop_to_addr(v->address);
					}
				;
       
DECLARATION :	DECLARATION_AND_ASSIGNMENT
		| TYPE tIDENTIFIER
		;

IF :	tIF tOP EXPRESSION tCP BODY
		{
		}
              
%%

int main(void)
{
	init();
	yylval.string = NULL;

	yyparse();
}

