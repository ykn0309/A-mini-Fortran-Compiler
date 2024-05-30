all:
	flex lexer.l
	bison -d parser.y
	gcc lex.yy.c parser.tab.c -o my_parser