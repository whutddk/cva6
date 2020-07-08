read_vhdl {
		~/ariane/fpga/src/apb_uart/src/apb_uart.vhd
		~/ariane/fpga/src/apb_uart/src/uart_transmitter.vhd
		~/ariane/fpga/src/apb_uart/src/uart_interrupt.vhd
		~/ariane/fpga/src/apb_uart/src/slib_mv_filter.vhd
		~/ariane/fpga/src/apb_uart/src/slib_input_filter.vhd
		~/ariane/fpga/src/apb_uart/src/slib_counter.vhd
		~/ariane/fpga/src/apb_uart/src/uart_receiver.vhd
		~/ariane/fpga/src/apb_uart/src/slib_edge_detect.vhd
		~/ariane/fpga/src/apb_uart/src/slib_input_sync.vhd
		~/ariane/fpga/src/apb_uart/src/slib_clock_div.vhd
		~/ariane/fpga/src/apb_uart/src/slib_fifo.vhd
		~/ariane/fpga/src/apb_uart/src/uart_baudgen.vhd
}

read_verilog -sv {

		~/ariane/src/riscv-dbg/src/dm_pkg.sv
		~/ariane/src/axi/src/axi_pkg.sv
		~/ariane/src/register_interface/src/reg_intf.sv
		~/ariane/src/register_interface/src/reg_intf_pkg.sv
		~/ariane/src/fpu/src/fpnew_pkg.sv
		~/ariane/src/fpu/src/fpu_div_sqrt_mvp/hdl/defs_div_sqrt_mvp.sv


		~/ariane/include/riscv_pkg.sv
		~/ariane/include/axi_intf.sv
		~/ariane/include/ariane_pkg.sv
		~/ariane/include/std_cache_pkg.sv
		~/ariane/include/wt_cache_pkg.sv
		~/ariane/include/ariane_axi_pkg.sv

		~/ariane/tb/ariane_soc_pkg.sv


}

read_verilog -sv {
		~/ariane/src/tech_cells_generic/src/cluster_clock_gating.sv
		~/ariane/tb/common/mock_uart.sv
		~/ariane/src/util/sram.sv
}




