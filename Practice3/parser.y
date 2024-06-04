%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(char *);

int loop_start = 0;
int jump_out_else = 0;

/* 四元式结构 */
typedef struct {
    char *op;
    char *arg1;
    char *arg2;
    char *result;
} Quad;

/* 四元式数组和索引 */
Quad quads[100];
int quadIndex = 0;

/* 生成四元式的函数 */
void emit(char *op, char *arg1, char *arg2, char *result) {
    quads[quadIndex].op = strdup(op);
    quads[quadIndex].arg1 = arg1 ? strdup(arg1) : NULL;
    quads[quadIndex].arg2 = arg2 ? strdup(arg2) : NULL;
    quads[quadIndex].result = result ? strdup(result) : NULL;
    quadIndex++;
}

/* 打印四元式 */
void printQuads() {
    // 写入文件output.txt中
    FILE *fout = fopen("output.txt", "w");
    if (fout == NULL) {
        perror("Cannot open output.txt");
        exit(EXIT_FAILURE);
    }

    for (int i = 0; i < quadIndex; i++) {
        fprintf(fout, "(%d)(%s, %s, %s, %s)\n",
                i,
                quads[i].op,
                quads[i].arg1 ? quads[i].arg1 : "_",
                quads[i].arg2 ? quads[i].arg2 : "_",
                quads[i].result ? quads[i].result : "_");
    }

    fclose(fout);
    // for (int i = 0; i < quadIndex; i++) {
    //     printf("(%d)(%s, %s, %s, %s)\n",
    //            i,
    //            quads[i].op,
    //            quads[i].arg1 ? quads[i].arg1 : "_",
    //            quads[i].arg2 ? quads[i].arg2 : "_",
    //            quads[i].result ? quads[i].result : "_");
    // }
}
%}

%union {
    char *str;
    int int_val;
    double real_val;
}

%token <str> PROGRAM END DO IF THEN PRINT INTEGER REAL IDENTIFIER DOLLAR
%token <int_val> INTEGER_CONSTANT
%token <real_val> REAL_CONSTANT
%token ASSIGN MULTIPLY DIVIDE PLUS MINUS LPAREN RPAREN COMMA SCOPE

%type <str> program body declaration_list declaration type_specifier variable_list statement_list statement assignment_statement if_statement do_loop_statement print_statement expression term factor variable constant

%%

program:
    PROGRAM IDENTIFIER body END PROGRAM IDENTIFIER DOLLAR {
        printQuads(); // 打印四元式
    }
    ;

body:
    declaration_list statement_list
    ;

declaration_list:
    /* empty */ { $$ = NULL; }
    | declaration_list declaration { $$ = $1; }
    ;

declaration:
    type_specifier SCOPE variable_list {
        // 获取变量列表中的每个变量，并生成对应的声明四元式
        /*char *variables = $3;
        char *token = strtok(variables, ",");
        while (token != NULL) {
            // 生成单个变量的声明四元式
            emit("DECL", $1, NULL, token);
            token = strtok(NULL, ",");
        }*/
    }
    ;

type_specifier:
    INTEGER { $$ = "int"; }
    | REAL { $$ = "real"; }
    ;

variable_list:
    IDENTIFIER { $$ = $1; }
    | variable_list COMMA IDENTIFIER {
        // 将变量名连接成字符串
        char *temp = (char*)malloc(strlen($1) + strlen($3) + 2);
        sprintf(temp, "%s,%s", $1, $3);
        $$ = temp;
    }
    ;

statement_list:
    /* empty */ { $$ = NULL; }
    | statement_list statement { $$ = $1; }
    ;

statement:
    assignment_statement
    | if_statement
    | do_loop_statement
    | print_statement
    ;

assignment_statement:
    variable ASSIGN expression {
        // 生成赋值的四元式
        emit(":=", $3, NULL, $1);
    }
    ;

