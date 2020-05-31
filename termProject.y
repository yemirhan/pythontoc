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
	extern int tabamount;
	int openedifs=1;
	void yyerror(string s);
	struct nameStruct {
		string name;
		bool isInt;
		bool isFlt;
		bool isStr;
		int lasttype;
		nameStruct(string s, bool i, bool f, bool str, int lt){
			name = s;
			isInt = i;
			isFlt = f;
			isStr = str;
			lasttype = lt;
		}
	};
	vector<nameStruct> varArray;
    string finalOutput="\t";
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
		if(i==3){ //Tab inconstincency 
			cout << "Tab inconstincency in line: " << linenum << endl;
			exit(1);
		}
	}
	vector <string> storage;
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
%type <inum> typelist selector isdefined operations
%left ASSIGN

%%
program:
	statement
	|
	statement program
	;
statement:
	VAR EQUAL operations 
	{
		int flag = -1;
		for (int i = 0;i< varArray.size();i++)
			if (varArray[i].name == string($1))
				flag = i;
		if(flag==-1){
			struct nameStruct varname = nameStruct(string($1), false,false,false,0);
			if($3 == 1)
				varname.isInt = true;
			if($3 == 2)
				varname.isFlt = true;
			if($3 == 3)
				varname.isStr = true;
			varname.lasttype = $3;
			varArray.push_back(varname);
		}
		else {
			if($3 == 1)
				varArray[flag].isInt = true;
			if($3 == 2)
				varArray[flag].isFlt = true;
			if($3 == 3)
				varArray[flag].isStr = true;
			varArray[flag].lasttype = $3;
		}
		string alt="";
			if($3 == 1)
				alt+=string($1)+"_int";
			if($3 == 2)
				alt+=string($1)+"_flt";
			if($3 == 3)
				alt+=string($1)+"_str";
		if(expr!="")
			finalOutput+=alt+" = " +expr+";\n";
		else
			finalOutput+=alt+" = " +storage[0]+";\n";
		for(int i = 0;i<tabamount;i++)
			finalOutput+="\t";
		if(tabamount != openedifs)
			throwerror(3);
		expr="";
		storage.clear();
	}
	;
operations:
	selector {$$ = $1;}
	|
	operations ASSIGN operations {
		if($1 != $3&&($1==3 || $3==3)){
			throwerror(1);
		}
		if($1==2 || $3 == 2){
			$$=2;
		}
        if(storage.size()==2)
		    expr+=string(storage[0])+ " "+ string($2) +" "+ string(storage[1]);
        if(storage.size()==1)
		    expr+=" "+ string($2) +" "+ string(storage[0]);
		storage.clear();
	}
	;
selector:
	typelist {$$ = $1;}
	|
	isdefined {$$ = $1;}
	;
typelist:
	INTRSV {$$ = 1;storage.push_back($1);}
	|
	FLTRSV {$$ = 2;storage.push_back($1);}
	|
	QUOTE VAR QUOTE {$$ = 3;string alt = "\""+ string($2)+"\"";storage.push_back(alt);}
	|
	QUOTE INTRSV QUOTE {$$ = 3;string alt = "\""+ string($2)+"\"";storage.push_back(alt);}
	|
	QUOTE FLTRSV QUOTE {$$ = 3;string alt = "\""+ string($2)+"\"";storage.push_back(alt);}
	;
isdefined:
	VAR
	{
		int flag = -1;
		for (int i = 0;i< varArray.size();i++)
			if (varArray[i].name == string($1))
				flag = i;
		if(flag == -1)
			throwerror(2);
		else {
			if(varArray[flag].lasttype==1 && varArray[flag].isInt){
				$$=1;
				storage.push_back(string($1)+"_int");
			}
            	
			if(varArray[flag].lasttype==2 && varArray[flag].isFlt){
				$$=2;
				storage.push_back(string($1)+"_flt");
			}
				
			if(varArray[flag].lasttype==3 && varArray[flag].isStr){
				$$=3;
				storage.push_back(string($1)+"_str");
			}
				
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
    yyin=fopen(argv[1],"r");
    yyparse();
    fclose(yyin);
	vector<string> intarray;
	vector<string> floatarray;
	vector<string> strarray;
	for (int i = 0;i< varArray.size();i++){
		if(varArray[i].isStr == true)
			strarray.push_back(varArray[i].name + "_str");
		if(varArray[i].isInt == true)
			intarray.push_back(varArray[i].name + "_int");
		if(varArray[i].isFlt == true)
			floatarray.push_back(varArray[i].name + "_flt");
	}
	cout << "void main()\n{\n";
	if(intarray.size()>0){
		cout <<"\tint "; 
		for (int i = 0; i < intarray.size()-1; i++){
        	cout << intarray[i] << ","; 
		}
		cout << intarray[intarray.size()-1] << ";\n"; 
	}
	if(floatarray.size()>0){
		cout <<"\tfloat "; 
		for (int i = 0; i < floatarray.size()-1; i++) {
        	cout << floatarray[i] << ","; 
		}
		cout << floatarray[floatarray.size()-1] << ";\n"; 
	}
	if(strarray.size()>0){
		cout <<"\tstring "; 
		for (int i = 0; i < strarray.size()-1; i++) {
        	cout << strarray[i] << ","; 
		}
		cout << strarray[strarray.size()-1] << ";\n"; 
	}
	cout <<"\n"<<finalOutput.substr(0,finalOutput.length()-1);
	cout << "}"<<endl;
    return 0;
}