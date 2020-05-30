all: lex yacc
	g++ lex.yy.c y.tab.c -ll -o project

yacc: tp3.y
	yacc -d tp3.y

lex: termProject.l
	lex termProject.l

clean:
	rm lex.yy.c y.tab.c  y.tab.h  termProject
