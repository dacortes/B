%{
#include <symbol_table.h>
#include <buffer.h>
#include <labels.h>
#include <errors.h>
#include <file.h>

void yyerror(const char *s);
int yylex(void);
int yywrap(void);

#ifdef DEBUG
#define LOG(fmt, ...) fprintf(stderr, "[LOG] " fmt "\n", ##__VA_ARGS__)
#else
#define LOG(fmt, ...) ((void)0)
#endif


int		local_offset = 0;
int		param_offset = 8;
int		var_count = 0;
int		arg_count = 0;

char	*current_function = NULL;
char	*current_loop_start = NULL;
char	*current_loop_end = NULL;
char	*current_if_end = NULL;
char	*current_else_label = NULL;

%}

%union {
	int num;
	char *str;
}

%token <str> IDENTIFIER STRING
%token <num> NUMBER
%destructor { free($$); } <str>
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
	extern_def function_list
	{
		LOG("program -> extern_def function_list");
		if (!functionExists("main")) {
			fprintf(stderr, "Error: 'main' function not found\n");
			yyerror("Main function missing");
			YYERROR;
		} else {
			fprintf(stdout, ".intel_syntax noprefix\n");
			fprintf(stdout, ".text\n");
			fprintf(stdout, ".global _start\n");
			flush_output();
			clear_buffer();
		}
	}
	;

extern_def:
	%empty
	{
		LOG("extern_def -> empty");
	}
	| extern_def EXTRN IDENTIFIER ';'
	{
		if (addVariable($3, NULL) == ERROR) {
			YYERROR;
		}

		LOG("extern_def -> extern_def EXTRN IDENTIFIER ';' (ID: %s)", $3);
		emit("\textern %s\n", $3);
	}
	;

function_list:
	function_def
	{
		LOG("function_list -> function_def");
	}
	| function_list function_def
	{
		LOG("function_list -> function_list function_def");
	}
	;

function_def:
	IDENTIFIER '(' ')'
	{
		local_offset = 0;
		current_function = strdup($1);

		if (strcmp($1, "main") == 0) {
			emit("_start:\n");
		} else {
			emit("%s:\n", $1);
		}
		emit("\tpush ebp\n");
		emit("\tmov ebp, esp\n");
	} block
	{
		LOG("function_def -> IDENTIFIER '(' ')' block (ID: %s)", $1);
		
		if (addFuntion($1) == ERROR) {
			fprintf(stderr, "Error: Function '%s' already defined\n", $1);
			yyerror("Duplicate function definition");
			free(current_function);
			current_function = NULL;
			clear_buffer();
			YYERROR;
		}

		emit("\tmov esp, ebp\n");
		emit("\tpop ebp\n");
		
		if (strcmp($1, "main") == 0) {
			emit("\tmov eax, 1\n");
			emit("\tmov ebx, 0\n");
			emit("\tint 0x80\n");
		} else {
			emit("\tret\n");
		}
		
		free(current_function);
		current_function = NULL;
	}
	| IDENTIFIER '(' parameter_list ')'
	{
		local_offset = 0;
		param_offset = 8;
		current_function = strdup($1);
		emit("%s:\n", $1);
		emit("\tpush ebp\n");
		emit("\tmov ebp, esp\n");
	} block
	{
		LOG("function_def -> IDENTIFIER '(' parameter_list ')' block (ID: %s)", $1);
		
		if (addFuntion($1) == ERROR) {
			fprintf(stderr, "Error: Function '%s' already defined\n", $1);
			yyerror("Duplicate function definition");
			free(current_function);
			current_function = NULL;
			clear_buffer();
			YYERROR;
		}
		
		emit("\tmov esp, ebp\n");
		emit("\tpop ebp\n");
		emit("\tret\n");
		
		free(current_function);
		current_function = NULL;
	}
	;