read_verilog -sv {
		~/ariane/src/serdiv.sv
		~/ariane/src/ariane_regfile_ff.sv
		~/ariane/src/amo_buffer.sv
		~/ariane/src/ptw.sv
		~/ariane/src/branch_unit.sv
		~/ariane/src/mmu.sv
		~/ariane/src/controller.sv
		~/ariane/src/issue_stage.sv
		~/ariane/src/re_name.sv
		~/ariane/src/csr_buffer.sv
		~/ariane/src/tlb.sv
		~/ariane/src/decoder.sv
		~/ariane/src/scoreboard.sv
		~/ariane/src/perf_counters.sv
		~/ariane/src/store_unit.sv
		~/ariane/src/ariane.sv
		~/ariane/src/axi_adapter.sv
		~/ariane/src/fpu_wrap.sv
		~/ariane/src/csr_regfile.sv
		~/ariane/src/load_store_unit.sv
		~/ariane/src/commit_stage.sv
		~/ariane/src/multiplier.sv
		~/ariane/src/store_buffer.sv
		~/ariane/src/compressed_decoder.sv
		~/ariane/src/axi_shim.sv
		~/ariane/src/alu.sv
		~/ariane/src/instr_realign.sv
		~/ariane/src/ex_stage.sv
		~/ariane/src/id_stage.sv
		~/ariane/src/mult.sv
		~/ariane/src/load_unit.sv
		~/ariane/src/issue_read_operands.sv
		~/ariane/src/fpu/src/fpnew_fma.sv
		~/ariane/src/fpu/src/fpnew_opgroup_fmt_slice.sv
		~/ariane/src/fpu/src/fpnew_divsqrt_multi.sv
		~/ariane/src/fpu/src/fpnew_fma_multi.sv
		~/ariane/src/fpu/src/fpnew_opgroup_multifmt_slice.sv
		~/ariane/src/fpu/src/fpnew_classifier.sv
		~/ariane/src/fpu/src/fpnew_top.sv
		~/ariane/src/fpu/src/fpnew_noncomp.sv
		~/ariane/src/fpu/src/fpnew_cast_multi.sv
		~/ariane/src/fpu/src/fpnew_opgroup_block.sv
		~/ariane/src/fpu/src/fpnew_rounding.sv
		~/ariane/src/fpu/src/fpu_div_sqrt_mvp/hdl/iteration_div_sqrt_mvp.sv
		~/ariane/src/fpu/src/fpu_div_sqrt_mvp/hdl/nrbd_nrsc_mvp.sv
		~/ariane/src/fpu/src/fpu_div_sqrt_mvp/hdl/div_sqrt_top_mvp.sv 
		~/ariane/src/fpu/src/fpu_div_sqrt_mvp/hdl/preprocess_mvp.sv 
		~/ariane/src/fpu/src/fpu_div_sqrt_mvp/hdl/control_mvp.sv 
		~/ariane/src/fpu/src/fpu_div_sqrt_mvp/hdl/norm_div_sqrt_mvp.sv 
		~/ariane/src/fpu/src/fpu_div_sqrt_mvp/hdl/div_sqrt_mvp_wrapper.sv
		~/ariane/src/frontend/frontend.sv
		~/ariane/src/frontend/instr_scan.sv
		~/ariane/src/frontend/instr_queue.sv
		~/ariane/src/frontend/bht.sv
		~/ariane/src/frontend/btb.sv
		~/ariane/src/frontend/ras.sv
		~/ariane/src/cache_subsystem/wt_dcache.sv 
		~/ariane/src/cache_subsystem/tag_cmp.sv 
		~/ariane/src/cache_subsystem/wt_dcache_ctrl.sv
		~/ariane/src/cache_subsystem/amo_alu.sv
		~/ariane/src/cache_subsystem/wt_axi_adapter.sv
		~/ariane/src/cache_subsystem/std_nbdcache.sv
		~/ariane/src/cache_subsystem/cache_ctrl.sv
		~/ariane/src/cache_subsystem/miss_handler.sv
		~/ariane/src/cache_subsystem/std_cache_subsystem.sv
		~/ariane/src/cache_subsystem/wt_dcache_missunit.sv
		~/ariane/src/cache_subsystem/std_icache.sv
		~/ariane/src/cache_subsystem/wt_icache.sv
		~/ariane/src/cache_subsystem/wt_dcache_wbuffer.sv 
		~/ariane/src/cache_subsystem/wt_l15_adapter.sv 
		~/ariane/src/cache_subsystem/wt_dcache_mem.sv 
		~/ariane/src/cache_subsystem/wt_cache_subsystem.sv 
		~/ariane/src/clint/axi_lite_interface.sv 
		~/ariane/src/clint/clint.sv 
		~/ariane/fpga/src/axi2apb/src/axi2apb_wrap.sv 
		~/ariane/fpga/src/axi2apb/src/axi2apb.sv 
		~/ariane/fpga/src/axi2apb/src/axi2apb_64_32.sv 
		~/ariane/fpga/src/apb_timer/apb_timer.sv 
		~/ariane/fpga/src/apb_timer/timer.sv 
		~/ariane/fpga/src/axi_slice/src/axi_w_buffer.sv 
		~/ariane/fpga/src/axi_slice/src/axi_r_buffer.sv
		~/ariane/fpga/src/axi_slice/src/axi_slice_wrap.sv 
		~/ariane/fpga/src/axi_slice/src/axi_slice.sv 
		~/ariane/fpga/src/axi_slice/src/axi_single_slice.sv 
		~/ariane/fpga/src/axi_slice/src/axi_ar_buffer.sv 
		~/ariane/fpga/src/axi_slice/src/axi_b_buffer.sv
		~/ariane/fpga/src/axi_slice/src/axi_aw_buffer.sv 
		~/ariane/src/axi_node/src/axi_regs_top.sv 
		~/ariane/src/axi_node/src/axi_BR_allocator.sv 
		~/ariane/src/axi_node/src/axi_BW_allocator.sv 
		~/ariane/src/axi_node/src/axi_address_decoder_BR.sv 
		~/ariane/src/axi_node/src/axi_DW_allocator.sv 
		~/ariane/src/axi_node/src/axi_address_decoder_BW.sv 
		~/ariane/src/axi_node/src/axi_address_decoder_DW.sv 
		~/ariane/src/axi_node/src/axi_node_arbiter.sv 
		~/ariane/src/axi_node/src/axi_response_block.sv 
		~/ariane/src/axi_node/src/axi_request_block.sv 
		~/ariane/src/axi_node/src/axi_AR_allocator.sv 
		~/ariane/src/axi_node/src/axi_AW_allocator.sv 
		~/ariane/src/axi_node/src/axi_address_decoder_AR.sv 
		~/ariane/src/axi_node/src/axi_address_decoder_AW.sv 
		~/ariane/src/axi_node/src/apb_regs_top.sv
		~/ariane/src/axi_node/src/axi_node_intf_wrap.sv 
		~/ariane/src/axi_node/src/axi_node.sv 
		~/ariane/src/axi_node/src/axi_node_wrap_with_slices.sv 
		~/ariane/src/axi_node/src/axi_multiplexer.sv 
~/ariane/src/axi_riscv_atomics/src/axi_riscv_amos.sv 
~/ariane/src/axi_riscv_atomics/src/axi_riscv_atomics.sv 
~/ariane/src/axi_riscv_atomics/src/axi_res_tbl.sv 
~/ariane/src/axi_riscv_atomics/src/axi_riscv_lrsc_wrap.sv 
~/ariane/src/axi_riscv_atomics/src/axi_riscv_amos_alu.sv 
~/ariane/src/axi_riscv_atomics/src/axi_riscv_lrsc.sv
~/ariane/src/axi_riscv_atomics/src/axi_riscv_atomics_wrap.sv 
~/ariane/src/axi_mem_if/src/axi2mem.sv 
~/ariane/src/rv_plic/rtl/rv_plic_target.sv 
~/ariane/src/rv_plic/rtl/rv_plic_gateway.sv 
~/ariane/src/rv_plic/rtl/plic_regmap.sv 
~/ariane/src/rv_plic/rtl/plic_top.sv 
		~/ariane/src/riscv-dbg/src/dmi_cdc.sv 
		~/ariane/src/riscv-dbg/src/dmi_jtag.sv 
		~/ariane/src/riscv-dbg/src/dmi_jtag_tap.sv 
		~/ariane/src/riscv-dbg/src/dm_csrs.sv 
		~/ariane/src/riscv-dbg/src/dm_mem.sv 
		~/ariane/src/riscv-dbg/src/dm_sba.sv 
		~/ariane/src/riscv-dbg/src/dm_top.sv 
		~/ariane/src/riscv-dbg/debug_rom/debug_rom.sv 
		~/ariane/src/register_interface/src/apb_to_reg.sv 
~/ariane/src/axi/src/axi_multicut.sv 
~/ariane/src/common_cells/src/deprecated/generic_fifo.sv
~/ariane/src/common_cells/src/deprecated/pulp_sync.sv 
~/ariane/src/common_cells/src/deprecated/find_first_one.sv 
~/ariane/src/common_cells/src/rstgen_bypass.sv 
~/ariane/src/common_cells/src/rstgen.sv 
~/ariane/src/common_cells/src/stream_mux.sv 
~/ariane/src/common_cells/src/stream_demux.sv 
~/ariane/src/common_cells/src/exp_backoff.sv 
		~/ariane/src/util/axi_master_connect.sv 
		~/ariane/src/util/axi_slave_connect.sv 
		~/ariane/src/util/axi_master_connect_rev.sv 
		~/ariane/src/util/axi_slave_connect_rev.sv
		~/ariane/src/axi/src/axi_cut.sv 
		~/ariane/src/axi/src/axi_join.sv 
		~/ariane/src/axi/src/axi_delayer.sv 
		~/ariane/src/axi/src/axi_to_axi_lite.sv 
~/ariane/src/fpga-support/rtl/SyncSpRamBeNx64.sv 
~/ariane/src/common_cells/src/unread.sv 
~/ariane/src/common_cells/src/sync.sv 
~/ariane/src/common_cells/src/cdc_2phase.sv 
~/ariane/src/common_cells/src/spill_register.sv 
~/ariane/src/common_cells/src/sync_wedge.sv 
~/ariane/src/common_cells/src/edge_detect.sv 
~/ariane/src/common_cells/src/stream_arbiter.sv 
~/ariane/src/common_cells/src/stream_arbiter_flushable.sv 
~/ariane/src/common_cells/src/deprecated/fifo_v1.sv 
~/ariane/src/common_cells/src/deprecated/fifo_v2.sv 
~/ariane/src/common_cells/src/fifo_v3.sv 
~/ariane/src/common_cells/src/lzc.sv 
~/ariane/src/common_cells/src/popcount.sv 
~/ariane/src/common_cells/src/rr_arb_tree.sv 
~/ariane/src/common_cells/src/deprecated/rrarbiter.sv 
~/ariane/src/common_cells/src/stream_delay.sv 
~/ariane/src/common_cells/src/lfsr_8bit.sv 
~/ariane/src/common_cells/src/lfsr_16bit.sv 
~/ariane/src/common_cells/src/counter.sv 
~/ariane/src/common_cells/src/shift_reg.sv 
		~/ariane/src/tech_cells_generic/src/pulp_clock_gating.sv 
		~/ariane/src/tech_cells_generic/src/cluster_clock_inverter.sv 
		~/ariane/src/tech_cells_generic/src/pulp_clock_mux2.sv 
		~/ariane/tb/ariane_testharness.sv 
		~/ariane/tb/ariane_peripherals.sv 
		~/ariane/tb/common/uart.sv 
		~/ariane/tb/common/SimDTM.sv 
		~/ariane/tb/common/SimJTAG.sv
}

