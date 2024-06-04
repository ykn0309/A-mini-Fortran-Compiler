%{
#include <stdio.h>
#include "parser.tab.h"

int yylineno = 1;
int yycolno = 1;
%}

%option noyywrap

%%

KEYWORD[[:space:]]+[0-9]+   { 
                                yycolno += yyleng;
                                int num;
                                if (sscanf(yytext, "%*s %d", &num) == 1) {
                                    switch(num) {
                                        case 0:     return PROGRAM;     break;
                                        case 1:     return END ;        break;
                                        case 2:     return INTEGER ;    break;
                                        case 3:     return REAL ;       break;
                                        case 4:     return IF ;         break;
                                        case 5:     return THEN ;       break;
                                        case 6:     return DO ;         break;
                                        case 7:     return PRINT ;      break;
                                        case 8:     return PLUS ;       break;
                                        case 9:     return MINUS ;      break;
                                        case 10:    return MULTIPLY ;   break;
                                        case 11:    return DIVIDE ;     break;
                                        case 12:    return LPAREN ;     break;
                                        case 13:    return RPAREN ;     break;
                                        case 14:    return SCOPE ;      break;
                                        case 15:    return ASSIGN ;     break;
                                        case 16:    return COMMA ;      break;
                                        case 17:    return DOLLAR;
                                    }
                                }
                            }

IDENTIFIER  {yycolno+=yyleng; return IDENTIFIER;}

INTEGER     {yycolno+=yyleng; return INTEGER_CONSTANT;}

REAL        {yycolno+=yyleng; return REAL_CONSTANT;}

"\n"        {yycolno = 1; yylineno++;}

.           {yycolno ++;}

%%

// int main() {
//     yylex();
//     return 0;
// }
