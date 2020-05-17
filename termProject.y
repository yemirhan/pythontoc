%{
	#include <stdio.h>
	#include <iostream>
	#include <string>
	#include <vector> 
	#include "y.tab.h"
	using namespace std;

	extern FILE *yyin;
	extern int yylex();
	extern int linenum;
	void yyerror(string s);
	
%}

%union
{
	char * str;
	int inum;
	float fnum;
}
%token PLUS MINUS MULTP DIV QUOTE EQUAL 
%token <str> VAR
%token <inum> INTRSV 
%token <fnum> FLTRSV
%left PLUS

%%
program:
    statement
	|
	statement program
    ;
statement:
    VAR EQUAL variablestatement
    ;
variablestatement:
    types
    |
    doesexists
    |
    variablestatement assignment types
    ;
types:
    INTRSV
    |
    FLTRSV
    |
    QUOTE VAR QUOTE
    ;
assignment:
    PLUS
    |
    MINUS
    |
    MULTP
    |
    DIV
    ;
doesexists:

    ;
%%

void yyerror(string s){
	cout<<"error at line: "<<linenum<<endl;
}
int yywrap(){
	return 1;
}

int main(int argc, char *argv[])
{
    /* Call the lexer, then quit. */

    yyin=fopen(argv[1],"r");
    yyparse();
    fclose(yyin);
    return 0;
}
