%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern int yylineno;
int yylex(void);
void yyerror(const char *msg);
int if_error = 0;
%}

%union {
    char *str;
    int int_val;
    double real_val;
}

%token PROGRAM END DO IF THEN PRINT INTEGER REAL IDENTIFIER INTEGER_CONSTANT REAL_CONSTANT TYPE_SPECIFIER ASSIGN MULTIPLY DIVIDE PLUS MINUS LPAREN RPAREN DOT COMMA SCOPE EOL
%type <str> type_specifier variable_list variable declaration_list statement_list expression term factor constant

%%

program: PROGRAM IDENTIFIER body END PROGRAM IDENTIFIER
        ;

body: declaration_list statement_list
    ;

declaration_list: /* empty */
                | declaration_list declaration
                ;

declaration: type_specifier SCOPE variable_list
            ;

type_specifier: INTEGER
              | REAL
              ;

variable_list: IDENTIFIER
             | variable_list COMMA IDENTIFIER
             ;

statement_list: /* empty */
              | statement_list statement
              ;

statement: assignment_statement
         | if_statement
         | do_loop_statement
         | print_statement
         ;

assignment_statement: variable ASSIGN expression
                     ;

if_statement: IF LPAREN expression RPAREN THEN statement_list END IF
            ;

do_loop_statement: DO variable ASSIGN INTEGER_CONSTANT COMMA INTEGER_CONSTANT statement_list END DO
                 | DO variable ASSIGN IDENTIFIER COMMA IDENTIFIER statement_list END DO
                 | DO variable ASSIGN INTEGER_CONSTANT COMMA IDENTIFIER statement_list END DO
                 | DO variable ASSIGN IDENTIFIER COMMA INTEGER_CONSTANT statement_list END DO
                 ;

print_statement: PRINT MULTIPLY COMMA expression
                ;

expression: term
          | expression PLUS term
          | expression MINUS term
          ;

term: factor
    | term MULTIPLY factor
    | term DIVIDE factor
    ;

factor: variable
      | constant
      | LPAREN expression RPAREN
      ;

variable: IDENTIFIER
        ;

constant: INTEGER_CONSTANT
        | REAL_CONSTANT
        ;

%%

int main() {
    yyparse();
    if(!if_error) printf("\033[47;42mPass!\033[0m\n");
    return 0;
}

void yyerror(const char *msg) {
    fprintf(stderr, "\033[47;31mError at line %d: %s\033[0m\n", yylineno, msg);
    if_error =1;
}
