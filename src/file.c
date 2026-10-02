#include <file.h>

int checkExtension(char *name, int size)
{
	if (size < 3) {
		fprintf(stderr, "Error: \
		The file name must include its extension and a \
		name consisting of at least one character.\n");
		return ERROR;
	}

	char *exten = &name[size - 2];
	if (strncmp(".b", exten, 2)) {
		fprintf(stderr , "Error: file extension %s\n", name);
		return ERROR;
	}
	return false;
}

int checkFiles(char *name, int size)
{
	if (checkExtension(name, size))
		return ERROR;

	if (access(name, F_OK)) {
		fprintf(stderr, "Error: The file does not exist: %s.\n", name);
		return ERROR;
	}
	if (access(name, R_OK)) {
		fprintf(stderr, "Error: The file does not have read permission: %s.\n", name);
		return ERROR;
	}
	return false;
}

void clearFiles(file_t *self)
{
	if (!self->files || !*self->files)
		return;
	
	int i = 0;

	while(self->files[i]) {
		free(self->files[i]);
		self->files[i] = NULL;
		++i;
	}
	free(self->files);
}

void clear(file_t *self)
{
	self->clearFiles(self);
	if (self->buffer) {
		free(self->buffer);
		self->buffer = NULL;
	}
}

void newLine(file_t *self, FILE *fp)
{
	if (self->lenBuff > 0 && self->buffer[self->lenBuff - 1] != '\n') {
		char *new_buff = realloc(self->buffer, self->lenBuff + 2);

		if (!new_buff) {
			free(self->line);
			fclose(fp);
			exit(exitError(err_mem, "realloc failed"));
		}
		self->buffer = new_buff;
		self->buffer[self->lenBuff] = '\n';
		self->buffer[self->lenBuff + 1] = '\0';
		self->lenBuff += 1;
	}
}

int addBuffer(file_t *self, FILE *fp)
{
	ssize_t nread;

	while ((nread = getline(&self->line, &self->lenLine, fp)) != -1) {
		size_t lenLine = (size_t)nread;

		char *new_buff = realloc(self->buffer, self->lenBuff + lenLine + 1);
		if (!new_buff) {
			free(self->line);
			fclose(fp);
			exit(exitError(err_mem, "realloc failed in addBuffer"));
		}
		self->buffer = new_buff;

		memcpy(self->buffer + self->lenBuff, self->line, lenLine);
		self->lenBuff += lenLine;
		self->buffer[self->lenBuff] = '\0';
	}
	newLine(self, fp);
	free(self->line);
	self->line = NULL;
	self->lenLine = 0;
	fclose(fp);

	if (self->buffer)
		fprintf(stderr, "Buffer acumulado (%lu bytes):\n%s\n",
				self->lenBuff, self->buffer);

	return 0;
}

int readFiles(file_t *self)
{
	if (!self->files || !*self->files) {
		self->clearFiles(self);
		exit(exitError(err_mem, "Null pointer: files"));
	}
	int		i = 0;

	while (self->files[i])
	{
		fprintf(stderr, "*%s*\n", self->files[i]);
		FILE *fp = fopen(self->files[i], "r");

		if (!fp) {
			self->clearFiles(self);
			exit(exitError(err_mem, "Null pointer: fp"));
		}
		self->addBuffer(self, fp);
		++i;
	}
	return 0;
}

void setFile(file_t *self)
{
	self->files = NULL;
	self->buffer = NULL;
	self->line = NULL;

	self->lenLine = 0;
	self->lenBuff = 0;
	self->clearFiles = clearFiles;
	self->readFiles = readFiles;
	self->addBuffer = addBuffer;
	self->clear = clear;

}

int initFile(file_t *self, int numFile, char **name)
{
	if (numFile <= 1)
		exit(exitError(err_param, "It has no parameters."));

	setFile(self);
	self->files = calloc(numFile, sizeof(char *));

	if (!self->files)
		exit(exitError(err_mem, "memory allocation in files"));
	for(int i = 0; i < (numFile - 1); i++) {
		int sizeFile = strlen(name[i + 1]);

		if (checkFiles(name[i + 1], sizeFile) == ERROR) {
			self->clearFiles(self);
			exit(ERROR);
		}
		self->files[i] = strndup(name[i + 1], sizeFile);

		if (!self->files[i]) {
			self->clearFiles(self);
			exit(exitError(err_mem, "memory allocation in strndup"));
		}
	}
	return 0;
}
