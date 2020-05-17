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
    vector<string> strarray;
	vector<string> intarray;
	vector<string> floatarray;
    string finalOutput="void main()\n{\n";
	
%}

%union
{
	char * str;
	int inum;
	float fnum;
}
%token QUOTE EQUAL 
%token <str> VAR ASSIGN
%token <inum> INTRSV 
%token <fnum> FLTRSV
%type <inum> variablestatement types doesexists
%left ASSIGN

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
    variablestatement ASSIGN types
    ;
types:
    INTRSV {$$ = 1;expr+=to_string($1)+"+";}
    |
    FLTRSV {$$ = 2;string flt=to_string($1);expr+=flt.substr(0,3)+"+";}
    |
    QUOTE VAR QUOTE {$$ = 3;expr+=string($2)+"+";}
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
