#define QUOTE 257
#define EQUAL 258
#define VAR 259
#define ASSIGN 260
#define INTRSV 261
#define FLTRSV 262
#ifdef YYSTYPE
#undef  YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
#endif
#ifndef YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
typedef union
{
	char * str;
	int inum;
	float fnum;
} YYSTYPE;
#endif /* !YYSTYPE_IS_DECLARED */
extern YYSTYPE yylval;
