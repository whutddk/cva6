# Author: Florian Zaruba, ETH Zurich
# Date: 03/19/2017
# Description: Makefile for linting and testing Ariane.

# questa library
library        ?= work
# verilator lib
ver-library    ?= work-ver
# library for DPI
dpi-library    ?= work-dpi
# Top level module to compile
top_level      ?= ariane_tb
# Maximum amount of cycles for a successful simulation run
max_cycles     ?= 10000000
# Test case to run
test_case      ?= core_test
# QuestaSim Version
questa_version ?= ${QUESTASIM_VERSION}
# verilator version
verilator      ?= verilator
# traget option
target-options ?=
# additional definess
defines        ?= WT_DCACHE
# test name for torture runs (binary name)
test-location  ?= output/test
# set to either nothing or -log
torture-logs   :=
# custom elf bin to run with sim or sim-verilator
elf-bin        ?= tmp/riscv-tests/build/benchmarks/dhrystone.riscv
# board name for bitstream generation. Currently supported: kc705, genesys2
BOARD          ?= genesys2
# root path
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
root-dir := $(dir $(mkfile_path))

support_verilator_4 := $(shell ($(verilator) --version | grep '4\.') &> /dev/null; echo $$?)
ifeq ($(support_verilator_4), 0)
	verilator_threads := 2
endif

ifndef RISCV
$(error RISCV not set - please point your RISCV variable to your RISCV installation)
endif

# setting additional xilinx board parameters for the selected board
ifeq ($(BOARD), genesys2)
	XILINX_PART              := xc7k325tffg900-2
	XILINX_BOARD             := digilentinc.com:genesys2:part0:1.1
	CLK_PERIOD_NS            := 20
else ifeq ($(BOARD), kc705)
	XILINX_PART              := xc7k325tffg900-2
	XILINX_BOARD             := xilinx.com:kc705:part0:1.5
	CLK_PERIOD_NS            := 20
else ifeq ($(BOARD), vc707)
	XILINX_PART              := xc7vx485tffg1761-2
	XILINX_BOARD             := xilinx.com:vc707:part0:1.3
	CLK_PERIOD_NS            := 20
else
$(error Unknown board - please specify a supported FPGA board)
endif

# spike tandem verification
ifdef spike-tandem
    compile_flag += -define SPIKE_TANDEM
    ifndef preload
        $(error Tandem verification requires preloading)
    endif
endif

# Sources
# Package files -> compile first
ariane_pkg :=       include/riscv_pkg.sv                          \
                    src/riscv-dbg/src/dm_pkg.sv                   \
                    include/ariane_pkg.sv                         \
                    include/std_cache_pkg.sv                      \
                    include/wt_cache_pkg.sv                       \
                    src/axi/src/axi_pkg.sv                        \
                    src/register_interface/src/reg_intf.sv        \
                    src/register_interface/src/reg_intf_pkg.sv    \
                    include/axi_intf.sv                           \
              tb/ariane_soc_pkg.sv                          \
                    include/ariane_axi_pkg.sv                     \
              src/fpu/src/fpnew_pkg.sv                      \
              src/fpu/src/fpu_div_sqrt_mvp/hdl/defs_div_sqrt_mvp.sv
ariane_pkg := $(addprefix $(root-dir), $(ariane_pkg))

# utility modules
util := include/instr_tracer_pkg.sv                         \
        src/util/instr_tracer_if.sv                         \
        src/util/instr_tracer.sv                            \
        src/tech_cells_generic/src/cluster_clock_gating.sv  \
        tb/common/mock_uart.sv                              \
        src/util/sram.sv

ifdef spike-tandem
    util += tb/common/spike.sv
endif

util := $(addprefix $(root-dir), $(util))
# Test packages
test_pkg := $(wildcard tb/test/*/*sequence_pkg.sv*) \
			$(wildcard tb/test/*/*_pkg.sv*)
