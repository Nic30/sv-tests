INSTALL_DIR := $(abspath $(OUT_DIR)/runners/)

RDIR := third_party/tools
TDIR := tools

# get number of available cores for the build parallelization
# if not specified otherwise
ifeq ($J,)
	OS := $(shell uname)
	ifeq ($(OS),Linux)
		NPROCS := $(shell grep -c ^processor /proc/cpuinfo)
	else ifeq ($(OS),Darwin)
		NPROCS := $(shell system_profiler | awk '/Number of CPUs/ {print $$4}{next;}')
	else
		# can not resolve number of CPUs
		NPROCS := 1
	endif
else
	NPROCS := $J
endif

.PHONY: runners

runners:

# odin
odin: $(INSTALL_DIR)/bin/odin_II

$(INSTALL_DIR)/bin/odin_II:
	$(MAKE) -C $(RDIR)/odin_ii/ODIN_II/ build
	install -D $(RDIR)/odin_ii/ODIN_II/odin_II $@

# yosys
yosys: $(INSTALL_DIR)/bin/yosys

$(INSTALL_DIR)/bin/yosys:
	$(MAKE) -C $(RDIR)/yosys ENABLE_TCL=0 ENABLE_ABC=0 ENABLE_GLOB=0 ENABLE_PLUGINS=0 ENABLE_READLINE=0 ENABLE_COVER=0
	install -D $(RDIR)/yosys/yosys $@

# icarus
icarus: $(INSTALL_DIR)/bin/iverilog

$(INSTALL_DIR)/bin/iverilog:
	cd $(RDIR)/icarus && autoconf
	cd $(RDIR)/icarus && ./configure --prefix=$(abspath $(INSTALL_DIR))/
	$(MAKE) -C $(RDIR)/icarus
	$(MAKE) -C $(RDIR)/icarus installdirs
	$(MAKE) -C $(RDIR)/icarus install

# verilator
verilator: $(INSTALL_DIR)/bin/verilator

$(INSTALL_DIR)/bin/verilator:
	cd $(RDIR)/verilator && autoconf
	cd $(RDIR)/verilator && ./configure --prefix=$(abspath $(INSTALL_DIR))/
	$(MAKE) -C $(RDIR)/verilator
	$(MAKE) -C $(RDIR)/verilator install

# slang
slang: $(INSTALL_DIR)/bin/driver

$(INSTALL_DIR)/bin/driver:
	mkdir -p $(RDIR)/slang/build
	cd $(RDIR)/slang/build && cmake .. -DSLANG_INCLUDE_TESTS=OFF
	$(MAKE) -C $(RDIR)/slang/build
	mkdir -p $(INSTALL_DIR)/bin
	install $(RDIR)/slang/build/bin/* $(INSTALL_DIR)/bin/

# zachjs-sv2v
zachjs-sv2v: $(INSTALL_DIR)/bin/zachjs-sv2v

$(INSTALL_DIR)/bin/zachjs-sv2v:
	$(MAKE) -C $(RDIR)/zachjs-sv2v
	install -D $(RDIR)/zachjs-sv2v/bin/sv2v $@

# tree-sitter-verilog
tree-sitter-verilog: $(INSTALL_DIR)/lib/verilog.so

$(INSTALL_DIR)/lib/verilog.so:
	mkdir -p $(INSTALL_DIR)/lib
	cd $(RDIR)/tree-sitter-verilog && npm install
	/usr/bin/env python3 -c "from tree_sitter import Language; Language.build_library(\"$@\", [\"$(abspath $(RDIR)/tree-sitter-verilog)\"])"

# sv-parser
sv-parser: $(INSTALL_DIR)/bin/parse_sv

$(INSTALL_DIR)/bin/parse_sv:
	mkdir -p $(INSTALL_DIR)/bin
	install -D $(RDIR)/sv-parser/bin/parse_sv $@

# hdlConvertor
# @note "can not" check python path files directly
#       as it's name and path is composed of arch dependent things
hdlConvertor: $(INSTALL_DIR)/share/hdlConvertor/__build_done__

$(INSTALL_DIR)/share/hdlConvertor/__build_done__:
	mkdir -p $(INSTALL_DIR)/share/hdlConvertor
	cd $(RDIR)/hdlConvertor/ && ./setup.py build -j $(NPROCS)
	cd $(RDIR)/hdlConvertor/ && ./setup.py bdist
	# note not using --prefix as it check PYTHONPATH and $(INSTALL_DIR)/lib/python*/... is not in
	# [todo] use virtualenv 
	cd $(RDIR)/hdlConvertor/dist/ && tar -xzf hdlConvertor-*.tar.gz -C $(INSTALL_DIR)
	touch $(INSTALL_DIR)/share/hdlConvertor/__build_done__


# setup the dependencies
RUNNERS_TARGETS := odin yosys icarus verilator slang zachjs-sv2v tree-sitter-verilog sv-parser hdlConvertor
.PHONY: $(RUNNERS_TARGETS)
runners: $(RUNNERS_TARGETS)
