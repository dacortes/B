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

CC := gcc
RMV = rm -rf

all:
	echo :3

createdirs:
	mkdir -p $(DIR_OBJ)
	printf "$(INFO) All object directories are ready\n"
	$(foreach dir,$(SUB_DIRS),mkdir -p $(DIR_OBJ)/$(dir);)
	printf "$(INFO) All object subdirectories are ready\n"

lexer: createdirs
	@if lex -o $(DIR_OBJ)/$(LEXER_DIR)/$(LEX_NAME) $(LEX_TREE); then \
	    printf "$(SUCCESS) create: $(LEX_NAME)\n"; \
	else \
	    printf "$(ERROR) in $@: create $(LEX_NAME) -- path: $(LEX_TREE)\n"; \
	    exit 1; \
	fi

remove_dir:
	$(RMV) $(DIR_OBJ)
	printf "$(INFO) directories of deleted objects"

clean: remove_dir

.PHONY: lexerz clean remove_dir $(DIR_OBJS)
.SILENT:

