
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#define VAR_TABLE_SIZE	100

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
		long address;

	} Variable;

	Variable vars[VAR_TABLE_SIZE];
	int vars_index;

	Variable *get_var(char *identifier) {
		int i;
		for (i = 0; i < vars_index; i++) {
			if (strcmp(vars[i].identifier, identifier) == 0)
				break;
		}
		return (i == vars_index) ? NULL : &(vars[i]) ;
	}

	Variable *add_var(char *identifier) {
		if (vars_index == VAR_TABLE_SIZE) {
			return NULL;
		}	

		vars[vars_index].identifier = strdup(identifier);
		vars[vars_index].id = vars_index;

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

	<string> tIDENTIFIER

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

		| tRETURN EXPRESSION tSEMI_C STATEMENT
			{ printf("[RETURN]\n"); }
           	;
           

           
EXPRESSION :	EXPRESSION tADD EXPRESSION
			{ 
				printf("[%d + %d]\n", $1, $3);
				printf("add %s, %d, %d\n", "eax", $1, $3);
			}
                
		| EXPRESSION tMUL EXPRESSION
			{ printf("[%d * %d]\n", $1, $3); }

		| EXPRESSION tSUB EXPRESSION
			{ printf("[%d / %d]\n", $1, $3); }

		| EXPRESSION tDIV EXPRESSION
			{ printf("[DIV]\n"); }

		| EXPRESSION tMOD EXPRESSION
			{ printf("[MODULO]\n"); }
                
                
		| FUNCTION_CALL
			{ printf("[FUNCTION_CALL]\n"); }  


		| tINTEGER_NUMBER
			{ 
				$$ = $1;
				printf("[INTEGER_NUMBER = %d]\n", $$);
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
					v = add_var($1);
				}
				
				/* For now we return the id only because we needed to return an integer number */
				$$ = v->id;
				printf("[IDENTIFIER = %s]\n", $1);
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
			{ printf("[PRINTF]\n"); }
		;
             
 
             
FUNCTION_CALL :	PRINTF
		| tIDENTIFIER tOP FUNCTION_ARGS tCP
		;
           
TYPE :	tINT
	| tFLOAT
	| tDOUBLE
	| tCHAR
	;
           
ASSIGNMENT :	tIDENTIFIER tEQUAL EXPRESSION
			{ printf("[ASSIGNMENT]\n"); }
		;

DELCARATION_AND_ASSIGNMENT :	TYPE ASSIGNMENT ;
       
DECLARATION :	DELCARATION_AND_ASSIGNMENT
		| TYPE tIDENTIFIER
		;
              
%%

int main(void)
{
	init();
	yylval.string = NULL;

	yyparse();
}

