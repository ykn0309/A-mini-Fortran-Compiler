%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(char *);
extern int yylineno;
extern void init_table();
extern char* identifier_table[100];

int identifier_type_table[100]; //保存标识符的类型

int loop_start = 0;
int jump_out_else = 0;

struct exp_t{
    char *str;
    int type;
};

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
    // printf("%s\n", &result);
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
    struct exp_t* exp;
}

%token <str> PROGRAM END DO IF THEN PRINT INTEGER REAL IDENTIFIER DOLLAR
%token <int_val> INTEGER_CONSTANT
%token <real_val> REAL_CONSTANT
%token ASSIGN MULTIPLY DIVIDE PLUS MINUS LPAREN RPAREN COMMA SCOPE

%type <str> program body declaration_list declaration type_specifier variable_list statement_list statement assignment_statement if_statement do_loop_statement print_statement

%type <exp> expression term factor variable constant

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
        int type = 0; //int类型
        if(strcmp($1, "real") == 0)
            type = 1; //real类型
        char *variables = $3;
        char *token = strtok(variables, ",");
        while (token != NULL) {
            // 生成单个变量的声明四元式
            // emit("DECL", $1, NULL, token);
            identifier_type_table[atoi(token)] = type;
            token = strtok(NULL, ",");
        }
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
        if($1->type != $3->type){
            char* t1 = $1->type == 0 ? "int" : "real";
            char* t2 = $3->type == 0 ? "int" : "real";
            printf("Type error at %d! Type of %s is %s while type of %s is %s.\n", yylineno, $1->str, t1, $3->str, t2);
        }
        emit(":=", $3->str, NULL, $1->str);
    }
    ;

if_statement:
    IF LPAREN expression RPAREN THEN {
        // 生成条件跳转的四元式，跳转目标为 statement_list 之后的四元式编号
        int jump_false_quad = quadIndex;
        emit("JUMPF", $3->str, NULL, NULL); // 占位，稍后回填

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
        if($2->type == 1){
            printf("Type error at %d! Type of %s should be int.\n", yylineno, $2->str);
        }
        emit(":=", $4->str, NULL, $2->str);
        loop_start = quadIndex;} COMMA expression statement_list END DO {
        char *start_label = (char *)malloc(10);
        snprintf(start_label, 10, "%d", loop_start);

        // 循环条件判断
        int cond_quad = quadIndex;
        char *cond_label = (char *)malloc(10);
        snprintf(cond_label, 10, "t%d", quadIndex);

        // 比较循环变量和终止条件
        if($7->type == 1){
            printf("Type error at %d! Type of %s should be int.\n", yylineno, $7->str);
        }
        emit(">", $2->str, $7->str, cond_label);

        // 条件跳转，跳出循环
        int jump_out_quad = quadIndex;
        emit("JUMPF", cond_label, NULL, NULL); // 占位，稍后回填

        // 循环体
        $$ = $7->str;

        // 增加循环变量
        char *temp = (char *)malloc(10);
        snprintf(temp, 10, "t%d", quadIndex);
        emit("+", $2->str, "1", temp);
        emit(":=", temp, NULL, $2->str);

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
        emit("PRINT", $4->str, NULL, NULL);
    }
    ;

expression:
    term { $$->str = $1->str; $$->type = $1->type; }
    | expression PLUS term {
        // 生成加法的四元式
        if($1->type != $3->type){
            char* t1 = $1->type == 0 ? "int" : "real";
            char* t2 = $3->type == 0 ? "int" : "real";
            printf("Type error at %d! Type of %s is %s while type of %s is %s.\n", yylineno, $1->str, t1, $3->str, t2);
        }
        char *temp = (char*)malloc(10);
        sprintf(temp, "t%d", quadIndex);
        emit("+", $1->str, $3->str, temp);
        $$ = (struct exp_t*)malloc(sizeof(struct exp_t));
        $$->str = temp;
        $$->type = $1->type;
    }
    | expression MINUS term {
        // 生成减法的四元式
        if($1->type != $3->type){
            char* t1 = $1->type == 0 ? "int" : "real";
            char* t2 = $3->type == 0 ? "int" : "real";
            printf("Type error at %d! Type of %s is %s while type of %s is %s.\n", yylineno, $1->str, t1, $3->str, t2);
        }
        char *temp = (char*)malloc(10);
        sprintf(temp, "t%d", quadIndex);
        emit("-", $1->str, $3->str, temp);
        $$ = (struct exp_t*)malloc(sizeof(struct exp_t));
        $$->str = temp;
        $$->type = $1->type;
    }
    ;

term:
    factor { $$ = (struct exp_t*)malloc(sizeof(struct exp_t)); $$->str = $1->str; $$->type = $1->type; }
    | term MULTIPLY factor {
        // 生成乘法的四元式
        char *temp = (char*)malloc(10);
        sprintf(temp, "t%d", quadIndex);
        emit("*", $1->str, $3->str, temp);
        $$ = (struct exp_t*)malloc(sizeof(struct exp_t));
        $$->str = temp;
        $$->type = ($1->type == 1 || $3->type == 1) ? 1 : 0;
    }
    | term DIVIDE factor {
        // 生成除法的四元式
        char *temp = (char*)malloc(10);
        sprintf(temp, "t%d", quadIndex);
        emit("/", $1->str, $3->str, temp);
        $$ = (struct exp_t*)malloc(sizeof(struct exp_t));
        $$->str = temp;
        $$->type = ($1->type == 1 || $3->type == 1) ? 1 : 0;
    }
    ;

factor:
    variable { 
        $$ = (struct exp_t*)malloc(sizeof(struct exp_t));
        $$->str = $1->str;
        $$->type = $1->type;
    }
    | constant { $$ = (struct exp_t*)malloc(sizeof(struct exp_t)); $$->str = $1->str; $$->type = $1->type; }
    | LPAREN expression RPAREN { $$ = (struct exp_t*)malloc(sizeof(struct exp_t)); $$->str = $2->str; $$->type = $2->type; }
    ;

variable:
    IDENTIFIER { 
        $$ = (struct exp_t*)malloc(sizeof(struct exp_t)); 
        char *id = (char*)malloc(10);
        sprintf(id, "id%s", $1);
        $$->str = id;
        $$->type = identifier_type_table[atoi($1)];
        }
    ;

constant:
    INTEGER_CONSTANT {
        $$ = (struct exp_t*)malloc(sizeof(struct exp_t));
        char *temp = (char*)malloc(10);
        sprintf(temp, "%d", $1);
        $$->str = temp;
        $$->type = 0;
    }
    | REAL_CONSTANT {
        $$ = (struct exp_t*)malloc(sizeof(struct exp_t));
        char *temp = (char*)malloc(10);
        sprintf(temp, "%f", $1);
        $$->str = temp;
        $$->type = 1;
    }
    ;
%%

int main() {
    init_table();
    yyparse();
    return 0;
}
