%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

void yyerror(char *);

int yylineno = 1;
int integer_constant = 0;
float real_constant = 0.0;

int integer_table[100];
float real_table[100];
char* identifier_table[100];

void init_table(){
    FILE* integer_file = fopen("integer_table.txt", "r");
    FILE* real_file = fopen("real_table.txt", "r");
    FILE* identifier_file = fopen("identifier_table.txt", "r");
    int id, int_value;
    while (fscanf(integer_file, "%d %d", &id, &int_value) == 2) {
        integer_table[id] = int_value;
    }
    float real_value;
    while (fscanf(real_file, "%d %f", &id, &real_value) == 2) {
        real_table[id] = real_value;
    }
    char* identifier;
    while (fscanf(identifier_file, "%d %s", &id, &identifier) == 2) {
        identifier_table[id] = identifier;
    }
    
    fclose(integer_file);
    fclose(real_file);
    fclose(identifier_file);
}

%}

%option noyywrap

%%

KEYWORD[[:space:]]+[0-9]+   {   //printf(yytext);
                                //printf("\n");
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

IDENTIFIER[[:space:]]+[0-9]+    {   //printf(yytext); 
                                    //printf("\n");
                                    int num;
                                    if (sscanf(yytext, "%*s %d", &num) == 1){
                                        char str[2];
                                        str[0] = num + '0';
                                        str[1] = '\0';
                                        yylval.str = strdup(str);
                                        return IDENTIFIER;
                                    }
                                }
                                    

INTEGER[[:space:]]+[0-9]+       {   //printf(yytext); 
                                    //printf("\n");
                                    int num;
                                    if (sscanf(yytext, "%*s %d", &num) == 1){
                                        yylval.int_val = integer_table[num];
                                        return INTEGER_CONSTANT;
                                    }
                                }

REAL[[:space:]]+[0-9]+          {   //printf(yytext); 
                                    //printf("\n");
                                    int num;
                                    if (sscanf(yytext, "%*s %d", &num) == 1){
                                        yylval.real_val = real_table[num];
                                        return REAL_CONSTANT;
                                    }
                                }

"\n"        {yylineno++; }

"$"        {return DOLLAR;}

.           ;



%%
void yyerror(char *str) {
    fprintf(stderr, "Syntax error at line %d: %s\n", yylineno, str);
}