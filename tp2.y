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
%token QUOTE  
%token <str> VAR ASSIGN INTRSV FLTRSV EQUAL
%type <inum> variablestatement types doesexists expression stmtblock
%left ASSIGN

%%
program:
    statement
	|
	statement program
    ;

statement:
	VAR EQUAL expression
	{
        int flag = -1; 
		for (int i = 0; i < varArray.size(); i++) 
			if(varArray[i].name == string($1)){
				flag=i;
		
		if(flag==-1)
			intarray.push_back($1);
        if(flag!=-1)
            varArray[flag].lastoneassigned = $3
        if(storage.size()==1)
		    finalOutput+="\t"+string($1)+" = " + expr+";\n";
        if(storage.size()==0)
		    finalOutput+="\t"+string($1)+" = " + string(storage[0])+";\n";
		expr="";
        storage.clear();
	}
    ;

expression:
    stmtblock
    |
	expression ASSIGN expression     { 
		if($1 != $3&&($1==3 || $3==3)){
			throwerror(1);
		}
		/*if($1==2 || $3 == 2){
			$$=2;
		}*/
        if(storage.size()==2)
		    expr+=string(storage[0])+ string($2) + string(storage[1]);
        if(storage.size()==2)
		    expr+=string($2) + string(storage[1]);
        
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
			if(vararray[i].name == string($1)){
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
/*

*/

/*
if 
if else
if elseif else



*/