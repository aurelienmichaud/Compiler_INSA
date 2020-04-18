
%{
	#include <stdlib.h>
	#include <string.h>

	#include "y.tab.h"
	#include "symbol_table.h"
%}

DIGIT	[0-9]
INTEGER	[+-]?{DIGIT}+

EXPONENTIAL_FLOAT	{INTEGER}[.]{DIGIT}+(e|E)({INTEGER}|"("{INTEGER}")")
NON_EXPONENTIAL_FLOAT	{INTEGER}[.]{DIGIT}+
FLOAT			(({EXPONENTIAL_FLOAT})|({NON_EXPONENTIAL_FLOAT}))

IDENTIFIER [_a-zA-Z][_a-zA-Z0-9]*

SPACE	[ \t]+
NEWLINE	[\n]+
BLANKS	(({SPACE})|({NEWLINE}))+

%%

"("		{ return tOP; } 
")"		{ return tCP; }
"{"		{
			symbol_table_increase_depth();
			return tOCB;
		} 
"}"		{
			symbol_table_decrease_depth();
			return tCCB;
		}
"["		{ return tOB; } 
"]"		{ return tCB; }

";"		{ return tSEMI_C; }
","		{ return tCOMMA; }    
":"		{ return tCOLON; }    
"?"		{ return tQ_MARK; }
"!"		{ return tE_MARK; }     

"<="		{ return tLESS_THAN_OR_EQUAL_TO; }
"<"		{ return tLESS_THAN; }
">="		{ return tGREATER_THAN_OR_EQUAL_TO; }
">"		{ return tGREATER_THAN; }
"!="		{ return tDIFFERENT; }
"=="		{ return tEQUAL_COMPARISON; }

int		{ return tINT; }
float		{ return tFLOAT; }
char		{ return tCHAR; }
double		{ return tDOUBLE; }
void		{ return tVOID; }

long		{ return tLONG; }
signed		{ return tSIGNED; }
unsigned	{ return tUNSIGNED; }
short		{ return tSHORT; }
const		{ return tCONST; }

if		{ return tIF; }
else		{ return tELSE; } 
while		{ return tWHILE; }
for		{ return tFOR; }
do		{ return tDO; }
switch		{ return tSWITCH; }
break 		{ return tBREAK; }
continue	{ return tCONTINUE; }
default		{ return tDEFAULT; }
                       

return		{ return tRETURN; }
 
main		{
			yylval.string = NULL;
			return tMAIN;
		}
printf		{ return tPRINTF; }
       
{INTEGER}	{
			yylval.integer_nb = atoi(yytext);
			return tINTEGER_NUMBER;
		}
{FLOAT}		{ 
			yylval.float_nb = atof(yytext);
			return tFLOAT_NUMBER;
		}

{IDENTIFIER}	{
			/* FIXME : yylval cannot seem to be NULLed firsthand
			printf("BEFORE\n");
			free(yylval.string);
			printf("AFTER\n");
			*/

			yylval.string = strdup(yytext);
			return tIDENTIFIER;
		}

"*"	{ return tMUL; }
"/"	{ return tDIV; }   
"%"	{ return tMOD; }            
"+"	{ return tADD; }
"-"	{ return tSUB; }

"="	{ return tEQUAL; }

{NEWLINE}	{ }    
{SPACE}		{ }

%%

int yywrap(void) {}
/*
int main(void) {
    yylex();
    return 1;
}
*/
