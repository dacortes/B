#ifndef ERRORS_H
#define ERRORS_H

#include <stdio.h>
#include <stdlib.h>
#include <symbol_table.h>

typedef enum errors_e {
	err_param = 1,
	err_mem,
} errors;

int exitError(int numErr, char *str);
#endif