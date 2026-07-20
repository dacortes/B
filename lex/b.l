%{
#include <stdio.h>
%}

%%
[0-9]+					printf("NUMBER\n");
[a-zA-Z][a-zA-Z0-9]*	printf("WORD\n");
[a-zA-Z0-9\/.-]+		printf("FILENAME ");
\"						printf("QUOTE ");
\{						printf("OBRACE ");
\}						printf("EBRACE ");
; 						printf("SEMICOLON ");
\n						printf("\n");
[ \t]+ 					/* ignore whitespace */;
%%