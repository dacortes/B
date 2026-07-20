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

LEXER_DIR = lex
LEX_FILE  = lex.yy.c
LEX_TREE = $(LEXER_DIR)/b.l
LEX_NAME = lexer_b

YACC_DIR = yacc
YACC_FILE = 
DIR_SRC = .src
DIR_INC = .inc
SUB_DIRS_SRC = $(LEXER_DIR)
SUB_DIRS_INC = 

CC := cc
RMV = rm -rf
BINARIES = $(LEX_NAME)

all: lexer

help: ## Show this help
	@echo "$(INFO) Available targets:$(END)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(LIGTH)%-20s$(END) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

createdirs: ## Create source directories
	mkdir -p $(DIR_SRC) $(DIR_INC)
	printf "$(INFO) All source directories are ready\n"
	$(foreach dir,$(SUB_DIRS_SRC),mkdir -p $(DIR_SRC)/$(dir);)
	printf "$(INFO) All source subdirectories are ready\n"

lexer_src: createdirs ## Generate lexer C source from .l file
	@if lex -o $(DIR_SRC)/$(LEXER_DIR)/$(LEX_NAME).c $(LEX_TREE); then \
	    printf "$(SUCCESS) create: $(LEX_NAME)\n"; \
	else \
	    printf "$(ERROR) in $@: create $(LEX_NAME) -- path: $(LEX_TREE)\n"; \
	    exit 1; \
	fi

lexer: lexer_src ## Compile lexer (standalone)
	if $(CC) $(DIR_SRC)/$(LEXER_DIR)/$(LEX_NAME).c -o $(LEX_NAME) -ll; then \
		printf "$(SUCCESS) Created: $(LEX_NAME)\n"; \
	else \
		printf "$(ERROR) compilation failure $(LEX_NAME)\n"; \
		exit 1; \
	fi

clean: ## Remove object directory
	@if [ -d "$(DIR_SRC)" ]; then \
		$(RMV) "$(DIR_SRC)"; \
		printf "$(SUCCESS) Object directory removed\n"; \
	else \
		printf "$(WARNING) Object directory not found\n"; \
	fi

fclean: clean ## Remove binaries and object directory
	@for bin in $(BINARIES); do \
		if [ -f "$$bin" ]; then \
			$(RMV) "$$bin"; \
			printf "$(SUCCESS) Binary $$bin removed\n"; \
		else \
			printf "$(WARNING) Binary $$bin not found, skipping\n"; \
		fi; \
	done

re: fclean all ## Rebuild everything (fclean + all)

.PHONY: lexer lexer_src clean fclean
.SILENT:

