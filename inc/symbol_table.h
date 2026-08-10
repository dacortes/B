/* SPDX-License-Identifier: GPL-2.0 */
/**
 * @file symbol_table.h
 * @brief Symbol table management for the B compiler.
 *
 * This module provides a simple symbol table implementation to track
 * function declarations and definitions during the compilation process.
 * It ensures that duplicate function definitions are detected and reported
 * as errors, maintaining semantic correctness of the compiled program.
 */
#ifndef SYMBOL_TABLE_H
#define SYMBOL_TABLE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*==============================================================================
 *                                  Constants
 *============================================================================
 */

/**
 * @def ERROR
 * @brief Return code indicating an error condition.
 */
#define ERROR	-1

/**
 * @def true
 * @brief Boolean true value.
 */
#define true	1

/**
 * @def false
 * @brief Boolean false value.
 */
#define false	0

/*==============================================================================
 *                                  Data Types
 *============================================================================
 */

/**
 * @struct var_symbol
 * @brief Represents a variable entry in the symbol table.
 *
 * Each variable has a name, a scope (NULL for global, or the function
 * name for local), a defined flag, and an offset for stack allocation.
 */
struct var_symbol {
	char *name;		/**< Variable name */
	char *scope;	/**< NULL for global, function name for local */
	int defined;	/**< 1 if defined, 0 if extern reference */
	int offset;		/**< Stack offset (for locals) */
};

/**
 * @struct function_t
 * @brief Represents a function entry in the symbol table.
 *
 * This structure holds the name of a function and a flag indicating
 * whether it has been defined. It is used to detect duplicate definitions
 * and to ensure that the required `main` function is present.
 */
struct  function_t {
	char *name;      /**< Function name as a dynamically allocated string */
	int defined;     /**< Boolean flag: 1 if defined, 0 if declared only */
};

/*==============================================================================
 *                              Global Variables
 *============================================================================
 */

/**
 * @var functions
 * @brief Dynamic array of function entries.
 *
 * This pointer points to a dynamically allocated array of `function_t`
 * structures. The array grows as new functions are encountered during
 * parsing.
 */
extern struct function_t *functions;

/**
 * @var var_table
 * @brief Dynamically allocated array of variable symbols.
 *
 * This table stores all variables (both global and local) encountered
 * during parsing. Each entry contains the variable name, its scope
 * (NULL for globals, function name for locals), a defined flag, and
 * its stack offset for local variables.
 *
 * The table grows dynamically as new variables are added using
 * addVariable(). Memory is managed with realloc() and freed with
 * clearVariables().
 */
extern struct var_symbol *var_table;

/**
 * @var idxf
 * @brief Current number of functions stored in the symbol table.
 *
 * This variable tracks the number of valid entries in the `functions`
 * array. It is used as an index for adding new functions and for iterating
 * over existing entries.
 */
extern int idxf;

/**
 * @var idxv
 * @brief Number of variables currently stored in the table.
 */
extern int idxv;

/*==============================================================================
 *                              Function Prototypes
 *============================================================================
 */

/**
 * @brief Checks if a variable with the given name and scope exists.
 *
 * @param name  Variable name to look up.
 * @param scope The scope to check: NULL for global, function name for local.
 * @return true (1) if found, false (0) otherwise.
 *
 * @note Two variables with the same name but different scopes are
 *       considered distinct (e.g., 'x' in main and 'x' in foo).
 */
int variableExists(char *name, char *scope);

/**
 * @brief Adds a new variable to the symbol table.
 *
 * @param name  Variable name to add (will be duplicated).
 * @param scope The scope for this variable: NULL for global, function name for local.
 * @return 0 on success, ERROR (-1) if duplicate exists or allocation fails.
 */
int addVariable(char *name, char *scope);

/**
 * @brief Clears and frees the entire variable symbol table.
 */
void clearVariables(void);

/**
 * @brief Checks whether a function with the given name already exists.
 *
 * This function performs a linear search through the symbol table to
 * determine if a function name has already been registered. It is used
 * to prevent duplicate function definitions.
 *
 * @param name The function name to look up (case-sensitive).
 * @return int Returns `true` (1) if the function exists, `false` (0) otherwise.
 */
int functionExists(char *name);

/**
 * @brief Adds a new function to the symbol table.
 *
 * This function registers a new function name in the symbol table after
 * verifying that it does not already exist. On success, the function entry
 * is appended to the dynamic array. On failure (duplicate or memory error),
 * an error code is returned.
 *
 * @param name The function name to add (will be duplicated internally).
 * @return int Returns 0 on success, or ERROR (-1) if the function already
 *             exists or a memory allocation failure occurs.
 */
int addFuntion(char *name);

/**
 * @brief Clears and frees the entire symbol table.
 *
 * This function releases all memory associated with the symbol table,
 * including the dynamically allocated function names and the array itself.
 * After calling this function, the global pointers are reset to NULL and
 * the function count is set to zero. It is typically called at the end
 * of compilation or when a fatal error occurs.
 */
void clearFuntions(void);

#endif
