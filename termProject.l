%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
int linenum=1;
int tabamount=1;
%}
%%
[a-zA-Z][a-zA-Z0-9]* {yylval.str = strdup(yytext);return VAR;}
[0-9]+ {yylval.str = strdup(yytext);return INTRSV;}
[0-9]+\.[0-9]+ {yylval.str = strdup(yytext);return FLTRSV;}
\= return EQUAL;
\" return QUOTE;
\+|\-|\/|\* {yylval.str = strdup(yytext);return ASSIGN;}
\n	{linenum++;tabamount=1;}
\t {tabamount++;}
[ \t]+
%%