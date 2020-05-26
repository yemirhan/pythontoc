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
    expression                      { cout<<$1<<endl;}
    |
	VARIABLE ASSIGNOP expression
	{
				values[string($1)] = $3;
				cout<<$1<<" = "<<values[string($1)]<<endl;
	}
    ;

expression:
    INTEGER	{$$=$1;}
    |
	VARIABLE                      { $$ = values[string($1)];}
    |
	expression PLUSOP expression     { $$ = $1 + $3; }
    |
	expression MINUSOP expression     { $$ = $1 - $3; }
    |
	expression MULTOP expression     { $$ = $1 * $3; }
    |
	expression DIVIDEOP expression     { $$ = $1 / $3; }
    |
	OPENPAR expression CLOSEPAR            { $$ = $2; }
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
	if(intarray.size()>0){
		cout <<"int "; 
		declpart+="int ";
		for (int i = 0; i < intarray.size()-1; i++){
        	cout << intarray[i] << ", "; 
			declpart+=string(intarray[i])+", ";
		}
		cout << intarray[intarray.size()-1] << ";\n"; 
		declpart+=string(intarray[intarray.size()-1])+";\n";
	}
	if(floatarray.size()>0){
		cout <<"float "; 
		declpart+="float ";
		for (int i = 0; i < floatarray.size()-1; i++) {
        	cout << floatarray[i] << ", "; 
			declpart+=string(floatarray[i])+", ";
		}
		cout << floatarray[floatarray.size()-1] << ";\n"; 
		declpart+=string(floatarray[floatarray.size()-1])+";\n";
	}
	if(strarray.size()>0){
		cout <<"string "; 
		declpart+="string ";
		for (int i = 0; i < strarray.size()-1; i++) {
        	cout << strarray[i] << ", "; 
			declpart+=string(strarray[i])+", ";
		}
		cout << strarray[strarray.size()-1] << ";\n"; 
		declpart+=string(strarray[strarray.size()-1])+";\n";
	}
	cout << "\n";
	cout << finalOutput;
	output=fopen(argv[2],"w");
	fprintf(output,"%s\n%s",declpart.c_str(),finalOutput.c_str());
	fclose(output);
    return 0;
}

/*

program:
    statement
	|
	statement program
    ;
statement:
    VAR EQUAL variablestatement{
		int flag=0;
		for(int i=0;i<intarray.size();i++)
			if(intarray[i] == string($1))
				flag++;
		for(int i=0;i<floatarray.size();i++)
			if(floatarray[i] == string($1))
				flag++;
		for(int i=0;i<strarray.size();i++)
			if(strarray[i] == string($1))
				flag++;
		if($3==1 && flag==0)
			intarray.push_back($1);
		if($3==2 && flag==0)
			floatarray.push_back($1);
		if($3==3 && flag==0)
			strarray.push_back($1);
		finalOutput+="\t"+string($1)+" = " + expr.substr(0,expr.length()-1)+";\n";
		expr="";
	}
    ;
variablestatement:
    types
    |
    doesexists
    |
    variablestatement ASSIGN types
	{
		if($1 != $3&&($1==3 || $3==3)){
			throwerror(1);
		}
		if($1==2 || $3 == 2){
			$$=2;
		}
		expr+=string($2);
	}
	|
	variablestatement ASSIGN doesexists
	{
		if($1 != $3&&($1==3 || $3==3)){
			throwerror(1);
		}
		if($1==2 || $3 == 2){
			$$=2;
		}
		expr+=string($2);
	}
    ;
types:
    INTRSV 
    {
        $$ = 1;
        expr+=to_string($1);
    }
    |
    FLTRSV 
    {
        $$ = 2;
        string flt=to_string($1);
        expr+=flt.substr(0,3);
    }
    |
    QUOTE VAR QUOTE 
    {
        $$ = 3;
        expr+=string($2);
    }
    ;

doesexists:
    VAR 
	{
		int flag = 0; 
		string intstr = string($1) + "_int";
		for (int i = 0; i < intarray.size(); i++) 
			if(intarray[i] == intstr){
				$$ = 1;
				expr+=string(intarray[i]);
				flag++;
			}
		
		string fltstr = string($1) + "_flt";
		for (int i = 0; i < floatarray.size(); i++) 
			if(floatarray[i] == fltstr){
				expr+=string(floatarray[i]);
				$$ = 2;
				flag++;
			}
				
		string strstr = string($1) + "_str";
		for (int i = 0; i < strarray.size(); i++) 
			if(strarray[i] == strstr){
				expr+=string(strarray[i]);
				$$ = 3;
				flag++;
			}
		if(flag!=1){
			throwerror(2);
		}	
	}
    ;
*/