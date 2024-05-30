%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "keyword.h"

void yyerror(char *);
int yylineno;
char *yytext;
FILE *token_list;
FILE *identifier_table;
FILE *integer_table;
FILE *real_table;
char* token_filename = "token_list.txt";
char* identifier_filename = "identifier_table.txt";
char* integer_filename = "integer_table.txt";
char* real_filename = "real_table.txt";

int identifier_id = 0;
int integer_id = 0;
int real_id = 0;

struct Entry
{
    int id;
    union {
        char string_value[20];
        int int_value;
        float float_value;
    } value;
};

struct Entry identifier_array[100];
struct Entry integer_array[100];
struct Entry real_array[100];

int add_identifier_entry(char* string){
    for(int i = 0; i < identifier_id; i++){
        if(strcmp(string, identifier_array[i].value.string_value) == 0){
            return i;
        }
    }
    struct Entry e = {identifier_id, ""};
    strcpy(e.value.string_value, string);
    identifier_array[identifier_id] = e;
    identifier_id++;
    return identifier_id - 1;
}
int add_integer_entry(int v){
    struct Entry e = {.id = integer_id, .value.int_value = v};
    integer_array[integer_id] = e;
    integer_id++;
    return  integer_id - 1;
}
int add_real_entry(float v){
    struct Entry e = {.id = real_id, .value.float_value = v};
    real_array[real_id] = e;
    real_id++;
    return real_id - 1;
}

void add_token(int table_id, int value_id){
    char id[10];
    sprintf(id, "%d", value_id);
    char table[15];
    switch(table_id){
        case 0:
            strcpy(table, "KEYWORD");
            break;
        case 1:
            strcpy(table, "IDENTIFIER");
            break;
        case 2:
            strcpy(table, "INTEGER");
            break;
        case 3:
            strcpy(table, "REAL");
    }
    fprintf(token_list, table);
    fprintf(token_list, "\t");
    fprintf(token_list, id);
    fprintf(token_list, "\n");
}


%}

%option noyywrap

digit [0-9]
letter [a-zA-Z]
identifier (_|{letter})({letter}|{digit}|_){0,31}
integer_constant ([1-9]{digit}*)|0
real_constant {integer_constant}\.{digit}+

%%

PROGRAM         { printf("program ");add_token(0, PROGRAM); }
END             { printf("end ");add_token(0, END); }
DO              { printf("do ");add_token(0, DO); }
IF             { printf("if ");add_token(0, IF); }
THEN           { printf("then ");add_token(0, THEN); }
PRINT          { printf("print ");add_token(0, PRINT); }
INTEGER         { printf("int ");add_token(0, INTEGER); }
REAL            { printf("real ");add_token(0, REAL); }
{identifier}      { printf("id ");add_token(1, add_identifier_entry(yytext)); }
{integer_constant}    { printf("int_num ");add_token(2, add_integer_entry(atoi(yytext))); }
{real_constant}       { printf("real_num, %f", atof(yytext));add_token(3, add_real_entry(atof(yytext))); }
"::"            { printf(":: ");add_token(0, SCOPE); }
","             { printf(", ");add_token(0, COMMA);}
"="             { printf("= ");add_token(0, ASSIGN);}
"*"             { printf("* ");add_token(0, MULTIPLY);}
"/"             { printf("/ ");add_token(0, DIVIDE);}
"+"             { printf("+ ");add_token(0, PLUS);}
"-"             { printf("- ");add_token(0, MINUS);}
"("             { printf("( ");add_token(0, LPAREN);}
")"             { printf(") ");add_token(0, RPAREN);}
"\n"            { printf("\n");yylineno++; }
[ \t]           ;

%%

void yyerror(char *str) {
    fprintf(stderr, "Syntax error at line %d: %s\n", yylineno, str);
}

int main(){
    token_list = fopen(token_filename, "w");
    yylex();
    fclose(token_list);
    identifier_table = fopen(identifier_filename, "w");
    for(int i = 0; i < identifier_id; i++){
        char id[10];
        char value[20];
        sprintf(id, "%d", identifier_array[i].id);
        strcpy(value, identifier_array[i].value.string_value);
        fprintf(identifier_table, id);
        fprintf(identifier_table, "\t");
        fprintf(identifier_table, value);
        fprintf(identifier_table, "\n");
    }
    fclose(identifier_table);

    integer_table = fopen(integer_filename, "w");
    for(int i = 0; i < integer_id; i++){
        char id[10];
        char value[20];
        sprintf(id, "%d", integer_array[i].id);
        sprintf(value, "%d", integer_array[i].value.int_value);
        fprintf(integer_table, id);
        fprintf(integer_table, "\t");
        fprintf(integer_table, value);
        fprintf(integer_table, "\n");
    }
    fclose(integer_table);

    real_table = fopen(real_filename, "w");
    for(int i = 0; i < real_id; i++){
        char id[10];
        char value[20];
        sprintf(id, "%d", real_array[i].id);
        sprintf(value, "%f", real_array[i].value.float_value);
        fprintf(real_table, id);
        fprintf(real_table, "\t");
        fprintf(real_table, value);
        fprintf(real_table, "\n");
    }
    fclose(real_table);

}

//int yywrap() {
//    return 1;
//}
