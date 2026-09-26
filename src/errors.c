#include <errors.h>

int exitError(int numErr, char *str)
{
	if (!str)
		return ERROR;

	fprintf(stderr, "Error: %s\n", str);
	return numErr;
}
