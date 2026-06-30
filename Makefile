################################################################################
#                               COLOR DEFINITIONS                              #
################################################################################
END = \033[m
RED = \033[31m
GREEN = \033[32m
YELLOW = \033[33m
BLUE = \033[34m
LIGTH = \033[1m
DARK = \033[2m
ITALIC = \033[3m

SUCCESS = $(LIGTH)$(GREEN)[SUCCESS]$(END)
WARNING = $(LIGTH)$(YELLOW)[WARNING]$(END)
INFO = $(LIGTH)$(BLUE)[INFO]$(END)
ERROR = $(LIGTH)$(RED)[ERROR]$(END)

################################################################################
#                               BUILD VARIABLES                                #
################################################################################

LEXER_DIR = lexer
LEX_FILE  = lex.yy.c
LEX_TREE = $(LEXER_DIR)/b.l
LEX_NAME = lexer_b

DIR_OBJ = .obj
SUB_DIRS = $(LEXER_DIR)

CC := cc
RMV = rm -rf
BINARIES = $(LEX_NAME)

all: lexer

createdirs:
	mkdir -p $(DIR_OBJ)
	printf "$(INFO) All object directories are ready\n"
	$(foreach dir,$(SUB_DIRS),mkdir -p $(DIR_OBJ)/$(dir);)
	printf "$(INFO) All object subdirectories are ready\n"

lexer_obj: createdirs
	@if lex -o $(DIR_OBJ)/$(LEXER_DIR)/$(LEX_NAME).c $(LEX_TREE); then \
	    printf "$(SUCCESS) create: $(LEX_NAME)\n"; \
	else \
	    printf "$(ERROR) in $@: create $(LEX_NAME) -- path: $(LEX_TREE)\n"; \
	    exit 1; \
	fi

lexer: lexer_obj
	if $(CC) $(DIR_OBJ)/$(LEXER_DIR)/$(LEX_NAME).c -o $(LEX_NAME) -ll; then \
		printf "$(SUCCESS) Created: $(LEX_NAME)\n"; \
	else \
		printf "$(ERROR) compilation failure $(LEX_NAME)\n"; \
		exit 1; \
	fi

clean:
	@if [ -d "$(DIR_OBJ)" ]; then \
		$(RMV) "$(DIR_OBJ)"; \
		printf "$(SUCCESS) Object directory removed\n"; \
	else \
		printf "$(WARNING) Object directory not found\n"; \
	fi

fclean: clean
	@for bin in $(BINARIES); do \
		if [ -f "$$bin" ]; then \
			$(RMV) "$$bin"; \
			printf "$(SUCCESS) Binary $$bin removed\n"; \
		else \
			printf "$(WARNING) Binary $$bin not found, skipping\n"; \
		fi; \
	done

.PHONY: lexer lexer_obj clean fclean
.SILENT:

