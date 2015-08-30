# Makefile

.SILENT:

# Compiler
CC = clang
CF = -g -Wall -std=c11
CT = lldb

# Directories
_S = ./src
_D = ./docs
_B = ./build
_T = ./tests
_C = $(notdir $(shell pwd))

# Files
B  = $(wildcard $(_B)/*)
S  = $(wildcard $(_S)/*.c)
H  = $(wildcard $(_S)/*.h)
T  = $(wildcard $(_T)/*.c)
D  = $(shell $(DG) $(DF) ${H})

# Documentation
DG = ./deps/docco/bin/docco
DF = -l linear -l plain-markdown
DGS = https://github.com/jashkenas/docco

# Recipes
all: setup clean-all docs test-all

clean :
	rm -rf ./$(_B) ;

clean-all : clean
	rm -rf ./$(_D) ;

setup :
	mkdir -p $(_S) $(_T) deps;

	echo "# $(_C) :\n___\n" > Readme.md
	echo "Documentation :" >> Readme.md
	$(foreach f, \
		$(wildcard docs/*.md), \
		echo "[$(f)]($(f))" >> Readme.md \
	)

	if [ -e $(DG) ] ; then \
		echo "Found: $(DG)"; \
	else \
		git clone $(DGS) ./deps/$(notdir $(DG)); \
		cd ./deps/$(notdir $(DG)) && npm install; \
	fi

test : setup
	mkdir -p $(_B);

	$(foreach f, \
		${T}, \
		$(CC) $(CF) $(f) ${S} -o $(_B)/$(basename \
			$(notdir $(f)) \
		); \
	)

test-all : test
	$(foreach f, \
		$(notdir \
			$(basename \
				$(wildcard $(_T)/*.c) \
			) \
		), \
		$(CT) ./$(_B)/$(f); \
	)

docs : setup
	echo "${D}";

	$(foreach f, \
		$(wildcard ./$(_D)/*.html), \
		echo "     $(f) -> $(basename $(f))" && \
			mv $(f) $(basename $(f)).md; \
	)

.PHONY: test test-all docs clean-all
