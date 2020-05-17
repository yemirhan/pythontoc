all: lex yacc
	g++ lex.yy.c y.tab.c -ll -o prelab

yacc: prelab.y
	yacc -d prelab.y

lex: prelab.l
	lex prelab.l
clean:
	rm lex.yy.c y.tab.c  y.tab.h  prelab
