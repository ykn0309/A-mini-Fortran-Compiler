%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

void yyerror(char *);
int yylineno; // 声明行号变量
char *yytext; // 声明字符位置变量
%}

%option noyywrap

digit [0-9]
letter [a-zA-Z]
identifier (_|{letter})({letter}|{digit}|_){0,31}
integer_constant ([1-9]{digit}*)|0
real_constant {integer_constant}\.{digit}+

%%

PROGRAM         { printf("program\n");return PROGRAM; }
END             { printf("end\n");return END; }
DO              { printf("do\n");return DO; }
IF             { printf("if\n");return IF; }
THEN           { printf("then\n");return THEN; }
PRINT          { printf("print\n");return PRINT; }
INTEGER         { printf("int\n");return INTEGER; }
REAL            { printf("real\n");yylval.str = strdup(yytext); return REAL; }
{identifier}      { printf("id\n");yylval.str = strdup(yytext); return IDENTIFIER; }
{integer_constant}    { printf("int_num\n");yylval.int_val = atoi(yytext); return INTEGER_CONSTANT; }
{real_constant}       { printf("real_num\n");yylval.real_val = atof(yytext); return REAL_CONSTANT; }
"::"            { printf("::\n");return SCOPE; }
","             { printf(",\n");return COMMA; }
"="             { printf("=\n");return ASSIGN; }
"*"             { printf("*\n");return MULTIPLY; }
"/"             { printf("/\n");return DIVIDE; }
"+"             { printf("+\n");return PLUS; }
"-"             { printf("-\n");return MINUS; }
"("             { printf("(\n");return LPAREN; }
")"             { printf(")\n");return RPAREN; }
"."             { printf(".\n");return DOT; }
"\n"            { printf("eol\n");yylineno++; }
[ \t]           ; // 忽略空格和制表符

%%

void yyerror(char *str) {
    fprintf(stderr, "Syntax error at line %d: %s\n", yylineno, str);
}

//int yywrap() {
//    return 1;
//}
