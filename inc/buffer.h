#ifndef BUFFER_H
#define BUFFER_H

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void	emit(const char *fmt, ...);
void	flush_output(void);
void	clear_buffer(void);

#endif
