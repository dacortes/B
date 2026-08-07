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

SRC_DIR   = src
INC_DIR   = inc
LEX_DIR   = $(SRC_DIR)/lex
YACC_DIR  = $(SRC_DIR)/yacc

LEX_SRC   = $(LEX_DIR)/b.l
YACC_SRC  = $(YACC_DIR)/b.y

GEN_DIR   = .gen
OBJ_DIR   = .obj
DEP_DIR   = .dep

LEX_GEN   = lex.yy.c
YACC_GEN  = y.tab.c
YACC_H    = y.tab.h

SRC_EXTRA = $(SRC_DIR)/symbol_table.c
OBJ_EXTRA = $(SRC_EXTRA:$(SRC_DIR)/%.c=$(OBJ_DIR)/%.o)
DEP_EXTRA = $(SRC_EXTRA:$(SRC_DIR)/%.c=$(DEP_DIR)/%.d)

OBJS      = $(OBJ_DIR)/$(YACC_GEN:.c=.o) $(OBJ_DIR)/$(LEX_GEN:.c=.o) $(OBJ_EXTRA)
DEPS      = $(DEP_DIR)/$(YACC_GEN:.c=.d) $(DEP_DIR)/$(LEX_GEN:.c=.d) $(DEP_EXTRA)

BIN       = B

CC        = cc
CFLAGS    = -Wall -Wextra -Werror -I$(GEN_DIR) -I$(INC_DIR) -g
LDFLAGS   =

LEX       = flex
YACC      = bison
RM        = rm -rf

DEBUG_FLAGS = -DDEBUG

all: $(BIN) ## Build the compiler

debug: CFLAGS += $(DEBUG_FLAGS)  ## Build the compiler con logs (DEBUG)
debug: all

createdirs: ## Create source directories
	mkdir -p $(OBJ_DIR) $(DEP_DIR) $(INC_DIR)
	printf "$(INFO) All source directories are ready\n"
# 	$(foreach dir,$(SUB_DIRS_SRC),mkdir -p $(DIR_SRC)/$(dir);)
# 	printf "$(INFO) All source subdirectories are ready\n"

$(BIN): createdirs $(OBJS) ## Link object files into final binary
	@printf "$(INFO) Linking $@\n"
	$(CC) $(CFLAGS) $(OBJS) -o $@ $(LDFLAGS)
	@printf "$(SUCCESS) Compiler $(BIN) built\n"

$(OBJ_DIR)/%.o: $(GEN_DIR)/%.c
	@printf "$(INFO) Compiling $<\n"
	$(CC) $(CFLAGS) -MMD -MP -MF $(DEP_DIR)/$*.d -c $< -o $@

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	@mkdir -p $(OBJ_DIR) $(DEP_DIR)
	@printf "$(INFO) Compiling $<\n"
	$(CC) $(CFLAGS) -MMD -MP -MF $(DEP_DIR)/$*.d -c $< -o $@

$(GEN_DIR)/$(YACC_GEN) $(GEN_DIR)/$(YACC_H): $(YACC_SRC)
	@mkdir -p $(GEN_DIR)
	@printf "$(INFO) Generating parser from $<\n"
	$(YACC) -d -o $(GEN_DIR)/$(YACC_GEN) $<
	@printf "$(SUCCESS) Generated $(YACC_GEN) and $(YACC_H)\n"

$(GEN_DIR)/$(LEX_GEN): $(LEX_SRC) $(GEN_DIR)/$(YACC_H)
	@mkdir -p $(GEN_DIR)
	@printf "$(INFO) Generating lexer from $<\n"
	$(LEX) -o $(GEN_DIR)/$(LEX_GEN) $<
	@printf "$(SUCCESS) Generated $(LEX_GEN)\n"

$(OBJ_DIR)/$(YACC_GEN:.c=.o): $(GEN_DIR)/$(YACC_GEN) $(GEN_DIR)/$(YACC_H)
$(OBJ_DIR)/$(LEX_GEN:.c=.o): $(GEN_DIR)/$(LEX_GEN) $(GEN_DIR)/$(YACC_H)

$(OBJS): | $(OBJ_DIR) $(DEP_DIR)

-include $(DEPS)

################################################################################
#                              clean rules		                               #
################################################################################

clean: ## Remove generated objects and gen files
	@if [ -d "$(OBJ_DIR)" ]; then \
		$(RM) $(OBJ_DIR); \
		printf "$(SUCCESS) Object directory removed\n"; \
	else \
		printf "$(WARNING) Object directory not found\n"; \
	fi
	@if [ -d "$(DEP_DIR)" ]; then \
		$(RM) $(DEP_DIR); \
		printf "$(SUCCESS) Dependencies directory removed\n"; \
	else \
		printf "$(WARNING) Dependencies directory not found\n"; \
	fi
	@if [ -d "$(GEN_DIR)" ]; then \
		$(RM) $(GEN_DIR); \
		printf "$(SUCCESS) Generated sources directory removed\n"; \
	else \
		printf "$(WARNING) Generated sources directory not found\n"; \
	fi

fclean: clean ## Remove binary too
	@if [ -f "$(BIN)" ]; then \
		$(RM) $(BIN); \
		printf "$(SUCCESS) Binary $(BIN) removed\n"; \
	else \
		printf "$(WARNING) Binary $(BIN) not found\n"; \
	fi

re: fclean all ## Rebuild everything

################################################################################
#                              (make help)     		                           #
################################################################################

help: ## Show this help
	@echo "$(INFO) Available targets:$(END)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(LIGTH)%-20s$(END) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: all clean fclean re help
.SILENT: