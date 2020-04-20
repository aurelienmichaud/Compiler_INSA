
%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	#include "syntax_parser_data_types.h"
	#include "symbol_table.h"
	#include "asm.h"

	#define ABORT_ON_ERROR1(MSG, VAR1)				\
		do {							\
			fprintf(stderr, "\x1B[01;31m[!] ERROR: ");	\
			fprintf(stderr, MSG, (VAR1));			\
			fprintf(stderr, "\n\x1B[0m");			\
									\
			exit(1);					\
		} while(0)

	#define WARN1(MSG, VAR1)					\
		do {							\
			fprintf(stderr, "\x1B[01;32m[*] WARNING: ");	\
			fprintf(stderr, MSG, (VAR1));			\
			fprintf(stderr, "\n\x1B[0m");			\
		} while(0)


	/* Input stream */
	FILE *yyin;

	int yydebug = 1; 

	extern int yylex();

	int yyerror(char *s) {
		printf("=== YYERROR ===\n");
		exit(1);
		return 1;
	}

	/* Translates any expression on top of the stack into 1 or 0 for
	 * respectively true (any expression different from 0) or false
	 * (if that expression is 0).
	 *
	 * This allows the use of any expression such as '2 * 32' or 'a - 2'
	 * to be considered as a valid conditional expression.
	 *
	 * Of course it does not manually check if the expression on the top
	 * of the stack is true or false. Its goal is to produce a sequence
	 * of assembly instruction that will do the job while running. */
	void translate_expression_to_conditional_expression() {

		asm_comment_now("translating the expression into a conditional expression");

		/* We compare the expression on top of the stack with 0 */
		asm_push(0);
		Symbol *zero = asm_pop();
		Symbol *expr = symbol_table_peek();
		/* (EXPR == 0) ? */
		asm_EQU(expr->address, expr->address, zero->address);

		/* Since the previous EQU instruction will set the top of the
		 * stack to 1 if the expression was equal to 0, it means that
		 * the expression was actually false (because equals to 0).
		 * Therefore we now need to flip the 0 to 1 and the 1 to 0.
		 * That flipping is done by doing 1-EQU. */
		asm_push(1);
		Symbol *one = asm_pop();
		asm_SUB(expr->address, one->address, expr->address);
		
		/* Another workaround consists of the following instruction sequence.
		 * Basically applying a IF-THEN-ELSE structure in order to set the 
		 * value of the top of the stack to 0 or 1 respectively if the top of
		 * the stack is currently 1 or 0. */
		/*
		 * asm_JMF(expr->address, asm_get_next_line() + 3);
		 * asm_AFC(expr->address, 0);
		 * asm_JMP(asm_get_next_line() + 2);
		 * asm_AFC(expr->address, 1);
		*/
	}
%}


