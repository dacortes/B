#ifndef LABELS_H
#define LABELS_H

#include <stdio.h>
#include <stdlib.h>

extern int label_count;

char *new_label(const char *tag);
char *new_label_str(const char *tag);

#endif