#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define ERROR   -1
#define true    1
#define false   0

typedef struct {
	char *name;
	int defined;
} function_t;

function_t *functions = NULL;
size_t idxf = 0;
size_t newSize = 1;

int functionExists(char *name) {
	if (idxf == 0)
		return false;
	for (int idx = 0; idx < idxf; idx++)
	{
		if (!strcmp(functions[idx].name, name))
			return true;
	}
	return false;
}

void clearFuntions(void) {
	if (!functions)
		return ;

	for (int idx = 0; idx < idxf; idx++) {
		if (functions[idx].name)
		{
			free(functions[idx].name);
			functions[idx].defined = false;
		}
	}
	free(functions);
}

int addFuntion(char *name) {
	if (!name)
		return ERROR;

	size_t len = strlen(name) + 1;

	if (functionExists(name) == true) {
		clearFuntions();
		return ERROR;
	}
	function_t *add = realloc(functions, (idxf == 0 ? 1 : idxf * 2)  * sizeof(function_t));
	if (!add) {
		clearFuntions();
		return ERROR;
	}
	functions = add;
	functions[idxf].name = strndup(name, len);
	functions[idxf].defined = true;
	idxf++;
	return 0;
}

int main(int ac, char **av){
    if (ac <= 0)
        return 0;
    for (int i = 0; i < ac; i++)
    {
        if(addFuntion(av[i]) == ERROR)
            return ERROR;
    }
	clearFuntions();
    return 0;
}
