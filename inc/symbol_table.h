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
 * @var idxf
 * @brief Current number of functions stored in the symbol table.
 *
 * This variable tracks the number of valid entries in the `functions`
 * array. It is used as an index for adding new functions and for iterating
 * over existing entries.
 */
extern int idxf;

/*==============================================================================
 *                              Function Prototypes
 *============================================================================
 */

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
