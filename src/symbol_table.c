// SPDX-License-Identifier: GPL-2.0
/**
* @file symbol_table.c
* @brief Implementation of the symbol table management for the B compiler.
*
* This file provides the concrete implementation of the symbol table
* functions declared in symbol_table.h. It manages a dynamic array of
* function entries, allowing the compiler to track function definitions
* and detect duplicates.
*/

#include "symbol_table.h"

/*==============================================================================
*                           Global Variable Definitions
*============================================================================*/

/**
* @var functions
* @brief Pointer to the dynamically allocated array of function entries.
*
* This global variable is initialized to NULL and is reallocated as
* new functions are added.
*/
function_t *functions = NULL;

/**
* @var idxf
* @brief Number of functions currently stored in the symbol table.
*
* This counter is incremented each time a function is successfully added.
*/
int idxf = 0;

/*==============================================================================
*                         Symbol Table Implementation
*============================================================================*/

/**
* @brief Checks if a function with the given name already exists.
*
* This function performs a linear search through the symbol table.
* If the table is empty or the name is not found, it returns false.
*
* @param name The function name to search for.
* @return int Returns true if the function exists, false otherwise.
*/
int functionExists(char *name) {
	if (idxf == 0)
		return false;

	for (int idx = 0; idx < idxf; idx++)
	{
		if (strcmp(functions[idx].name, name) == 0)
			return true;
	}
	return false;
}

/**
* @brief Frees all memory used by the symbol table and resets it.
*
* This function iterates over the symbol table, frees each function name,
* then frees the array itself. After calling this, the global pointers
* are reset to NULL and the function count is set to zero.
*
* It is safe to call this function even if the symbol table is empty.
*/
void clearFuntions(void) {
	if (!functions)
		return ;

	for (int idx = 0; idx < idxf; idx++)
	{
		if (functions[idx].name)
		{
			free(functions[idx].name);
			functions[idx].name = NULL;
			functions[idx].defined = false;
		}
	}

	free(functions);
	functions = NULL;
	idxf = 0;
}

/**
* @brief Adds a new function to the symbol table.
*
* This function first validates the input name. If the function already
* exists, the symbol table is cleared and an error is returned.
* Otherwise, it attempts to reallocate the dynamic array to accommodate
* the new entry. The array size is doubled when possible to reduce
* reallocation overhead.
*
* On success, the function name is duplicated (using strdup) and stored
* in the table, and the defined flag is set to true.
*
* @param name The name of the function to add.
* @return int Returns 0 on success, ERROR (-1) on failure.
*/
int addFuntion(char *name) {
	if (!name)
		return ERROR;

	if (functionExists(name))
	{
		clearFuntions();
		return ERROR;
	}
	size_t new_size = (idxf == 0) ? 1 : idxf * 2;

	function_t *new_array = realloc(functions, new_size * sizeof(function_t));

	if (!new_array)
	{
		clearFuntions();
		return ERROR;
	}
	functions = new_array;
	functions[idxf].name = strdup(name);
	if (!functions[idxf].name)
	{
		clearFuntions();
		return ERROR;
	}
	functions[idxf].defined = true;
	idxf++;

	return 0;
}