parameter_list:
	IDENTIFIER
	{
		LOG("parameter_list -> IDENTIFIER (ID: %s)", $1);
		if (addVariable($1, current_function) == ERROR) {
			YYERROR;
		}

		set_variable_offset($1, current_function, param_offset);
        param_offset += 4;
	}
	| IDENTIFIER ',' parameter_list
	{
		LOG("parameter_list -> IDENTIFIER ',' parameter_list (ID: %s)", $1);
		if (addVariable($1, current_function) == ERROR) {
			YYERROR;
		}
		set_variable_offset($1, current_function, param_offset);
		param_offset += 4;
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
	| AUTO IDENTIFIER '=' expression ';'
	{
		LOG("declaration -> AUTO IDENTIFIER '=' expression ';' (ID: %s)", $2);
		local_offset += 4;
		emit("\tsub esp, 4\n");
		if (addVariable($2, current_function) == ERROR) {
			YYERROR;
		}
		set_variable_offset($2, current_function, local_offset);
		emit("\tmov DWORD PTR [ebp-%d], eax\n", local_offset);
	}
	;

identifier_list:
	IDENTIFIER
	{
		LOG("identifier_list -> IDENTIFIER (ID: %s)", $1);
		local_offset += 4;
		emit("\tsub esp, 4\n");
		if (addVariable($1, current_function) == ERROR) {
			YYERROR;
		}
		set_variable_offset($1, current_function, local_offset);
	}
	| IDENTIFIER '[' expression ']'
	{
		LOG("identifier_list -> IDENTIFIER '[' expression ']' (ID: %s)", $1);
		int base_offset = local_offset + 4;

		emit("\tmov ebx, eax\n");
		emit("\tshl ebx, 2\n");
		emit("\tsub esp, ebx\n");
		
		local_offset += 4;
		
		if (addVariable($1, current_function) == ERROR) {
			YYERROR;
		}
		set_variable_offset($1, current_function, base_offset);
	}
	| identifier_list ',' IDENTIFIER
	{
		LOG("identifier_list -> identifier_list ',' IDENTIFIER (ID: %s)", $3);
		local_offset += 4;
		emit("\tsub esp, 4\n");
		if (addVariable($3, current_function) == ERROR) {
			YYERROR;
		}
		set_variable_offset($3, current_function, local_offset);
	}
	| identifier_list ',' IDENTIFIER '[' expression ']'
	{
		LOG("identifier_list -> identifier_list ',' IDENTIFIER '[' expression ']' (ID: %s)", $3);
		int base_offset = local_offset + 4;

		emit("\tmov ebx, eax\n");
		emit("\tshl ebx, 2\n");
		emit("\tsub esp, ebx\n");
		
		local_offset += 4;
		
		if (addVariable($3, current_function) == ERROR) {
			YYERROR;
		}
		set_variable_offset($3, current_function, base_offset);
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
	assignment_expression ';'
	{
		LOG("expression_sttmt -> expression ';'");
	}
	;

if_prefix:
	IF '('
	{
		current_else_label = new_label(".L");
		current_if_end = new_label(".L");
	}
	;

if_sttmt:
	if_prefix expression ')' statement  %prec IFX
	{
		LOG("if_sttmt -> IF '(' expression ')' statement (sin else)");
		emit("\tcmp eax, 0\n");
		emit("\tje %s\n", current_else_label);
		emit("%s:\n", current_else_label);
		emit("%s:\n", current_if_end);
		free(current_else_label);
		free(current_if_end);
		current_else_label = NULL;
		current_if_end = NULL;
	}
	| if_prefix expression ')' statement ELSE statement
	{
		LOG("if_sttmt -> IF '(' expression ')' statement ELSE statement");
		emit("\tcmp eax, 0\n");
		emit("\tje %s\n", current_else_label);
		emit("\tjmp %s\n", current_if_end);
		emit("%s:\n", current_else_label);
		emit("%s:\n", current_if_end);
		free(current_else_label);
		free(current_if_end);
		current_else_label = NULL;
		current_if_end = NULL;
	}
	;

while_prefix:
	WHILE '('
	{
		current_loop_start = new_label(".L");
		current_loop_end = new_label(".L");
		emit("%s:\n", current_loop_start);
	}
	expression ')'
	{
		emit("\tcmp eax, 0\n");
		emit("\tje %s\n", current_loop_end);
	}
	;

while_sttmt:
	while_prefix statement
	{
		LOG("while_sttmt -> WHILE '(' expression ')' statement");
		emit("\tjmp %s\n", current_loop_start);
		emit("%s:\n", current_loop_end);
		free(current_loop_start);
		free(current_loop_end);
		current_loop_start = NULL;
		current_loop_end = NULL;
	}
	;

return__sttmt:
	RETURN '(' expression ')' ';'
	{
		LOG("return__sttmt -> RETURN '(' expression ')' ';'");
		emit("\tmov esp, ebp\n");
		emit("\tpop ebp\n");
		emit("\tret\n");
	}
	;

expression:
	assignment_expression
	{
		LOG("expression -> assignment_expression");
	}
	;

lvalue:
	IDENTIFIER
	{
		LOG("lvalue -> IDENTIFIER (ID: %s)", $1);
		int offset = get_variable_offset($1, current_function);
		if (offset == -1) {
			fprintf(stderr, "Error: Variable '%s' not declared\n", $1);
			YYERROR;
		}
		emit("\tlea eax, [ebp-%d]\n", offset);
	}
	| IDENTIFIER '[' expression ']'
	{
		LOG("lvalue -> IDENTIFIER '[' expression ']' (ID: %s)", $1);
		int offset = get_variable_offset($1, current_function);
		if (offset == -1) {
			fprintf(stderr, "Error: Array '%s' not declared\n", $1);
			YYERROR;
		}
		emit("\tlea ebx, [ebp-%d]\n", offset);
		emit("\tshl eax, 2\n");
		emit("\tsub ebx, eax\n");
		emit("\tmov eax, ebx\n");
	}
	;

assignment_expression:
	logical_or_expression
	{
		LOG("assignment_expression -> logical_or_expression");
	}
	| lvalue '=' { emit("\tmov edi, eax\n"); } assignment_expression
	{
		LOG("assignment_expression -> lvalue '=' assignment_expression");
		emit("\tmov DWORD PTR [edi], eax\n");
	}
	;

logical_or_expression:
	logical_and_expression
	{
		LOG("logical_or_expression -> logical_and_expression");
	}
	| logical_or_expression OR { emit("\tpush eax\n"); } logical_and_expression
	{
		LOG("logical_or_expression -> logical_or_expression OR logical_and_expression");
		emit("\tpop ebx\n");
		emit("\tor eax, ebx\n");
		emit("\tcmp eax, 0\n");
		emit("\tsetne al\n");
		emit("\tmovzx eax, al\n");
	}
	;

logical_and_expression:
	equality_expression
	{
		LOG("logical_and_expression -> equality_expression");
	}
	| logical_and_expression AND { emit("\tpush eax\n"); } equality_expression
	{
		LOG("logical_and_expression -> logical_and_expression AND equality_expression");
		emit("\tpop ebx\n");
		emit("\tand eax, ebx\n");
		emit("\tcmp eax, 0\n");
		emit("\tsetne al\n");
		emit("\tmovzx eax, al\n");
	}
	;

equality_expression:
	relational_expression
	{
		LOG("equality_expression -> relational_expression");
	}
	| equality_expression EQ { emit("\tpush eax\n"); } relational_expression
	{
		LOG("equality_expression -> equality_expression EQ relational_expression");
		emit("\tpop ebx\n");
		emit("\tcmp ebx, eax\n");
		emit("\tsete al\n");
		emit("\tmovzx eax, al\n");
	}
	| equality_expression NE { emit("\tpush eax\n"); } relational_expression
	{
		LOG("equality_expression -> equality_expression NE relational_expression");
		emit("\tpop ebx\n");
		emit("\tcmp ebx, eax\n");
		emit("\tsetne al\n");
		emit("\tmovzx eax, al\n");
	}
	;

relational_expression:
	additive_expression
	{
		LOG("relational_expression -> additive_expression");
	}
	| relational_expression '<' { emit("\tpush eax\n"); } additive_expression
	{
		LOG("relational_expression -> relational_expression '<' additive_expression");
		emit("\tpop ebx\n");
		emit("\tcmp ebx, eax\n");
		emit("\tsetl al\n");
		emit("\tmovzx eax, al\n");
	}
	| relational_expression '>' { emit("\tpush eax\n"); } additive_expression
	{
		LOG("relational_expression -> relational_expression '>' additive_expression");
		emit("\tpop ebx\n");
		emit("\tcmp ebx, eax\n");
		emit("\tsetg al\n");
		emit("\tmovzx eax, al\n");
	}
	| relational_expression LE { emit("\tpush eax\n"); } additive_expression
	{
		LOG("relational_expression -> relational_expression LE additive_expression");
		emit("\tpop ebx\n");
		emit("\tcmp ebx, eax\n");
		emit("\tsetle al\n");
		emit("\tmovzx eax, al\n");
	}
	| relational_expression GE { emit("\tpush eax\n"); } additive_expression
	{
		LOG("relational_expression -> relational_expression GE additive_expression");
		emit("\tpop ebx\n");
		emit("\tcmp ebx, eax\n");
		emit("\tsetge al\n");
		emit("\tmovzx eax, al\n");
	}
	;

additive_expression:
	multiplicative_expression
	{
		LOG("additive_expression -> multiplicative_expression");
	}
	| additive_expression '+' { emit("\tpush eax\n"); } multiplicative_expression
	{
		LOG("additive_expression -> additive_expression '+' multiplicative_expression");
		emit("\tpop ebx\n");
		emit("\tadd eax, ebx\n");
	}
	| additive_expression '-' { emit("\tpush eax\n"); } multiplicative_expression
	{
		LOG("additive_expression -> additive_expression '-' multiplicative_expression");
		emit("\tpop ebx\n");
		emit("\tsub ebx, eax\n");
		emit("\tmov eax, ebx\n");
	}
	;

multiplicative_expression:
	unary_expression
	{
		LOG("multiplicative_expression -> unary_expression");
	}
	| multiplicative_expression '*' { emit("\tpush eax\n"); } unary_expression
	{
		LOG("multiplicative_expression -> multiplicative_expression '*' unary_expression");
		emit("\tpop ebx\n");
		emit("\timul eax, ebx\n");
	}
	| multiplicative_expression '/' { emit("\tpush eax\n"); } unary_expression
	{
		LOG("multiplicative_expression -> multiplicative_expression '/' unary_expression");
		emit("\tpop ebx\n");
		emit("\tmov edx, 0\n");
		emit("\tidiv ebx\n");
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
		emit("\tinc eax\n");
	}
	| DEC unary_expression
	{
		LOG("unary_expression -> DEC unary_expression (pre-decremento)");
		emit("\tdec eax\n");
	}
	| primary_expression INC
	{
		LOG("unary_expression -> primary_expression INC (post-incremento)");
		emit("\tmov ebx, eax\n");
		emit("\tinc eax\n");
		emit("\tmov eax, ebx\n");
	}
	| primary_expression DEC
	{
		LOG("unary_expression -> primary_expression DEC (post-decremento)");
		emit("\tmov ebx, eax\n");
		emit("\tdec eax\n");
		emit("\tmov eax, ebx\n");
	}
	;

primary_expression:
	NUMBER
	{
		LOG("primary_expression -> NUMBER (valor: %d)", $1);
		emit("\tmov eax, %d\n", $1);
	}
	| IDENTIFIER
	{
		LOG("primary_expression -> IDENTIFIER (nombre: %s)", $1);
		int offset = get_variable_offset($1, current_function);
		if (offset == -1) {
			if (variableExists($1, NULL)) {
				emit("\tmov eax, DWORD PTR [%s]\n", $1);
			} else {
				fprintf(stderr, "Error: Variable '%s' not declared\n", $1);
				YYERROR;
			}
		} else {
			emit("\tmov eax, DWORD PTR [ebp-%d]\n", offset);
		}
	}
	| STRING
	{
		LOG("primary_expression -> STRING (valor: %s)", $1);
		char *label = new_label_str(".LC");
		emit(".section .rodata\n");
		emit("%s:\n", label);
		emit("\t.string %s\n", $1);
		emit(".text\n");
		emit("\tmov eax, %s\n", label);
		free(label);

	}
	| '(' expression ')'
	{
		LOG("primary_expression -> '(' expression ')'");
	}
	| IDENTIFIER '[' expression ']'
	{
		LOG("primary_expression -> IDENTIFIER '[' expression ']' (ID: %s)", $1);
		int offset = get_variable_offset($1, current_function);
		if (offset == -1) {
			fprintf(stderr, "Error: Array '%s' not declared\n", $1);
			YYERROR;
		}
		emit("\tlea ebx, [ebp-%d]\n", offset);
		emit("\tshl eax, 2\n");
		emit("\tsub ebx, eax\n");
		emit("\tmov eax, DWORD PTR [ebx]\n");
	}
	| IDENTIFIER '(' argument_list ')'
	{
		LOG("primary_expression -> IDENTIFIER '(' argument_list ')' (función: %s)", $1);
		emit("\tcall %s\n", $1);
		if (arg_count > 0) {
			emit("\tadd esp, %d\n", arg_count * 4);
		}
	}
	;

argument_list:
	%empty
	{
		LOG("argument_list -> empty");
		arg_count = 0;
	}
	| expression
	{
		LOG("argument_list -> expression");
		arg_count = 1;
		emit("\tpush eax\n");
	}
	| argument_list ',' expression
	{
		LOG("argument_list -> argument_list ',' expression");
		arg_count++;
		emit("\tpush eax\n");
	}
	;

%%

void yyerror(const char *s)
{
	fprintf(stderr, "Error: %s\n", s);
}

int yywrap(void)
{
	return 1;
}

int main(int ac, char **av)
{
	file_t	files;

	initFile(&files, ac, av);
	files.readFiles(&files);
	files.clear(&files);
	return 0;
	yyparse();
	return 0;
}