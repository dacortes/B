%{
#include <stdio.h>
#include <string.h>

void yyerror(const char *str);
int  yylex(void);
int  yywrap(void);
%}

%token NUMBER WORD FILENAME QUOTE OBRACE EBRACE SEMICOLON

%%
programa:
	;
%%

void yyerror(const char *str)
{
	fprintf(stderr, "error: %s\n", str);
}

int yywrap(void)
{
	return 1;
}

int main(void)
{
	yyparse();
	return 0;
}
