#include <labels.h>

int label_count = 0;

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

char *new_label(void)
{
	char *label = calloc(sizeof(char), len_num(label_count) + 2);
	if (!label)
		return NULL;
	sprintf(label, ".L%d", label_count++);
	return label;
}