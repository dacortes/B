#include "buffer.h"

static char *output_buffer = NULL;
static size_t output_size = 0;

void emit(const char *fmt, ...) {
	va_list args;
	va_start(args, fmt);
	size_t len = vsnprintf(NULL, 0, fmt, args);
	va_end(args);

	char *new_buffer = realloc(output_buffer, output_size + len + 1);
	if (!new_buffer) {
		fprintf(stderr, "Error: memory allocation failed in emit()\n");
		exit(1);
	}
	output_buffer = new_buffer;

	va_start(args, fmt);
	vsprintf(output_buffer + output_size, fmt, args);
	va_end(args);
	output_size += len;
}

void flush_output(void) {
	if (!output_buffer || output_size == 0)
		return;

	fwrite(output_buffer, 1, output_size, stdout);
}

void clear_buffer(void) {
	if (output_buffer) {
		free(output_buffer);
		output_buffer = NULL;
		output_size = 0;
	}
}
