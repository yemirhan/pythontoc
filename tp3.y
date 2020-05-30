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
	struct nameStruct {
		string name;
		bool isInt;
		bool isFlt;
		bool isStr;
		int lasttype;
	}
	vector<nameStruct> varArray;
    string finalOutput="void main()\n\n";
	string expr="";
	string declpart="";
	void throwerror(int i){
		if(i==1){ //Type mismatch
			cout << "Type mismatch in line: " << linenum << endl;
			exit(0);
		}
		if(i==2){ //Untyped variable
			cout << "Untyped variable is used in line: " << linenum << endl;
			exit(1);
		}
	}

	FILE *output;
%}

%union
{
	char * str;
	int inum;
	float fnum;
}
%token QUOTE  
%token <str> VAR ASSIGN INTRSV FLTRSV EQUAL
%type <inum>  types doesexists stmtblock
%left ASSIGN

%%
program:
    statement
	|
	statement program
    ;

statement:
	VAR EQUAL stmtblock {
        int flag = -1; 
		for (int i = 0; i < varArray.size(); i++) 
			if(varArray[i].name == string($1)){
				flag=i;
		expr="";
        storage.clear();
	}
    ;
stmtblock:
	types {$$=$1;}
	|
	doesexists {$$=$1;}
	;
types:
    INTRSV 
    {
        $$ = 1;
        storage.push_back(string($1));
    }
    |
    FLTRSV 
    {
        $$ = 2;
        storage.push_back(string($1));
    }
    |
    QUOTE VAR QUOTE 
    {
        $$ = 3;
        storage.push_back(string($2));
    }
    ;

doesexists:
	VAR 
	{
		int flag = -1; 
		for (int i = 0; i < varArray.size(); i++) 
			if(vararray[i].name == string($1))
				flag=i;
		if(flag==-1)
			throwerror(2);
        if(varArray[i].type==1 && varArray[i].isInt)
            $$=1;
        if(varArray[i].type==2 && varArray[i].isFlt)
            $$=2;
        if(varArray[i].type==3 && varArray[i].isStr)
            $$=3;
        storage.push_back(string($1));
	}
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