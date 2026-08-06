#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#define ERROR	-1
#define true	1
#define false	0

typedef struct {
	char *name;
	int defined;
} function_t;

extern function_t *functions;
extern int idxf;

int		functionExists(char *name);
int		ddFuntion(char *name);
void	clearFuntions(void);
#endif