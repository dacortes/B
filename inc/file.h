#ifndef FILE_H
# define FILE_H

#include <symbol_table.h>
#include <errors.h>
#include <unistd.h>

typedef struct  file_s file_t;

struct  file_s
{
	char	**files;
	char	*buffer;
	char	*line;

	size_t	lenLine;
	size_t	lenBuff;
	int (* readFiles)(file_t *self);
	int (* addBuffer)(file_t *self, FILE *fp);
	void (* clearFiles)(file_t *self);
	void (* clear)(file_t *self);
};

int	initFile(file_t *self, int numFile, char **name);
#endif