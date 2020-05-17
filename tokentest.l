%{
#include <stdio.h>
#include <string.h>
//#include "y.tab.h"
int linenum;
%}
%option noyywrap
%%
[a-zA-Z][a-zA-Z0-9]* {printf("var ");}//{yylval.str = strdup(yytext);return VAR;}
[0-9]+ {printf("int ");}//{yylval.str = strdup(yytext);return NUM;}
[0-9]+\.[0-9]+ {printf("float ");}
\= {printf("eq ");}//return EQUAL;
\" {printf("quote ");}//return QUOTE;
\+|\-|\/|\* {printf("assign ");}//return PLUS;
\n	{printf("\n");linenum++;}
[ \t]+
%%
int main(int argc, char *argv[]) {
  	yyin=fopen(argv[1],"r");
  	yylex();
	fclose(yyin);
  	return 0;
}