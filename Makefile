#
# Makefile for FXC (the FX compiler)
#

# Project root and build directory
ROOT:=$(shell dirname $(firstword $(MAKEFILE_LIST)))
BUILD_DIR:=$(ROOT)/_build

# The build command, sources (projects), and build flags.
BUILD=dune build
PROJECTS=fx
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
build: assemble link-executable

.PHONY: assemble
assemble: dune dune-project
	$(BUILD) $(FLAGS) @install

.PHONY: link-executable
link-executable: $(BUILD_DIR)/default/fx
	ln -fs $(BUILD_DIR)/default/fx $(ROOT)/fx

# Clean up
.PHONY: clean
clean:
	dune clean
	rm -f $(ROOT)/fx
