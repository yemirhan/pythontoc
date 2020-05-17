%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
int linenum=1;
%}
%%
[a-zA-Z][a-zA-Z0-9]* {yylval.str = strdup(yytext);return VAR;}
[0-9]+ {yylval.inum = atoi(yytext);return INTRSV;}
[0-9]+\.[0-9]+ {yylval.fnum = atof(yytext);return FLTRSV;}
\= return EQUAL;
\" return QUOTE;
\+ return PLUS;
\n	linenum++;
[ \t]+
%%