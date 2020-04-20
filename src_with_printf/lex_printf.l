

DIGIT [0-9]
INTEGER [+-]?{DIGIT}+

EXPONENTIAL_FLOAT {INTEGER}[.]{DIGIT}+(e|E)({INTEGER}|"("{INTEGER}")")
NON_EXPONENTIAL_FLOAT {INTEGER}[.]{DIGIT}+
FLOAT (({EXPONENTIAL_FLOAT})|({NON_EXPONENTIAL_FLOAT}))

IDENTIFIER [_a-zA-Z][_a-zA-Z0-9]*

SPACE [ \t]+
NEWLINE [\n]+
BLANKS ({SPACE} | {NEWLINE})+

%%
"(" {
        printf("[OP]");
    } 
    
")" {
        printf("[CP]");
    }
    
"!" {
        printf("[E-MARK]");
    }     
    
"{" {
        printf("[OCB]");
    } 
        
"}" {
        printf("[CCB]");
    }

"[" {
        printf("[OB]");
    } 
        
"]" {
        printf("[CB]");
    }

";" {
        printf("[SEMI-C]");
    }

"," {
        printf("[COMMA]");
    }    
    
":" {
        printf("[COLON]");
    }    
    
"?" {
        printf("[I-MARK]");
    }
              
int {
        printf("[INT]");
    }
    
float {
        printf("[FLOAT]");
      }
    
char {
        printf("[CHAR]");
     }
    
double {
        printf("[DOUBLE]");
       }
    
void {
        printf("[VOID]");
     }
    
long {
        printf("[LONG]");
     }

signed {
        printf("[SIGNED]");
       }
    
unsigned {
        printf("[UNSIGNED]");
         }
    
short {
        printf("[SHORT]");
      }
      
const {
        printf("[CONST]");
      }
     
if {
        printf("[IF]");
      }
      
else {
        printf("[ELSE]");
      } 
      
while {
        printf("[WHILE]");
      }
      
for {
        printf("[FOR]");
      }
      
do {
        printf("[DO]");
      }
      
switch {
        printf("[SWITCH]");
      }
      
break {
        printf("[BREAK]");
      }
      
continue {
        printf("[CONTINUE]");
      }
      
default {
        printf("[DEFAULT]");
      }
                       
return {
        printf("[RETURN]");
      } 
      
main    {
            printf("[MAIN]");
        }
       
{INTEGER} { printf("[INTEGER_EXPRESSION]\n"); }
       
{FLOAT} { printf("[FLOAT_EXPRESSION]\n"); }

            
{IDENTIFIER} {
                printf("[IDENTIFIER]");
             }
"*" {
        printf("[*]");
    }
    
"/" {
        printf("[/]");
    }   
     
"%" {
        printf("[%%]");
    }  
                    
"+" {
        printf("[+]");
    }

"-" {
        printf("[-]");
    }

"=" {
        printf("[=]");
    }

{NEWLINE} {
            printf("[NEWLINE]\n");
          }    

{SPACE} {
            printf("[SPACE]");
        }


%%

int yywrap(void) {}

int main(void) {
    yylex();
    return 1;
}
