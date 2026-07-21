%option noinput nounput
%{
#include <stdio.h>
#include "y.tab.h"
%}

%%
[0-9]+      { return NUMBER; }
[a-zA-Z][a-zA-Z0-9]* { return WORD; }
\"          { return QUOTE; }
\{          { return OBRACE; }
\}          { return EBRACE; }
;           { return SEMICOLON; }
\n          ;
[ \t]+      ;
.           { }
%%