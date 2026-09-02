#include <labels.h>

int	label_count = 0;
int	string_count = 0;

static int	len_num(int num)
{
	int	len;

	len = 0;
	if (num <= 0)
		len++;
	while (num)
	{
		len++;
		num = num / 10;
	}
	return (len);
}

char *new_label(const char *tag)
{
	char *label = calloc(sizeof(char), len_num(label_count) + 2);

	if (!label)
		return NULL;
	sprintf(label, "%s%d", tag, label_count++);
	return label;
}

char *new_label_str(const char *tag)
{
	char *label = calloc(sizeof(char), len_num(string_count) + 2);

	if (!label)
		return NULL;
	sprintf(label, "%s%d", tag, string_count++);
	return label;
}
