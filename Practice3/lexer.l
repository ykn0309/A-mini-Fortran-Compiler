%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

void yyerror(char *);
int yylineno = 1; // 声明行号变量
char *yytext; // 声明字符位置变量
%}

%option noyywrap

digit [0-9]
letter [a-zA-Z]
identifier (_|{letter})({letter}|{digit}|_){0,31}
integer_constant ([1-9]{digit}*)|0
real_constant {integer_constant}\.{digit}+

%%

PROGRAM         { return PROGRAM; }
END             { return END; }
DO              { return DO; }
IF              { return IF; }
THEN            { return THEN; }
PRINT           { return PRINT; }
INTEGER         { return INTEGER; }
REAL            { yylval.str = strdup(yytext); return REAL; }
{identifier}    { yylval.str = strdup(yytext); return IDENTIFIER; }
{integer_constant} { yylval.int_val = atoi(yytext); return INTEGER_CONSTANT; }
{real_constant} { yylval.real_val = atof(yytext); return REAL_CONSTANT; }
"::"            { return SCOPE; }
","             { return COMMA; }
"="             { return ASSIGN; }
"*"             { return MULTIPLY; }
"/"             { return DIVIDE; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"("             { return LPAREN; }
")"             { return RPAREN; }
"\n"            { yylineno++; }
"$"             { return DOLLAR; }
[ \t]           ; // 忽略空格和制表符

%%

void yyerror(char *str) {
    fprintf(stderr, "Syntax error at line %d: %s\n", yylineno, str);
}

//int yywrap() {
//    return 1;
//}