# DPI
dpi_list := $(patsubst tb/dpi/%.cc, ${dpi-library}/%.o, $(wildcard tb/dpi/*.cc))
# filter spike stuff if tandem is not activated
ifndef spike-tandem
    dpi = $(filter-out ${dpi-library}/spike.o ${dpi-library}/sim_spike.o, $(dpi_list))
else
    dpi = $(dpi_list)
endif

dpi_hdr := $(wildcard tb/dpi/*.h)
dpi_hdr := $(addprefix $(root-dir), $(dpi_hdr))
CFLAGS := -I$(QUESTASIM_HOME)/include         \
          -I$(RISCV)/include                  \
          $(if $(DROMAJO), -I../tb/dromajo/src,) \
          -std=c++11 -I../tb/dpi


ifdef spike-tandem
    CFLAGS += -Itb/riscv-isa-sim/install/include/spike
endif

# this list contains the standalone components
src :=  $(filter-out src/ariane_regfile.sv, $(wildcard src/*.sv))              \
        $(filter-out src/fpu/src/fpnew_pkg.sv, $(wildcard src/fpu/src/*.sv))   \
        $(filter-out src/fpu/src/fpu_div_sqrt_mvp/hdl/defs_div_sqrt_mvp.sv,    \
        $(wildcard src/fpu/src/fpu_div_sqrt_mvp/hdl/*.sv))                     \
        $(wildcard src/frontend/*.sv)                                          \
        $(filter-out src/cache_subsystem/std_no_dcache.sv,                     \
        $(wildcard src/cache_subsystem/*.sv))                                  \
        $(wildcard bootrom/*.sv)                                               \
        $(wildcard src/clint/*.sv)                                             \
        $(wildcard fpga/src/axi2apb/src/*.sv)                                  \
        $(wildcard fpga/src/apb_timer/*.sv)                                    \
        $(wildcard fpga/src/axi_slice/src/*.sv)                                \
        $(wildcard src/axi_node/src/*.sv)                                      \
        $(wildcard src/axi_riscv_atomics/src/*.sv)                             \
        $(wildcard src/axi_mem_if/src/*.sv)                                    \
        src/rv_plic/rtl/rv_plic_target.sv                                      \
        src/rv_plic/rtl/rv_plic_gateway.sv                                     \
        src/rv_plic/rtl/plic_regmap.sv                                         \
        src/rv_plic/rtl/plic_top.sv                                            \
        src/riscv-dbg/src/dmi_cdc.sv                                           \
        src/riscv-dbg/src/dmi_jtag.sv                                          \
        src/riscv-dbg/src/dmi_jtag_tap.sv                                      \
        src/riscv-dbg/src/dm_csrs.sv                                           \
        src/riscv-dbg/src/dm_mem.sv                                            \
        src/riscv-dbg/src/dm_sba.sv                                            \
        src/riscv-dbg/src/dm_top.sv                                            \
        src/riscv-dbg/debug_rom/debug_rom.sv                                   \
        src/register_interface/src/apb_to_reg.sv                               \
        src/axi/src/axi_multicut.sv                                            \
        src/common_cells/src/deprecated/generic_fifo.sv                        \
        src/common_cells/src/deprecated/pulp_sync.sv                           \
        src/common_cells/src/deprecated/find_first_one.sv                      \
        src/common_cells/src/rstgen_bypass.sv                                  \
        src/common_cells/src/rstgen.sv                                         \
        src/common_cells/src/stream_mux.sv                                     \
        src/common_cells/src/stream_demux.sv                                   \
	src/common_cells/src/exp_backoff.sv                                    \
        src/util/axi_master_connect.sv                                         \
        src/util/axi_slave_connect.sv                                          \
        src/util/axi_master_connect_rev.sv                                     \
        src/util/axi_slave_connect_rev.sv                                      \
        src/axi/src/axi_cut.sv                                                 \
        src/axi/src/axi_join.sv                                                \
        src/axi/src/axi_delayer.sv                                             \
        src/axi/src/axi_to_axi_lite.sv                                         \
        src/fpga-support/rtl/SyncSpRamBeNx64.sv                                \
        src/common_cells/src/unread.sv                                         \
        src/common_cells/src/sync.sv                                           \
        src/common_cells/src/cdc_2phase.sv                                     \
        src/common_cells/src/spill_register.sv                                 \
        src/common_cells/src/sync_wedge.sv                                     \
        src/common_cells/src/edge_detect.sv                                    \
        src/common_cells/src/stream_arbiter.sv                                 \
        src/common_cells/src/stream_arbiter_flushable.sv                       \
        src/common_cells/src/deprecated/fifo_v1.sv                             \
        src/common_cells/src/deprecated/fifo_v2.sv                             \
        src/common_cells/src/fifo_v3.sv                                        \
        src/common_cells/src/lzc.sv                                            \
        src/common_cells/src/popcount.sv                                       \
        src/common_cells/src/rr_arb_tree.sv                                    \
        src/common_cells/src/deprecated/rrarbiter.sv                           \
        src/common_cells/src/stream_delay.sv                                   \
        src/common_cells/src/lfsr_8bit.sv                                      \
        src/common_cells/src/lfsr_16bit.sv                                     \
        src/common_cells/src/counter.sv                                        \
        src/common_cells/src/shift_reg.sv                                      \
        src/tech_cells_generic/src/pulp_clock_gating.sv                        \
        src/tech_cells_generic/src/cluster_clock_inverter.sv                   \
        src/tech_cells_generic/src/pulp_clock_mux2.sv                          \
        tb/ariane_testharness.sv                                               \
        tb/ariane_peripherals.sv                                               \
        tb/common/uart.sv                                                      \
        tb/common/SimDTM.sv                                                    \
        tb/common/SimJTAG.sv

src := $(addprefix $(root-dir), $(src))

uart_src := $(wildcard fpga/src/apb_uart/src/*.vhd)
uart_src := $(addprefix $(root-dir), $(uart_src))

fpga_src :=  $(wildcard fpga/src/*.sv) $(wildcard fpga/src/bootrom/*.sv) $(wildcard fpga/src/ariane-ethernet/*.sv)
fpga_src := $(addprefix $(root-dir), $(fpga_src))

# look for testbenches
tbs := tb/ariane_tb.sv tb/ariane_testharness.sv
# RISCV asm tests and benchmark setup (used for CI)
# there is a definesd test-list with selected CI tests
riscv-test-dir            := tmp/riscv-tests/build/isa/
riscv-benchmarks-dir      := tmp/riscv-tests/build/benchmarks/
riscv-asm-tests-list      := ci/riscv-asm-tests.list
riscv-amo-tests-list      := ci/riscv-amo-tests.list
riscv-mul-tests-list      := ci/riscv-mul-tests.list
riscv-fp-tests-list       := ci/riscv-fp-tests.list
riscv-benchmarks-list     := ci/riscv-benchmarks.list
riscv-asm-tests           := $(shell xargs printf '\n%s' < $(riscv-asm-tests-list)  | cut -b 1-)
riscv-amo-tests           := $(shell xargs printf '\n%s' < $(riscv-amo-tests-list)  | cut -b 1-)
riscv-mul-tests           := $(shell xargs printf '\n%s' < $(riscv-mul-tests-list)  | cut -b 1-)
riscv-fp-tests            := $(shell xargs printf '\n%s' < $(riscv-fp-tests-list)   | cut -b 1-)
riscv-benchmarks          := $(shell xargs printf '\n%s' < $(riscv-benchmarks-list) | cut -b 1-)

# Search here for include files (e.g.: non-standalone components)
incdir := src/common_cells/include/
# Compile and sim flags
compile_flag     += +cover=bcfst+/dut -incr -64 -nologo -quiet -suppress 13262 -permissive +define+$(defines)
uvm-flags        += +UVM_NO_RELNOTES +UVM_VERBOSITY=LOW
questa-flags     += -t 1ns -64 -coverage -classdebug $(gui-sim) $(QUESTASIM_FLAGS)
compile_flag_vhd += -64 -nologo -quiet -2008

# Iterate over all include directories and write them with +incdir+ prefixed
# +incdir+ works for Verilator and QuestaSim
list_incdir := $(foreach dir, ${incdir}, +incdir+$(dir))

# RISCV torture setup
riscv-torture-dir    := tmp/riscv-torture
# old java flags  -Xmx1G -Xss8M -XX:MaxPermSize=128M
# -XshowSettings -Xdiag
riscv-torture-bin    := java -jar sbt-launch.jar

# if defined, calls the questa targets in batch mode
ifdef batch-mode
	questa-flags += -c
	questa-cmd   := -do "coverage save -onexit tmp/$@.ucdb; run -a; quit -code [coverage attribute -name TESTSTATUS -concise]"
	questa-cmd   += -do " log -r /*; run -all;"
else
	questa-cmd   := -do " log -r /*; run -all;"
endif
# we want to preload the memories
ifdef preload
	questa-cmd += +PRELOAD=$(preload)
	elf-bin = none
endif

ifdef spike-tandem
    questa-cmd += -gblso tb/riscv-isa-sim/install/lib/libriscv.so
endif

# remote bitbang is enabled
ifdef rbb
	questa-cmd += +jtag_rbb_enable=1
else
	questa-cmd += +jtag_rbb_enable=0
endif



fpga: $(ariane_pkg) $(util) $(src) $(fpga_src) $(uart_src)
	@echo "[FPGA] Generate sources"
	@echo read_vhdl        {$(uart_src)}    > fpga/scripts/add_sources.tcl
	@echo read_verilog -sv {$(ariane_pkg)} >> fpga/scripts/add_sources.tcl
	@echo read_verilog -sv {$(filter-out $(fpga_filter), $(util))}     >> fpga/scripts/add_sources.tcl
	@echo read_verilog -sv {$(filter-out $(fpga_filter), $(src))} 	   >> fpga/scripts/add_sources.tcl
	@echo read_verilog -sv {$(fpga_src)}   >> fpga/scripts/add_sources.tcl
	@echo "[FPGA] Generate Bitstream"
	cd fpga && make BOARD=$(BOARD) XILINX_PART=$(XILINX_PART) XILINX_BOARD=$(XILINX_BOARD) CLK_PERIOD_NS=$(CLK_PERIOD_NS)

.PHONY: fpga

build-spike:
	cd tb/riscv-isa-sim && mkdir -p build && cd build && ../configure --prefix=`pwd`/../install --with-fesvr=$(RISCV) --enable-commitlog && make -j8 install

clean:
	rm -rf $(riscv-torture-dir)/output/test*
	rm -rf $(library)/ $(dpi-library)/ $(ver-library)/
	rm -f tmp/*.ucdb tmp/*.log *.wlf *vstf wlft* *.ucdb

.PHONY:
	build sim sim-verilate clean                                              \
	$(riscv-asm-tests) $(addsuffix _verilator,$(riscv-asm-tests))             \
	$(riscv-benchmarks) $(addsuffix _verilator,$(riscv-benchmarks))           \
	check-benchmarks check-asm-tests                                          \
	torture-gen torture-itest torture-rtest                                   \
	run-torture run-torture-verilator check-torture check-torture-verilator