%union	{ 
		int integer_nb;
		float float_nb;
		char *string;
		Symbol *symbol;
		enum symbol_type symbol_type;
		struct _lvalue lvalue;
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

	<integer_nb>	tIF
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
			tQ_MARK

			tSEMI_C
			tCOMMA
			tCOLON

			tMUL
			tDIV
			tADD
			tSUB
			tMOD

			tLESS_THAN
			tLESS_THAN_OR_EQUAL_TO
			tGREATER_THAN
			tGREATER_THAN_OR_EQUAL_TO
			tEQUAL_COMPARISON
			tDIFFERENT

			tAMPERSAND


%left tEQUAL
%left tLESS_THAN tLESS_THAN_OR_EQUAL_TO tGREATER_THAN tGREATER_THAN_OR_EQUAL_TO tDIFFERENT tEQUAL_COMPARISON
%left tADD tSUB
%left tMUL tDIV tMOD
%left tOP tCP

%type <symbol> 	EXPRESSION
%type <lvalue>	LVALUE

%type <symbol_type> 	DECLARATION_TYPE
%type <symbol> 		DECLARATION_AND_ASSIGNMENT

%%

S : tVOID tMAIN tOP tCP BODY 
    ;

BODY : tOCB
		{ symbol_table_increase_depth(); }
	STATEMENT tCCB
		{ symbol_table_decrease_depth(); }
	;

STATEMENT :	/* NOTHING */		
		| tSEMI_C 
		| BODY STATEMENT

		| IF_STATEMENT STATEMENT
		| WHILE_STATEMENT STATEMENT

            	| DECLARATION tSEMI_C STATEMENT

		| ASSIGNMENT tSEMI_C STATEMENT

		| EXPRESSION tSEMI_C
			/* Since EXPRESSION rule always put the result on top of the stack,
			 * once the end of the statement is reached, we need to pop that value,
			 * in order to free the stack */
			{
				asm_pop();				
			}
		STATEMENT

		| tRETURN EXPRESSION tSEMI_C STATEMENT
           	;
           

           
EXPRESSION :	tOP EXPRESSION tCP
			{
				$$ = $2;
			}
		| EXPRESSION tADD EXPRESSION
			{ 
				Symbol *op2 = asm_pop();
				Symbol *op1 = symbol_table_peek();

				asm_ADD(op1->address, op1->address, op2->address);

				$$ = op1;
			}

		| EXPRESSION tSUB EXPRESSION
			{ 
				Symbol *op2 = asm_pop();
				Symbol *op1 = symbol_table_peek();

				asm_SUB(op1->address, op1->address, op2->address);

				$$ = op1;
			}
                
		| EXPRESSION tMUL EXPRESSION
			{ 
				Symbol *op2 = asm_pop();
				Symbol *op1 = symbol_table_peek();

				asm_MUL(op1->address, op1->address, op2->address);

				$$ = op1;
			}

		| EXPRESSION tDIV EXPRESSION
			{ 
			}

		| EXPRESSION tMOD EXPRESSION
			{ 
			}

		| EXPRESSION tLESS_THAN EXPRESSION
			{
				Symbol *op2 = asm_pop();
				Symbol *op1 = symbol_table_peek();

				asm_INF(op1->address, op1->address, op2->address);
				$$ = op1;
			}

		| EXPRESSION tLESS_THAN_OR_EQUAL_TO EXPRESSION
			{
				Symbol *op2 = asm_pop();
				Symbol *op1 = symbol_table_peek();


				/* Less than or equal to means not superior
				 * and since it will be followed by a JMF which check
				 * whether the condition was false, it should work fine */
				asm_SUP(op1->address, op1->address, op2->address);

				asm_push(1);
				op2 = asm_pop();

				asm_SUB(op1->address, 1, op1->address);
				$$ = op1;
			}

		| EXPRESSION tGREATER_THAN EXPRESSION
			{
				Symbol *op2 = asm_pop();
				Symbol *op1 = symbol_table_peek();

				asm_SUP(op1->address, op1->address, op2->address);
				$$ = op1;
			}

		| EXPRESSION tGREATER_THAN_OR_EQUAL_TO EXPRESSION
			{
				Symbol *op2 = asm_pop();
				Symbol *op1 = symbol_table_peek();

				asm_INF(op1->address, op1->address, op2->address);

				asm_push(1);
				op2 = asm_pop();

				asm_SUB(op1->address, 1, op1->address);

				$$ = op1;
			}

		| EXPRESSION tDIFFERENT EXPRESSION
			{
				Symbol *op2 = asm_pop();
				Symbol *op1 = symbol_table_peek();

				asm_EQU(op1->address, op1->address, op2->address);
				/* Once we have the result X of the previous EQU instruction,
				 * We can do 1-X to get the result of the 'different' != operand */
				asm_push(1);
				Symbol *one = asm_pop();
				asm_SUB(op1->address, one->address, op1->address);

				$$ = op1;
			}

		| EXPRESSION tEQUAL_COMPARISON EXPRESSION
			{
				Symbol *op2 = asm_pop();
				Symbol *op1 = symbol_table_peek();

				asm_EQU(op1->address, op1->address, op2->address);

				$$ = op1;
			}
                
                
		| FUNCTION_CALL
			{
			}  


		| tINTEGER_NUMBER
			{ 
				asm_push($1);

				$$ = symbol_table_peek();
			}

		| tFLOAT_NUMBER
			{ 
			}

		| tIDENTIFIER
			{
				Symbol *s = symbol_table_get_symbol($1);

				if (s == NULL) {
					ABORT_ON_ERROR1("Undeclared symbol '%s'.", $1);
				}


				/* $1 is actually yylval.string */
				free(yylval.string);
				
				asm_push_from_address(s->address);

				$$ = s;
			}

		| tAMPERSAND tIDENTIFIER
		/* POINTER TYPE */
			{
				Symbol *s = symbol_table_get_symbol($2);

				if (s == NULL) {
					ABORT_ON_ERROR1("Undeclared symbol '%s'.", $2);
				}
			
				/* $2 is actually yylval.string */
				free(yylval.string);
				
				asm_push_address(s->address);
			}
		| tMUL EXPRESSION
		/* POINTER DEREFERENCING */
			{
				Symbol *s = asm_pop();

				asm_push_from_pointer_address(s->address);
			}
		;
           
FUNCTION_ARGS :	/* NOTHING */ 
		| EXPRESSION
		| EXPRESSION tCOMMA FUNCTION_ARGS_NOT_EMPTY
		;
 
FUNCTION_ARGS_NOT_EMPTY :	EXPRESSION
				| EXPRESSION tCOMMA FUNCTION_ARGS_NOT_EMPTY
				;
           
PRINTF :	tPRINTF tOP
			{
				asm_comment_now("printf");
			}
		FUNCTION_ARGS_NOT_EMPTY tCP
			{
				Symbol *addr = asm_pop();
				asm_PRI(addr->address);
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

POINTER_STAR :	tMUL
		| tMUL POINTER_STAR
		;

DECLARATION_TYPE :	TYPE					{ $$ = BASIC_TYPE; }
			| tCONST TYPE				{ $$ = BASIC_CONSTANT_TYPE; }
			/* int* */
			| TYPE POINTER_STAR			{ $$ = POINTER_TYPE; }
			/* int* const */
			| TYPE POINTER_STAR tCONST		{ $$ = POINTER_CONSTANT_TYPE; }
			/* const int* */
			| tCONST TYPE POINTER_STAR		{ $$ = POINTER_TO_CONSTANT_TYPE; }
			/* cons int* const */
			| tCONST TYPE POINTER_STAR tCONST	{ $$ = POINTER_CONSTANT_TO_CONSTANT_TYPE; }
			;

DECLARATION_AND_ASSIGNMENT :	DECLARATION_TYPE tIDENTIFIER tEQUAL
					{
						int comment_size = strlen($2) + 55;
						char *comment = malloc(comment_size);
						snprintf(comment, comment_size, "declaration and initialization of variable '%s'", $2);
						asm_comment_now(comment);
					}
				EXPRESSION
					{
						if (!symbol_table_is_available($2)) {
							ABORT_ON_ERROR1("Declaration of the already declared symbol '%s'", $2);
						}


						enum symbol_type st = $1;

						Symbol *s = symbol_table_new_symbol($2, st);
						symbol_table_set_initialized(s, INITIALIZED);

						Symbol *expr = asm_pop();

						asm_COP(s->address, expr->address);

						$$ = s;
					}
				;
       
DECLARATION :	DECLARATION_AND_ASSIGNMENT
		| DECLARATION_TYPE tIDENTIFIER
			{
				if (!symbol_table_is_available($2)) {
					ABORT_ON_ERROR1("Declaration of the already declared symbol '%s'", $2);
				}

				enum symbol_type st = $1;

				Symbol *s = symbol_table_new_symbol($2, $1);

				if (symbol_table_is_constant(s)) {
					WARN1("Symbol '%s' declared with 'const' class not initialized", $2);
				}
			}
		;

LVALUE :	tIDENTIFIER
			{
				struct _lvalue l = {$1, 0};
				$$ = l;
			}
		| tMUL LVALUE
			{
				struct _lvalue l = {$2.identifier, $2.pointer_depth+1};
				$$ = l;
			}

ASSIGNMENT :	LVALUE tEQUAL
			{
				int comment_size = strlen($1.identifier) + $1.pointer_depth + 80;
				char *comment = malloc(comment_size);
				int i;
				int comment_current_length = 0;

				snprintf(comment, comment_size, "assignment of variable '");
				comment_current_length = strlen(comment);

				for (i = 0; i < $1.pointer_depth; i++, comment_current_length = strlen(comment)) {
					snprintf(&(comment[comment_current_length]), comment_size - comment_current_length, "*");
				}

				snprintf(&(comment[comment_current_length]), comment_size - (comment_current_length), "%s'", $1.identifier);

				asm_comment_now(comment);
			}
		EXPRESSION
			{
				struct _lvalue lvalue = $1;
				int depth;
				Symbol *s = symbol_table_get_symbol($1.identifier);

				if (s == NULL) {
					ABORT_ON_ERROR1("Undeclared symbol '%s'", lvalue.identifier);
				}

				if (lvalue.pointer_depth == 0) {

					if (!symbol_table_is_constant(s)) {
						Symbol *expr = asm_pop();
						asm_COP(s->address, expr->address);

					} else {
						ABORT_ON_ERROR1("Symbol '%s' declared with 'const' class is not mutable", lvalue.identifier);
					}
				}
				else {

					if (!symbol_table_is_pointer(s)) {
						WARN1("Dereferencing non-pointer variable '%s', prone to cause SEGFAULT.", lvalue.identifier);
					}

					for (depth = 0; depth < lvalue.pointer_depth; depth++) {
						asm_push_from_pointer_address(s->address);
						s = asm_pop();
					}

					Symbol *expr = asm_pop();
					asm_STORE(s->address, expr->address);
				}
			}
		/*
		tMUL tIDENTIFIER tEQUAL
			{
				int comment_size = strlen($2) + 80;
				char *comment = malloc(comment_size);
				snprintf(comment, comment_size, "assignment of variable '*%s'", $2);
				asm_comment_now(comment);
			}
		EXPRESSION
			{
				Symbol *s = symbol_table_get_symbol($2);


				if (s == NULL) {
					ABORT_ON_ERROR1("Undeclared symbol '%s'", $2);
				}

				if (!symbol_table_is_pointer(s)) {
					WARN1("Dereferencing non-pointer variable '%s', prone to cause SEGFAULT.", $2);
				}

				if (!symbol_table_is_constant(s)) {
					Symbol *expr = asm_pop();
					asm_STORE(s->address, expr->address);

				} else {
					ABORT_ON_ERROR1("Symbol '%s' declared with 'const' class is not mutable", $2);
				}
			}
		| tIDENTIFIER tEQUAL
			{
				int comment_size = strlen($1) + 40;
				char *comment = malloc(comment_size);
				snprintf(comment, comment_size, "assignment of variable '%s'", $1);
				asm_comment_now(comment);
			}
		EXPRESSION
			{
				Symbol *s = symbol_table_get_symbol($1);


				if (s == NULL) {
					ABORT_ON_ERROR1("Undeclared symbol '%s'", $1);
				}

				if (!symbol_table_is_constant(s)) {
					Symbol *expr = asm_pop();
					asm_COP(s->address, expr->address);

				} else {
					ABORT_ON_ERROR1("Symbol '%s' declared with 'const' class is not mutable", $1);
				}
			}
		*/
		;


IF_STATEMENT : 	tIF 
			{
				asm_comment_now("if statement");
			}
		tOP EXPRESSION tCP 
			{
				/* We need to transform any non-zero expression to 1, since
				 * conditional jumps only recognize 0 (false) and 1 (true) */

				/* Compare the expression with a 0 value */

				translate_expression_to_conditional_expression();
				asm_comment_now("if block {");

				Symbol *condition = asm_pop();

				/* This jump allows us to skip the whole 'if' statement when the
				 * 'if' statement was false. The address it will point to will be set
				 * when we reach the beginning of that 'else' block, which we don't know
				 * the address of yet. Thus we only 'prepare' this conditional jump. */
				$1 = asm_prepare_JMF(condition->address);
			}
		BODY tELSE
			{
				/* If the condition of the 'if' statement was false, 
				 * this is where the code must go in order to skip the whole
				 * 'if' statement. So we need to provide that former conditional
				 * jump with our current assembly instruction line number.
				 * asm_get_next_line() + 1 since we need to go after the following jmp */
				asm_update_jmp($1, asm_get_next_line() + 1);

				/* This jump allows us to skip the whole 'else' statement when the
				 * 'if' statement was right. The address it will point to will be set
				 * when we reach the end of that 'else' block, which we don't know the
				 * address of yet. Thus we only 'prepare' this unconditional jump. */
				$1 = asm_prepare_JMP();
				asm_comment_now("else statement");
			}
		BODY
			{
				/* If the condition of the 'if' statement was right, 
				 * this is where the code must go in order to skip the whole
				 * 'else' statement. So we need to provide that former conditional
				 * jump with our current assembly instruction line number */
				asm_update_jmp($1, asm_get_next_line());
				asm_comment_now("} end of if-else statement");
			}

		
		| tIF
			{
				asm_comment_now("if statement");
			}
		tOP EXPRESSION tCP
			{
				asm_comment_now("if block {");

				/* We need to transform any non-zero expression to 1, since
				 * conditional jumps only recognize 0 (false) and 1 (true) */

				/* Compare the expression with a 0 value */
				translate_expression_to_conditional_expression();

				asm_update_jmp($1, asm_get_next_line());
			}
		BODY
			{
				asm_update_jmp($1, asm_get_next_line());
				asm_comment_now("} end of if statement");
			}
		;

		

WHILE_STATEMENT :	tWHILE tOP
				{
					asm_comment_now("while statement");

					/* Store the next asm instruction line number so that
					 * the end of the 'while' block can come back here and
					 * evaluate the conditional expression again and thus
					 * infer whether it needs to loop again or not */
					$2 = asm_get_next_line();
				}
			EXPRESSION tCP 
				{

					/* We need to transform any non-zero expression to 1, since
					 * conditional jumps only recognize 0 (false) and 1 (true) */

					/* Compare the expression with a 0 value */
					translate_expression_to_conditional_expression();

					Symbol *condition = asm_pop();

					$1 = asm_prepare_JMF(condition->address);
					asm_comment_now("while block {");
				}
			BODY
				{
					/* If the condition of the 'while' statement was false, 
					 * this is where the code must go in order to skip the whole
					 * while loop. So we just provide that conditional former jump 
					 * with our current assembly instruction line number */
					asm_update_jmp($1, asm_get_next_line() + 1);

					/* Once we reach the end of the 'while' block, we go back
					 * to the conditional expression in order to evaluate it again */
					asm_JMP($2);
					asm_comment_now("} end of while statement");
				}
			;


%%

int main(int argc, char *argv[])
{
	FILE *out_file;
	char *out_filename;
	char *out_extension = ".asm";

	if (argc > 1) {
		size_t filename_length = strlen(argv[1]) + strlen(out_extension);

		out_filename = malloc(filename_length + 1);
		snprintf(out_filename, filename_length + 1, "%s%s", argv[1], out_extension);

		out_file = fopen(out_filename, "w");
		yyin = fopen(argv[1], "r");
	} else {
		out_file = stdout;
		yyin = stdin;
	}

	init_output(out_file);
	init_symbol_table();

	yylval.string = NULL;

	yyparse();

	display_asm_instruction_table();
}