if_statement:
    IF LPAREN expression RPAREN THEN {
        // 生成条件跳转的四元式，跳转目标为 statement_list 之后的四元式编号
        int jump_false_quad = quadIndex;
        emit("JUMPF", $3, NULL, NULL); // 占位，稍后回填

        // 回填跳转目标
        char temp[10];
        snprintf(temp, 10, "%d", quadIndex + 1); // 回填到下一条指令
        quads[jump_false_quad].result = strdup(temp);
        
        // else部分
        jump_out_else = quadIndex;
        emit("JUMP", NULL, NULL, NULL); // 占位，稍后回填

    } statement_list END IF {// 回填条件不满足的跳转目标
        char end_label[10];
        snprintf(end_label, 10, "%d", quadIndex); // 回填到下一条指令
        quads[jump_out_else].result = strdup(end_label);}
    ;

do_loop_statement:
    DO variable ASSIGN expression {
        // 初始化循环变量
        emit(":=", $4, NULL, $2);
        loop_start = quadIndex;} COMMA expression statement_list END DO {
        char *start_label = (char *)malloc(10);
        snprintf(start_label, 10, "%d", loop_start);

        // 循环条件判断
        int cond_quad = quadIndex;
        char *cond_label = (char *)malloc(10);
        snprintf(cond_label, 10, "t%d", quadIndex);

        // 比较循环变量和终止条件
        emit(">", $2, $7, cond_label);

        // 条件跳转，跳出循环
        int jump_out_quad = quadIndex;
        emit("JUMPF", cond_label, NULL, NULL); // 占位，稍后回填

        // 循环体
        $$ = $7;

        // 增加循环变量
        char *temp = (char *)malloc(10);
        snprintf(temp, 10, "t%d", quadIndex);
        emit("+", $2, "1", temp);
        emit(":=", temp, NULL, $2);

        // 跳回循环开始
        emit("JUMP", NULL, NULL, start_label);

        // 回填循环结束的跳转目标
        char end_label[10];
        snprintf(end_label, 10, "%d", quadIndex); // 回填到下一条指令
        quads[jump_out_quad].result = strdup(end_label);
    }
    ;

print_statement:
    PRINT MULTIPLY COMMA expression {
        // 生成打印的四元式
        emit("PRINT", $4, NULL, NULL);
    }
    ;

expression:
    term { $$ = $1; }
    | expression PLUS term {
        // 生成加法的四元式
        char *temp = (char*)malloc(10);
        sprintf(temp, "t%d", quadIndex);
        emit("+", $1, $3, temp);
        $$ = temp;
    }
    | expression MINUS term {
        // 生成减法的四元式
        char *temp = (char*)malloc(10);
        sprintf(temp, "t%d", quadIndex);
        emit("-", $1, $3, temp);
        $$ = temp;
    }
    ;

term:
    factor { $$ = $1; }
    | term MULTIPLY factor {
        // 生成乘法的四元式
        char *temp = (char*)malloc(10);
        sprintf(temp, "t%d", quadIndex);
        emit("*", $1, $3, temp);
        $$ = temp;
    }
    | term DIVIDE factor {
        // 生成除法的四元式
        char *temp = (char*)malloc(10);
        sprintf(temp, "t%d", quadIndex);
        emit("/", $1, $3, temp);
        $$ = temp;
    }
    ;

factor:
    variable { $$ = $1; }
    | constant { $$ = $1; }
    | LPAREN expression RPAREN { $$ = $2; }
    ;

variable:
    IDENTIFIER { $$ = $1; }
    ;

constant:
    INTEGER_CONSTANT {
        char *temp = (char*)malloc(10);
        sprintf(temp, "%d", $1);
        $$ = temp;
    }
    | REAL_CONSTANT {
        char *temp = (char*)malloc(10);
        sprintf(temp, "%f", $1);
        $$ = temp;
    }
    ;
%%

int main() {
    yyparse();
    return 0;
}
