#
# Makefile for HXC (the HX compiler)
#

# The build command, sources (projects), and build flags.
BUILD=dune build
DEV_FLAGS=--profile=dev
REL_FLAGS=--profile=release
FLAGS=

#
# Build rules.
#

# The default is to build everything in release mode.
.DEFAULT_GOAL:= all
.PHONY: all
all: development

# Prepare release build
.PHONY: release
release: FLAGS:=$(REL_FLAGS)
release: build

# Prepare development build
.PHONY: development
development: FLAGS:=$(DEV_FLAGS)
development: build

.PHONY: dev
dev: development

# Generic build rule
.PHONY: build
build: dune-project
	$(BUILD) $(FLAGS)

# Debug build rules
.PHONY: debug-parser
debug-parser: text/parser.mly
	menhir --explain text/parser.mly
	mv text/parser.conflicts .

# Clean up
.PHONY: clean
clean:
	dune clean
