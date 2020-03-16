%{
    int yydebug = 1; 
    #include <stdio.h>
    #include <stdlib.h>
    
    extern int yylex();
    
    int yyerror(char *s) {
        printf("=== YYERROR ===\n");
        exit(1);
        return 1;
    }
%}
%union { int nb;
         char * s;
         }

%token
    tMAIN
    tPRINTF
    
    
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
    
    
    tFLOAT_NUMBER
    
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

%token <nb> tINTEGER_NUMBER  
%token <s> tIDENTIFIER

%left tADD tSUB
%left tMUL tDIV tMOD
//%type <nb>   EXPRESSION // a completer

%%

S : tVOID tMAIN tOP tCP BODY 
        { printf("[MAIN]"); }
    ;

BODY : tOCB STATEMENT tCCB ;

STATEMENT : | tSEMI_C
            | BODY STATEMENT
            | DECLARATION tSEMI_C STATEMENT
                { printf("[DECLARATION]"); }

            | EXPRESSION tSEMI_C STATEMENT
                { printf("[EXPRESSION tSEMI_C]"); }
                
            | tRETURN EXPRESSION tSEMI_C STATEMENT
                { printf("[RETURN]"); }
           ;
           

           
EXPRESSION : EXPRESSION tADD EXPRESSION
                { 
                    printf("[%f + %f]", $1, $3);
                }
                
            | EXPRESSION tMUL EXPRESSION
                { printf("[%f * %f]", $1, $3); }
                
            | EXPRESSION tSUB EXPRESSION
                { printf("[%f / %f]", $1, $3); }
                
            | EXPRESSION tDIV EXPRESSION
                { printf("[DIV]"); }
                
            | EXPRESSION tMOD EXPRESSION
                { printf("[MODULO]"); }
                
                
            | FUNCTION_CALL
                { printf("[FUNCTION_CALL]"); }  
                
                  
            | tINTEGER_NUMBER
                { 
                    $$ = $1;
                    printf("[INTEGER_NUMBER]");
                }
                
            | tFLOAT_NUMBER
                { 
                    $$ = $1;
                    printf("[FLOAT_NUMBER = %f]", $1);
                }
                
            | tIDENTIFIER
                { printf("[IDENTIFIER]"); }
            ;
           
FUNCTION_ARGS :  
        | EXPRESSION
        | EXPRESSION tCOMMA FUNCTION_ARGS_NOT_EMPTY
        ;
 
FUNCTION_ARGS_NOT_EMPTY : EXPRESSION
                | EXPRESSION tCOMMA FUNCTION_ARGS_NOT_EMPTY
                ;
           
PRINTF : tPRINTF tOP FUNCTION_ARGS_NOT_EMPTY tCP
            { printf("[PRINTF]"); }
        ;
             
 
             
FUNCTION_CALL : PRINTF
                | tIDENTIFIER tOP FUNCTION_ARGS tCP
                ;
           
TYPE : tINT
       | tFLOAT
       | tDOUBLE
       | tCHAR
       ;
           
ASSIGNMENT : tIDENTIFIER tEQUAL EXPRESSION
                { printf("[ASSIGNMENT]"); }
             ;

DELCARATION_AND_ASSIGNMENT : TYPE ASSIGNMENT ;
       
DECLARATION : DELCARATION_AND_ASSIGNMENT
              | TYPE tIDENTIFIER
              ;
              
%%

int main(void) {
	yyparse();
}
