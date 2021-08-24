#
# Makefile for HXC (the HX compiler)
#

# Project root and build directory
ROOT:=$(shell dirname $(firstword $(MAKEFILE_LIST)))
BUILD_DIR:=$(ROOT)/_build

# The build command, sources (projects), and build flags.
BUILD=dune build
PROJECTS=hx
COMMON_FLAGS=$(PROJECTS) --build-dir=$(BUILD_DIR)
DEV_FLAGS=$(COMMON_FLAGS) --profile=dev
REL_FLAGS=$(COMMON_FLAGS) --profile=release
FLAGS=

#
# Build rules.
#

# The default is to build everything in release mode.
.DEFAULT_GOAL:= all
.PHONY: all
all: release

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
build: unlink-executable assemble link-executable

.PHONY: assemble
assemble: dune dune-project
	$(BUILD) $(FLAGS) @install

.PHONY: link-executable
link-executable: $(BUILD_DIR)/default/hx
	ln -fs $(BUILD_DIR)/default/hx $(ROOT)/hx

.PHONY: unlink-executable
unlink-executable:
	rm -f $(ROOT)/hx

# Clean up
.PHONY: clean
clean:	unlink-executable
	dune clean