read_verilog -sv {
		~/ariane/fpga/src/ariane_peripherals_xilinx.sv 
		~/ariane/fpga/src/fan_ctrl.sv 
		~/ariane/fpga/src/ariane_xilinx.sv 
		~/ariane/fpga/src/bootrom/bootrom.sv 
		~/ariane/fpga/src/ariane-ethernet/ssio_ddr_in.sv 
		~/ariane/fpga/src/ariane-ethernet/eth_mac_1g_rgmii.sv 
		~/ariane/fpga/src/ariane-ethernet/axis_gmii_rx.sv 
		~/ariane/fpga/src/ariane-ethernet/oddr.sv 
		~/ariane/fpga/src/ariane-ethernet/axis_gmii_tx.sv 
		~/ariane/fpga/src/ariane-ethernet/dualmem_widen8.sv 
		~/ariane/fpga/src/ariane-ethernet/rgmii_phy_if.sv 
		~/ariane/fpga/src/ariane-ethernet/eth_mac_1g.sv 
		~/ariane/fpga/src/ariane-ethernet/dualmem_widen.sv 
		~/ariane/fpga/src/ariane-ethernet/rgmii_lfsr.sv 
		~/ariane/fpga/src/ariane-ethernet/rgmii_core.sv 
		~/ariane/fpga/src/ariane-ethernet/rgmii_soc.sv 
		~/ariane/fpga/src/ariane-ethernet/eth_mac_1g_rgmii_fifo.sv 
		~/ariane/fpga/src/ariane-ethernet/iddr.sv 
		~/ariane/fpga/src/ariane-ethernet/framing_top.sv
}
