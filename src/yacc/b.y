%{
#include <stdio.h>
#include <stdlib.h>
void yyerror(const char *s);
int yylex(void);
int yywrap(void);

/* Macro de log condicional */
#ifdef DEBUG
#define LOG(fmt, ...) fprintf(stderr, "[LOG] " fmt "\n", ##__VA_ARGS__)
#else
#define LOG(fmt, ...) ((void)0)
#endif
%}

%union {
    int num;
    char *str;
}

%token <str> IDENTIFIER STRING
%token <num> NUMBER

%token AUTO EXTRN IF ELSE WHILE RETURN
%token EQ NE LE GE AND OR
%token INC DEC

%nonassoc IFX
%nonassoc ELSE

%left '='
%left OR
%left AND
%left EQ NE
%left '<' '>' LE GE
%left '+' '-'
%left '*' '/'
%right INC DEC

%start program

%%

program:
	extern_def function_def
	{
		LOG("program -> extern_def function_def");
	}
	;

extern_def:
	%empty
	{
		LOG("extern_def -> empty");
	}
	| extern_def EXTRN IDENTIFIER ';'
	{
		LOG("extern_def -> extern_def EXTRN IDENTIFIER ';' (ID: %s)", $3);
	}
	;

function_def:
	IDENTIFIER '(' ')' block
	{
		LOG("function_def -> IDENTIFIER '(' ')' block (ID: %s)", $1);
	}
	;

block:
	'{' declaration_list statement_list '}'
	{
		LOG("block -> { declaration_list statement_list }");
	}
	;

declaration_list:
	%empty
	{
		LOG("declaration_list -> empty");
	}
	| declaration_list declaration 
	{
		LOG("declaration_list -> declaration_list declaration");
	}
	;

declaration:
	AUTO identifier_list ';'
	{
		LOG("declaration -> AUTO identifier_list ';'");
	}
	;

identifier_list:
	IDENTIFIER
	{
		LOG("identifier_list -> IDENTIFIER (ID: %s)", $1);
	}
	| IDENTIFIER '[' expression ']'
	{
		LOG("identifier_list -> IDENTIFIER '[' expression ']' (ID: %s)", $1);
	}
	| identifier_list ',' IDENTIFIER
	{
		LOG("identifier_list -> identifier_list ',' IDENTIFIER (ID: %s)", $3);
	}
	| identifier_list ',' IDENTIFIER '[' expression ']'
	{
		LOG("identifier_list -> identifier_list ',' IDENTIFIER '[' expression ']' (ID: %s)", $3);
	}
	;

statement_list:
	%empty
	{
		LOG("statement_list -> empty");
	}
	| statement_list statement
	{
		LOG("statement_list -> statement_list statement");
	}
	;

statement:
	if_sttmt
	{
		LOG("statement -> if_sttmt");
	}
	| while_sttmt
	{
		LOG("statement -> while_sttmt");
	}
	| return__sttmt
	{
		LOG("statement -> return__sttmt");
	}
	| block
	{
		LOG("statement -> block");
	}
	| expression_sttmt
	{
		LOG("statement -> expression_sttmt");
	}
	;

expression_sttmt:
	expression ';'
	{
		LOG("expression_sttmt -> expression ';'");
	}
	;

if_sttmt:
	IF '(' expression ')' statement  %prec IFX
	{
		LOG("if_sttmt -> IF '(' expression ')' statement (sin else)");
	}
	| IF '(' expression ')' statement ELSE statement
	{
		LOG("if_sttmt -> IF '(' expression ')' statement ELSE statement");
	}
	;

while_sttmt:
	WHILE '(' expression ')' statement
	{
		LOG("while_sttmt -> WHILE '(' expression ')' statement");
	}
	;

return__sttmt:
	RETURN '(' expression ')' ';'
	{
		LOG("return__sttmt -> RETURN '(' expression ')' ';'");
	}
	;

expression:
	assignment_expression
	{
		LOG("expression -> assignment_expression");
	}
	;

