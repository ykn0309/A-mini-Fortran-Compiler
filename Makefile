all:
	flex lexer.l
	bison -d parser.y
	gcc lex.yy.c parser.tab.c -o my_parser

p1:
	flex Practice1/lexer.l
	gcc Practice1/lex.yy.c -o Practice1/my_lexer
