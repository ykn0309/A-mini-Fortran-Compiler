all:
	bison -d parser.y

	flex lexer.l

	gcc parser.tab.c lex.yy.c -o fortran_compiler

