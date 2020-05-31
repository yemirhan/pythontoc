all: lex yacc
	g++ lex.yy.c y.tab.c -ll -o project

yacc: termProject.y
	yacc -d termProject.y

lex: termProject.l
	lex termProject.l

clean:
	rm lex.yy.c y.tab.c  y.tab.h  termProject
