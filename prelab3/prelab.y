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
	string finalOutput="";
	string expr="";
	string declpart="";
	FILE *output;
%}

%union
{
	char * str;
	int inum;
	float fnum;
}
%token PLUS MINUS QUOTE EQUAL 
%token <str> VAR
%token <inum> INTRSV 
%token <fnum> FLTRSV
%type <inum> type plusoperation ifexists sub
%left PLUS
%%

program:
    statement
	|
	statement program
    ;
statement:
	variablestatement
	|
	VAR EQUAL plusoperation {
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
		finalOutput+=string($1)+" = " + expr.substr(0,expr.length()-1)+";\n";
		expr="";
	}
	;

variablestatement:
	VAR EQUAL INTRSV
	{
		intarray.push_back($1);
		finalOutput+=string($1)  + " = " +to_string($3) + ";\n";
	}
	|
	VAR EQUAL FLTRSV
	{
		floatarray.push_back($1);
		string flt= to_string($3);
		finalOutput+=string($1)  + " = " + flt.substr(0,3) + ";\n";
	}
	|
	VAR EQUAL QUOTE VAR QUOTE 
	{
		strarray.push_back($1);
		finalOutput+=string($1)  + " = \"" +string($4) + "\";\n";
	}
    ;

plusoperation:
	plusoperation PLUS sub 
	{
		if($1 != $3&&($1==3 || $3==3)){
			throwerror(1);
		}
		if($1==2 || $3 == 2){
			$$=2;
		}
	}
	|
	sub
	;
sub:
	type {$$=$1;}
	|
	ifexists {$$=$1;}
	;
type:
    INTRSV {$$ = 1;expr+=to_string($1)+"+";}
    |
	FLTRSV {$$ = 2;string flt=to_string($1);expr+=flt.substr(0,3)+"+";}
	|
	QUOTE VAR QUOTE {$$ = 3;expr+=string($2)+"+";}
	;
ifexists:
	VAR 
	{
		int flag = 0; 
		for (int i = 0; i < intarray.size(); i++) 
			if(intarray[i] == string($1)){
				$$ = 1;
				expr+=string(intarray[i])+"+";
				flag++;
			}
				
		for (int i = 0; i < floatarray.size(); i++) 
			if(floatarray[i] == string($1)){
				expr+=string(floatarray[i])+"+";
				$$ = 2;
				flag++;
			}
				
		for (int i = 0; i < strarray.size(); i++) 
			if(strarray[i] == string($1)){
				expr+=string(strarray[i])+"+";
				$$ = 3;
				flag++;
			}
		if(flag!=1){
			throwerror(2);
		}	
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
