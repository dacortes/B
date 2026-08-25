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
 *============================================================================
 */

/**
 * @var functions
 * @brief Pointer to the dynamically allocated array of function entries.
 *
 * This global variable is initialized to NULL and is reallocated as
 * new functions are added.
 */
struct function_t *functions = NULL;

/**
 * @var idxf
 * @brief Number of functions currently stored in the symbol table.
 *
 * This counter is incremented each time a function is successfully added.
 */
int idxf = 0;

/**
 * @var var_table
 * @brief Dynamically allocated array of variable symbols.
 *
 * This table stores both global and local variables. Scopes are used
 * to differentiate variables with the same name in different functions.
 */
struct var_symbol *var_table = NULL;

/**
 * @var idxv
 * @brief Number of variables currently stored in the symbol table.
 *
 * This counter is incremented each time a function is successfully added.
 */

int idxv = 0;

/*==============================================================================
 *                         Symbol Table Implementation
 *============================================================================
 */

/**
 * @brief Checks whether a variable with the given name and scope exists.
 *
 * This function performs a linear search through the variable table
 * to determine if a variable with the specified name and scope has
 * already been registered.
 *
 * @param name  The variable name to look up (case-sensitive).
 * @param scope The scope to check: NULL for global variables, or the
 *              function name for local variables.
 * @return int Returns `true` (1) if the variable exists, `false` (0) otherwise.
 *
 * @note Two variables with the same name but different scopes are
 *       considered distinct (e.g., 'x' in main and 'x' in foo).
 */

int variableExists(char *name, char *scope)
{
	if (idxv == 0)
		return false;

	for (int i = 0; i < idxv; i++) {
		if (strcmp(var_table[i].name, name) == 0) {
			if ((scope == NULL && var_table[i].scope == NULL) ||
				(scope != NULL && var_table[i].scope != NULL &&
				strcmp(var_table[i].scope, scope) == 0)) {
				return true;
			}
		}
	}
	return false;
}

/**
 * @brief Clears and frees the entire variable symbol table.
 *
 * This function releases all memory associated with the variable table:
 * - Frees the name string for each variable.
 * - Frees the scope string for each variable.
 * - Resets the defined and offset fields to 0.
 * - Frees the table itself and resets var_table to NULL.
 * - Resets idxv to 0.
 *
 * It is safe to call this function even if the table is empty or already
 * cleared. Typically called at the end of compilation or on fatal errors.
 */

void clearVariables(void)
{
	if (!var_table)
		return;

	for (int i = 0; i < idxv; i++) {
		if (var_table[i].name)
			free(var_table[i].name);
		if (var_table[i].scope)
			free(var_table[i].scope);
		var_table[i].defined = 0;
		var_table[i].offset = 0;
	}
	free(var_table);
	var_table = NULL;
	idxv = 0;
}

/**
 * @brief Adds a new variable to the symbol table.
 *
 * This function registers a new variable in the symbol table after:
 * - Validating that the name is not NULL.
 * - Verifying that no variable with the same name and scope exists.
 *
 * On success, the variable entry is appended to the dynamic array.
 * The array is reallocated with a growing strategy (doubling the size
 * or allocating 1 element for the first entry) to minimize reallocations.
 *
 * @param name  The variable name to add (will be duplicated internally).
 * @param scope The scope of the variable: NULL for global variables,
 *              or the function name for local variables.
 * @return int Returns 0 on success, or ERROR (-1) if:
 *             - The name is NULL.
 *             - The variable already exists in the given scope.
 *             - Memory allocation fails.
 *
 * @note The function uses strdup() to duplicate the name and scope
 *       strings, so the caller is responsible for freeing their own
 *       copies. On failure, the table is cleared to maintain consistency.
 */

int addVariable(char *name, char *scope)
{
	if (!name)
		return ERROR;

	if (variableExists(name, scope)) {
		fprintf(stderr, "Error: variable '%s' already defined in scope '%s'\n",
				name, scope ? scope : "global");
		return ERROR;
	}

	size_t new_size = (idxv == 0) ? 1 : idxv * 2;
	struct var_symbol *new_table = realloc(var_table, new_size * sizeof(struct var_symbol));

	if (!new_table) {
		clearVariables();
		return ERROR;
	}
	var_table = new_table;

	var_table[idxv].name = strdup(name);
	var_table[idxv].scope = scope ? strdup(scope) : NULL;
	var_table[idxv].defined = 1;
	var_table[idxv].offset = 0;
	idxv++;
	return 0;
}


int get_variable_offset(char *name, char *scope) {
	for (int i = 0; i < idxv; i++) {
		if (strcmp(var_table[i].name, name) == 0) {
			if ((scope == NULL && var_table[i].scope == NULL) ||
				(scope != NULL && var_table[i].scope != NULL &&
				strcmp(var_table[i].scope, scope) == 0)) {
				return var_table[i].offset;
			}
		}
	}
	return -1;
}

void set_variable_offset(char *name, char *scope, int offset) {
	for (int i = 0; i < idxv; i++) {
		if (strcmp(var_table[i].name, name) == 0) {
			if ((scope == NULL && var_table[i].scope == NULL) ||
				(scope != NULL && var_table[i].scope != NULL &&
				strcmp(var_table[i].scope, scope) == 0)) {
				var_table[i].offset = offset;
				return;
			}
		}
	}
}


/**
 * @brief Checks if a function with the given name already exists.
 *
 * This function performs a linear search through the symbol table.
 * If the table is empty or the name is not found, it returns false.
 *
 * @param name The function name to search for.
 * @return int Returns true if the function exists, false otherwise.
 */
int functionExists(char *name)
{
	if (idxf == 0)
		return false;

	for (int idx = 0; idx < idxf; idx++) {
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
void clearFuntions(void)
{
	if (!functions)
		return;

	for (int idx = 0; idx < idxf; idx++) {
		if (functions[idx].name) {
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
int addFuntion(char *name)
{
	if (!name)
		return ERROR;

	if (functionExists(name)) {
		clearFuntions();
		return ERROR;
	}
	size_t new_size = (idxf == 0) ? 1 : idxf * 2;

	struct function_t *new_array = realloc(functions, new_size * sizeof(struct function_t));

	if (!new_array) {
		clearFuntions();
		return ERROR;
	}
	functions = new_array;
	functions[idxf].name = strdup(name);
	if (!functions[idxf].name) {
		clearFuntions();
		return ERROR;
	}
	functions[idxf].defined = true;
	idxf++;

	return 0;
}
