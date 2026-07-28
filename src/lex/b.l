%option noinput nounput
%{
#include <stdio.h>
#include "y.tab.h"
%}

%%
"auto"			{ return AUTO; }
"extern"		{ return EXTRN; }
"if"			{ return IF; }
"else"			{ return ELSE; }
"while"			{ return WHILE; }
"return"		{ return RETURN; }

"++"			{ return INC; }
"--"			{ return DEC; }

[0-9]+			{ return NUMBER; }
[a-zA-Z_][a-zA-Z0-9_]* { return IDENTIFIER; }

\"([^\\\"]|\\.)*\" { return STRING; }

"=="			{ return EQ; }
"!="			{ return NE; }
"<="			{ return LE; }
">="			{ return GE; }
"&&"			{ return AND; }
"||"			{ return OR; }

"+"				{ return '+'; }
"-"				{ return '-'; }
"*"				{ return '*'; }
"/"				{ return '/'; }
"%"				{ return '%'; }
"="				{ return '='; }
"<"				{ return '<'; }
">"				{ return '>'; }
"!"				{ return '!'; }
"&"				{ return '&'; }
"|"				{ return '|'; }
"("				{ return '('; }
")"				{ return ')'; }
"{"				{ return '{'; }
"}"				{ return '}'; }
"["				{ return '['; }
"]"				{ return ']'; }
";"				{ return ';'; }
","				{ return ','; }

[ \t\n]+		;
.				{ fprintf(stderr, "unknown character: %c\n", *yytext); }
%%