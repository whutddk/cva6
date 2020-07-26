#=======================================================================
# UCB VLSI FLOW: Makefile for riscv-bmarks
#-----------------------------------------------------------------------
# Yunsup Lee (yunsup@cs.berkeley.edu)
#


default: all



#--------------------------------------------------------------------
# Sources
#--------------------------------------------------------------------

bmarks = \
	test_uart \

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

RISCV_GCC ?= riscv64-unknown-elf-gcc
RISCV_GCC_OPTS ?= -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O2 -ffast-math -fno-common -fno-builtin-printf
RISCV_LINK ?= riscv64-unknown-elf-gcc -T ./common/test.ld $(incs)
RISCV_LINK_OPTS ?= -static -nostdlib -nostartfiles -lm -lgcc -T ./common/test.ld
RISCV_OBJDUMP ?= riscv64-unknown-elf-objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.data
RISCV_SIM ?= spike --isa=rv64gc

incs  += -I ./common -I $./../libs $(addprefix -I $./, $(bmarks))
objs  :=

define compile_template
$(1).riscv: $(wildcard ./$(1)/*) $(wildcard ./common/*) $(wildcard ./../libs/*)
	$$(RISCV_GCC) $$(incs) $$(RISCV_GCC_OPTS) -o $$@ $(wildcard ./$(1)/*.c) $(wildcard ./common/*.c) \
	$(wildcard ./../libs/*.c) $(wildcard ./common/*.S) $$(RISCV_LINK_OPTS)
endef

$(foreach bmark,$(bmarks),$(eval $(call compile_template,$(bmark))))

#------------------------------------------------------------
# Build


bmarks_riscv_dump = $(addsuffix .riscv.dump, $(bmarks))

$(bmarks_riscv_dump): %.riscv.dump: %.riscv
	$(RISCV_OBJDUMP) $< > $@



riscv: $(bmarks_riscv_dump)


junk +=  $(bmarks_riscv_dump) 

#------------------------------------------------------------
# Default

all: riscv


#------------------------------------------------------------
# Clean up

clean:
	rm -rf $(objs) $(junk)