assignment_expression:
	logical_or_expression
	{
		LOG("assignment_expression -> logical_or_expression");
	}
	| assignment_expression '=' logical_or_expression
	{
		LOG("assignment_expression -> assignment_expression '=' logical_or_expression");
	}
	;

logical_or_expression:
	logical_and_expression
	{
		LOG("logical_or_expression -> logical_and_expression");
	}
	| logical_or_expression OR logical_and_expression
	{
		LOG("logical_or_expression -> logical_or_expression OR logical_and_expression");
	}
	;

logical_and_expression:
	equality_expression
	{
		LOG("logical_and_expression -> equality_expression");
	}
	| logical_and_expression AND equality_expression
	{
		LOG("logical_and_expression -> logical_and_expression AND equality_expression");
	}
	;

equality_expression:
	relational_expression
	{
		LOG("equality_expression -> relational_expression");
	}
	| equality_expression EQ relational_expression
	{
		LOG("equality_expression -> equality_expression EQ relational_expression");
	}
	| equality_expression NE relational_expression
	{
		LOG("equality_expression -> equality_expression NE relational_expression");
	}
	;

relational_expression:
	additive_expression
	{
		LOG("relational_expression -> additive_expression");
	}
	| relational_expression '<' additive_expression
	{
		LOG("relational_expression -> relational_expression '<' additive_expression");
	}
	| relational_expression '>' additive_expression
	{
		LOG("relational_expression -> relational_expression '>' additive_expression");
	}
	| relational_expression LE additive_expression
	{
		LOG("relational_expression -> relational_expression LE additive_expression");
	}
	| relational_expression GE additive_expression
	{
		LOG("relational_expression -> relational_expression GE additive_expression");
	}
	;

additive_expression:
	multiplicative_expression
	{
		LOG("additive_expression -> multiplicative_expression");
	}
	| additive_expression '+' multiplicative_expression
	{
		LOG("additive_expression -> additive_expression '+' multiplicative_expression");
	}
	| additive_expression '-' multiplicative_expression
	{
		LOG("additive_expression -> additive_expression '-' multiplicative_expression");
	}
	;

multiplicative_expression:
	unary_expression
	{
		LOG("multiplicative_expression -> unary_expression");
	}
	| multiplicative_expression '*' unary_expression
	{
		LOG("multiplicative_expression -> multiplicative_expression '*' unary_expression");
	}
	| multiplicative_expression '/' unary_expression
	{
		LOG("multiplicative_expression -> multiplicative_expression '/' unary_expression");
	}
	;

unary_expression:
	primary_expression
	{
		LOG("unary_expression -> primary_expression");
	}
	| INC unary_expression
	{
		LOG("unary_expression -> INC unary_expression (pre-incremento)");
	}
	| DEC unary_expression
	{
		LOG("unary_expression -> DEC unary_expression (pre-decremento)");
	}
	| primary_expression INC
	{
		LOG("unary_expression -> primary_expression INC (post-incremento)");
	}
	| primary_expression DEC
	{
		LOG("unary_expression -> primary_expression DEC (post-decremento)");
	}
	;

primary_expression:
	NUMBER
	{
		LOG("primary_expression -> NUMBER (valor: %d)", $1);
	}
	| IDENTIFIER
	{
		LOG("primary_expression -> IDENTIFIER (nombre: %s)", $1);
	}
	| STRING
	{
		LOG("primary_expression -> STRING (valor: %s)", $1);
	}
	| '(' expression ')'
	{
		LOG("primary_expression -> '(' expression ')'");
	}
	| IDENTIFIER '[' expression ']'
	{
		LOG("primary_expression -> IDENTIFIER '[' expression ']' (ID: %s)", $1);
	}
	;

%%

void yyerror(const char *s) {
	fprintf(stderr, "Error: %s\n", s);
}

int yywrap(void) {
	return 1;
}

int main(void) {
	yyparse();
	return 0;
}