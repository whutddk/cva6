// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Description: Xilinx FPGA top-level
// Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>

module ariane_xilinx (


  inout [14:0]DDR_addr,
  inout [2:0]DDR_ba,
  inout DDR_cas_n,
  inout DDR_ck_n,
  inout DDR_ck_p,
  inout DDR_cke,
  inout DDR_cs_n,
  inout [3:0]DDR_dm,
  inout [31:0]DDR_dq,
  inout [3:0]DDR_dqs_n,
  inout [3:0]DDR_dqs_p,
  inout DDR_odt,
  inout DDR_ras_n,
  inout DDR_reset_n,
  inout DDR_we_n,
  inout FIXED_IO_ddr_vrn,
  inout FIXED_IO_ddr_vrp,
  inout [53:0]FIXED_IO_mio,
  inout FIXED_IO_ps_clk,
  inout FIXED_IO_ps_porb,
  inout FIXED_IO_ps_srstb,



  input  logic         trst_n      ,


  input  logic        tck         ,
  input  logic        tms         ,
  input  logic        tdi         ,
  output wire         tdo         
);
// 24 MByte in 8 byte words
localparam NumWords = (24 * 1024 * 1024) / 8;
localparam NBSlave = 2; // debug, ariane
localparam AxiAddrWidth = 64;
localparam AxiDataWidth = 64;
localparam AxiIdWidthMaster = 4;
localparam AxiIdWidthSlaves = AxiIdWidthMaster + $clog2(NBSlave); // 5
localparam AxiUserWidth = 1;

AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthMaster ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
) slave[NBSlave-1:0]();

AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
) master[ariane_soc::NB_PERIPHERALS-1:0]();

// disable test-enable
logic test_en;
logic ndmreset;
logic ndmreset_n;
logic debug_req_irq;
logic timer_irq;
logic ipi;

logic sys_clk;




logic rst_n;



// Debug
logic          debug_req_valid;
logic          debug_req_ready;
dm::dmi_req_t  debug_req;
logic          debug_resp_valid;
logic          debug_resp_ready;
dm::dmi_resp_t debug_resp;

logic dmactive;

// IRQ
logic [1:0] irq;
assign test_en    = 1'b0;

logic [NBSlave-1:0] pc_asserted;

rstgen i_rstgen_main (
    .clk_i        ( sys_clk ),
    .rst_ni       (  (~ndmreset) ),
    .test_mode_i  ( test_en                  ),
    .rst_no       ( ndmreset_n               ),
    .init_no      (                          ) // keep open
);


// ---------------
// Debug Module
// ---------------
dmi_jtag i_dmi_jtag (
    .clk_i                ( sys_clk                  ),
    .rst_ni               ( rst_n                ),
    .dmi_rst_no           (                      ), // keep open
    .testmode_i           ( test_en              ),
    .dmi_req_valid_o      ( debug_req_valid      ),
    .dmi_req_ready_i      ( debug_req_ready      ),
    .dmi_req_o            ( debug_req            ),
    .dmi_resp_valid_i     ( debug_resp_valid     ),
    .dmi_resp_ready_o     ( debug_resp_ready     ),
    .dmi_resp_i           ( debug_resp           ),
    .tck_i                ( tck    ),
    .tms_i                ( tms    ),
    .trst_ni              ( trst_n ),
    .td_i                 ( tdi    ),
    .td_o                 ( tdo    ),
    .tdo_oe_o             (        )
);

ariane_axi::req_t    dm_axi_m_req;
ariane_axi::resp_t   dm_axi_m_resp;

logic                dm_slave_req;
logic                dm_slave_we;
logic [64-1:0]       dm_slave_addr;
logic [64/8-1:0]     dm_slave_be;
logic [64-1:0]       dm_slave_wdata;
logic [64-1:0]       dm_slave_rdata;

logic                dm_master_req;
logic [64-1:0]       dm_master_add;
logic                dm_master_we;
logic [64-1:0]       dm_master_wdata;
logic [64/8-1:0]     dm_master_be;
logic                dm_master_gnt;
logic                dm_master_r_valid;
logic [64-1:0]       dm_master_r_rdata;

// debug module
dm_top #(
    .NrHarts          ( 1                 ),
    .BusWidth         ( AxiDataWidth      ),
    .SelectableHarts  ( 1'b1              )
) i_dm_top (
    .clk_i            ( sys_clk               ),
    .rst_ni           ( rst_n             ), // PoR
    .testmode_i       ( test_en           ),
    .ndmreset_o       ( ndmreset          ),
    .dmactive_o       ( dmactive          ), // active debug session
    .debug_req_o      ( debug_req_irq     ),
    .unavailable_i    ( '0                ),
    .hartinfo_i       ( {ariane_pkg::DebugHartInfo} ),
    .slave_req_i      ( dm_slave_req      ),
    .slave_we_i       ( dm_slave_we       ),
    .slave_addr_i     ( dm_slave_addr     ),
    .slave_be_i       ( dm_slave_be       ),
    .slave_wdata_i    ( dm_slave_wdata    ),
    .slave_rdata_o    ( dm_slave_rdata    ),
    .master_req_o     ( dm_master_req     ),
    .master_add_o     ( dm_master_add     ),
    .master_we_o      ( dm_master_we      ),
    .master_wdata_o   ( dm_master_wdata   ),
    .master_be_o      ( dm_master_be      ),
    .master_gnt_i     ( dm_master_gnt     ),
    .master_r_valid_i ( dm_master_r_valid ),
    .master_r_rdata_i ( dm_master_r_rdata ),
    .dmi_rst_ni       ( rst_n             ),
    .dmi_req_valid_i  ( debug_req_valid   ),
    .dmi_req_ready_o  ( debug_req_ready   ),
    .dmi_req_i        ( debug_req         ),
    .dmi_resp_valid_o ( debug_resp_valid  ),
    .dmi_resp_ready_i ( debug_resp_ready  ),
    .dmi_resp_o       ( debug_resp        )
);

axi2mem #(
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves    ),
    .AXI_ADDR_WIDTH ( AxiAddrWidth        ),
    .AXI_DATA_WIDTH ( AxiDataWidth        ),
    .AXI_USER_WIDTH ( AxiUserWidth        )
) i_dm_axi2mem (
    .clk_i      ( sys_clk                       ),
    .rst_ni     ( rst_n                     ),
    .slave      ( master[ariane_soc::Debug] ),
    .req_o      ( dm_slave_req              ),
    .we_o       ( dm_slave_we               ),
    .addr_o     ( dm_slave_addr             ),
    .be_o       ( dm_slave_be               ),
    .data_o     ( dm_slave_wdata            ),
    .data_i     ( dm_slave_rdata            )
);

// axi_master_connect i_dm_axi_master_connect (
//   .axi_req_i(dm_axi_m_req),
//   .axi_resp_o(dm_axi_m_resp),
//   .master(slave[1])
// );

axi_adapter #(
    .DATA_WIDTH            ( AxiDataWidth              )
) i_dm_axi_master (
    .clk_i                 ( sys_clk                       ),
    .rst_ni                ( rst_n                     ),
    .req_i                 ( dm_master_req             ),
    .type_i                ( ariane_axi::SINGLE_REQ    ),
    .gnt_o                 ( dm_master_gnt             ),
    .gnt_id_o              (                           ),
    .addr_i                ( dm_master_add             ),
    .we_i                  ( dm_master_we              ),
    .wdata_i               ( dm_master_wdata           ),
    .be_i                  ( dm_master_be              ),
    .size_i                ( 2'b11                     ), // always do 64bit here and use byte enables to gate
    .id_i                  ( '0                        ),
    .valid_o               ( dm_master_r_valid         ),
    .rdata_o               ( dm_master_r_rdata         ),
    .id_o                  (                           ),
    .critical_word_o       (                           ),
    .critical_word_valid_o (                           ),
    .axi_req_o             ( dm_axi_m_req              ),
    .axi_resp_i            ( dm_axi_m_resp             )
);

// ---------------
// Core
// ---------------
ariane_axi::req_t    axi_ariane_req;
ariane_axi::resp_t   axi_ariane_resp;

ariane #(
    .ArianeCfg ( ariane_soc::ArianeSocCfg )
) i_ariane (
    .clk_i        ( sys_clk                 ),
    .rst_ni       ( ndmreset_n          ),
    .boot_addr_i  ( 64'hfc00_0000 ), // start fetching from ROM
    .hart_id_i    ( '0                  ),
    .irq_i        ( irq                 ),
    .ipi_i        ( ipi                 ),
    .time_irq_i   ( timer_irq           ),
    .debug_req_i  ( debug_req_irq       ),
    .axi_req_o    ( axi_ariane_req      ),
    .axi_resp_i   ( axi_ariane_resp     )
);

// axi_master_connect i_axi_master_connect_ariane (.axi_req_i(axi_ariane_req), .axi_resp_o(axi_ariane_resp), .master(slave[0]));

// ---------------
// CLINT
// ---------------

ariane_axi::req_t    axi_clint_req;
ariane_axi::resp_t   axi_clint_resp;

clint #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
    .NR_CORES       ( 1                )
) i_clint (
    .clk_i       ( sys_clk            ),
    .rst_ni      ( ndmreset_n     ),
    .testmode_i  ( test_en        ),
    .axi_req_i   ( axi_clint_req  ),
    .axi_resp_o  ( axi_clint_resp ),
    .rtc_i       ( sys_clk  ),
    .timer_irq_o ( timer_irq      ),
    .ipi_o       ( ipi            )
);

// axi_slave_connect i_axi_slave_connect_clint (.axi_req_o(axi_clint_req), .axi_resp_i(axi_clint_resp), .slave(master[ariane_soc::CLINT]));




AXI_BUS #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
) dram();

axi_riscv_atomics_wrap #(
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
    .AXI_USER_WIDTH ( AxiUserWidth     ),
    .AXI_MAX_WRITE_TXNS ( 1  ),
    .RISCV_WORD_WIDTH   ( 64 )
) i_axi_riscv_atomics (
    .clk_i  ( sys_clk                      ),
    .rst_ni ( ndmreset_n               ),
    .slv    ( master[ariane_soc::DRAM] ),
    .mst    ( dram                     )
);



ariane_axi::req_t    axi_zynq_req;
ariane_axi::resp_t   axi_zynq_resp;

// axi_slave_connect i_axi_slave_connect_zynq (.axi_req_o(axi_zynq_req), .axi_resp_i(axi_zynq_resp), .slave(master[ariane_soc::ZYNQ]));



xilinx_ariane_wrapper i_xilinx_ariane_wrapper
(   
    .DDR_addr(DDR_addr),
    .DDR_ba(DDR_ba),
    .DDR_cas_n(DDR_cas_n),
    .DDR_ck_n(DDR_ck_n),
    .DDR_ck_p(DDR_ck_p),
    .DDR_cke(DDR_cke),
    .DDR_cs_n(DDR_cs_n),
    .DDR_dm(DDR_dm),
    .DDR_dq(DDR_dq),
    .DDR_dqs_n(DDR_dqs_n),
    .DDR_dqs_p(DDR_dqs_p),
    .DDR_odt(DDR_odt),
    .DDR_ras_n(DDR_ras_n),
    .DDR_reset_n(DDR_reset_n),
    .DDR_we_n(DDR_we_n),

    .peripheral_aresetn(rst_n),
    .FCLK_CLK0(sys_clk),

    .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
    .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
    .FIXED_IO_mio(FIXED_IO_mio),
    .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
    .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
    .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),


    .S_AXI_GP0_araddr(axi_zynq_req.ar.addr),
    .S_AXI_GP0_arburst(axi_zynq_req.ar.burst),
    .S_AXI_GP0_arcache(axi_zynq_req.ar.cache),
    .S_AXI_GP0_arid(axi_zynq_req.ar.id),
    .S_AXI_GP0_arlen(axi_zynq_req.ar.len),
    .S_AXI_GP0_arlock(axi_zynq_req.ar.lock),
    .S_AXI_GP0_arprot(axi_zynq_req.ar.prot),
    .S_AXI_GP0_arqos(axi_zynq_req.ar.qos),
    .S_AXI_GP0_arready(axi_zynq_resp.ar_ready),
    .S_AXI_GP0_arsize(axi_zynq_req.ar.size),
    .S_AXI_GP0_arvalid(axi_zynq_req.ar_valid),

    .S_AXI_GP0_awaddr(axi_zynq_req.aw.addr),
    .S_AXI_GP0_awburst(axi_zynq_req.aw.burst),
    .S_AXI_GP0_awcache(axi_zynq_req.aw.cache),
    .S_AXI_GP0_awid(axi_zynq_req.aw.id),
    .S_AXI_GP0_awlen(axi_zynq_req.aw.len),
    .S_AXI_GP0_awlock(axi_zynq_req.aw.lock),
    .S_AXI_GP0_awprot(axi_zynq_req.aw.prot),
    .S_AXI_GP0_awqos(axi_zynq_req.aw.qos),
    .S_AXI_GP0_awready(axi_zynq_resp.aw_ready),
    .S_AXI_GP0_awsize(axi_zynq_req.aw.size),
    .S_AXI_GP0_awvalid(axi_zynq_req.aw_valid),

    .S_AXI_GP0_bid(axi_zynq_resp.b.id),
    .S_AXI_GP0_bready(axi_zynq_req.b_ready),
    .S_AXI_GP0_bresp(axi_zynq_resp.b.resp),
    .S_AXI_GP0_bvalid(axi_zynq_resp.b_valid),

    .S_AXI_GP0_rdata(axi_zynq_resp.r.data),
    .S_AXI_GP0_rid(axi_zynq_resp.r.id),
    .S_AXI_GP0_rlast(axi_zynq_resp.r.last),
    .S_AXI_GP0_rready(axi_zynq_req.r_ready),
    .S_AXI_GP0_rresp(axi_zynq_resp.r.resp),
    .S_AXI_GP0_rvalid(axi_zynq_resp.r_valid),

    .S_AXI_GP0_wdata(axi_zynq_req.w.data),
    .S_AXI_GP0_wid(),
    .S_AXI_GP0_wlast(axi_zynq_req.w.last),
    .S_AXI_GP0_wready(axi_zynq_resp.w_ready),
    .S_AXI_GP0_wstrb(axi_zynq_req.w.strb),
    .S_AXI_GP0_wvalid(axi_zynq_req.w_valid),



    .S_AXI_HP0_araddr(dram.ar_addr),
    .S_AXI_HP0_arburst(dram.ar_burst),
    .S_AXI_HP0_arcache(dram.ar_cache),
    .S_AXI_HP0_arid(dram.ar_id),
    .S_AXI_HP0_arlen(dram.ar_len),
    .S_AXI_HP0_arlock(dram.ar_lock),
    .S_AXI_HP0_arprot(dram.ar_prot),
    .S_AXI_HP0_arqos(dram.ar_qos),
    .S_AXI_HP0_arready(dram.ar_ready),
    .S_AXI_HP0_arsize(dram.ar_size),
    .S_AXI_HP0_arvalid(dram.ar_valid),

    .S_AXI_HP0_awaddr(dram.aw_addr),
    .S_AXI_HP0_awburst(dram.aw_burst),
    .S_AXI_HP0_awcache(dram.aw_cache),
    .S_AXI_HP0_awid(dram.aw_id),
    .S_AXI_HP0_awlen(dram.aw_len),
    .S_AXI_HP0_awlock(dram.aw_lock),
    .S_AXI_HP0_awprot(dram.aw_prot),
    .S_AXI_HP0_awqos(dram.aw_qos),
    .S_AXI_HP0_awready(dram.aw_ready),
    .S_AXI_HP0_awsize(dram.aw_size),
    .S_AXI_HP0_awvalid(dram.aw_valid),

    .S_AXI_HP0_bid(dram.b_id),
    .S_AXI_HP0_bready(dram.b_ready),
    .S_AXI_HP0_bresp(dram.b_resp),
    .S_AXI_HP0_bvalid(dram.b_valid),

    .S_AXI_HP0_rdata(dram.r_data),
    .S_AXI_HP0_rid(dram.r_id),
    .S_AXI_HP0_rlast(dram.r_last),
    .S_AXI_HP0_rready(dram.r_ready),
    .S_AXI_HP0_rresp(dram.r_resp),
    .S_AXI_HP0_rvalid(dram.r_valid),

    .S_AXI_HP0_wdata(dram.w_data),
    .S_AXI_HP0_wid(),
    .S_AXI_HP0_wlast(dram.w_last),
    .S_AXI_HP0_wready(dram.w_ready),
    .S_AXI_HP0_wstrb(dram.w_strb),
    .S_AXI_HP0_wvalid(dram.w_valid)


  );









































// ariane_axi::req_t    axi_clint_req;
// ariane_axi::resp_t   axi_clint_resp;

ariane_axi::req_t    axi_dram_req;
ariane_axi::resp_t   axi_dram_resp;

ariane_axi::req_t    axi_debug_req;
ariane_axi::resp_t   axi_debug_resp;
// axi_slave_connect i_axi_slave_connect_clint (.axi_req_o(axi_clint_req), .axi_resp_i(axi_clint_resp), .slave(master[ariane_soc::CLINT]));
axi_master_connect i_axi_master_connect_dram (.axi_req_i(axi_dram_req), .axi_resp_o(axi_dram_resp), .master(master[ariane_soc::DRAM]));
axi_master_connect i_axi_master_connect_debug (.axi_req_i(axi_debug_req), .axi_resp_o(axi_debug_resp), .master(master[ariane_soc::Debug]));



axi_crossbar i_axi_crossbar
(
  .aclk(sys_clk),
  .aresetn(ndmreset_n),


  .s_axi_awid   ( { dm_axi_m_req.aw.id,     axi_ariane_req.aw.id }),
  .s_axi_awaddr ( { dm_axi_m_req.aw.addr,   axi_ariane_req.aw.addr }),
  .s_axi_awlen  ( { dm_axi_m_req.aw.len,    axi_ariane_req.aw.len }),
  .s_axi_awsize ( { dm_axi_m_req.aw.size,   axi_ariane_req.aw.size }),
  .s_axi_awburst( { dm_axi_m_req.aw.burst,  axi_ariane_req.aw.burst }),
  .s_axi_awlock ( { dm_axi_m_req.aw.lock,   axi_ariane_req.aw.lock }),
  .s_axi_awcache( { dm_axi_m_req.aw.cache,  axi_ariane_req.aw.cache }),
  .s_axi_awprot ( { dm_axi_m_req.aw.prot,   axi_ariane_req.aw.prot }),
  .s_axi_awqos  ( { dm_axi_m_req.aw.qos,    axi_ariane_req.aw.qos }),
  .s_axi_awvalid( { dm_axi_m_req.aw_valid,  axi_ariane_req.aw_valid }),
  .s_axi_awready( { dm_axi_m_resp.aw_ready, axi_ariane_resp.aw_ready }),
  .s_axi_wdata  ( { dm_axi_m_req.w.data,    axi_ariane_req.w.data }),
  .s_axi_wstrb  ( { dm_axi_m_req.w.strb,    axi_ariane_req.w.strb }),
  .s_axi_wlast  ( { dm_axi_m_req.w.last,    axi_ariane_req.w.last }),
  .s_axi_wvalid ( { dm_axi_m_req.w_valid,   axi_ariane_req.w_valid }),
  .s_axi_wready ( { dm_axi_m_resp.w_ready,  axi_ariane_resp.w_ready }),
  .s_axi_bid    ( { dm_axi_m_resp.b.id,     axi_ariane_resp.b.id }),
  .s_axi_bresp  ( { dm_axi_m_resp.b.resp,   axi_ariane_resp.b.resp }),
  .s_axi_bvalid ( { dm_axi_m_resp.b_valid,  axi_ariane_resp.b_valid }),
  .s_axi_bready ( { dm_axi_m_req.b_ready,   axi_ariane_req.b_ready }),
  .s_axi_arid   ( { dm_axi_m_req.ar.id,     axi_ariane_req.ar.id }),
  .s_axi_araddr ( { dm_axi_m_req.ar.addr,   axi_ariane_req.ar.addr }),
  .s_axi_arlen  ( { dm_axi_m_req.ar.len,    axi_ariane_req.ar.len }),
  .s_axi_arsize ( { dm_axi_m_req.ar.size,   axi_ariane_req.ar.size }),
  .s_axi_arburst( { dm_axi_m_req.ar.burst,  axi_ariane_req.ar.burst }),
  .s_axi_arlock ( { dm_axi_m_req.ar.lock,   axi_ariane_req.ar.lock }),
  .s_axi_arcache( { dm_axi_m_req.ar.cache,  axi_ariane_req.ar.cache }),
  .s_axi_arprot ( { dm_axi_m_req.ar.prot,   axi_ariane_req.ar.prot }),
  .s_axi_arqos  ( { dm_axi_m_req.ar.qos,    axi_ariane_req.ar.qos }),
  .s_axi_arvalid( { dm_axi_m_req.ar_valid,  axi_ariane_req.ar_valid }),
  .s_axi_arready( { dm_axi_m_resp.ar_ready, axi_ariane_resp.ar_ready }),
  .s_axi_rid    ( { dm_axi_m_resp.r.id,     axi_ariane_resp.r.id }),
  .s_axi_rdata  ( { dm_axi_m_resp.r.data,   axi_ariane_resp.r.data }),
  .s_axi_rresp  ( { dm_axi_m_resp.r.resp,   axi_ariane_resp.r.resp }),
  .s_axi_rlast  ( { dm_axi_m_resp.r.last,   axi_ariane_resp.r.last }),
  .s_axi_rvalid ( { dm_axi_m_resp.r_valid,  axi_ariane_resp.r_valid }),
  .s_axi_rready ( { dm_axi_m_req.r_ready,   axi_ariane_req.r_ready }),








  .m_axi_arregion (),
  .m_axi_awregion (),
  .m_axi_awid   ( { axi_debug_req.aw.id,     axi_clint_req.aw.id,     axi_zynq_req.aw.id,     axi_dram_req.aw.id} ),
  .m_axi_awaddr ( { axi_debug_req.aw.addr,   axi_clint_req.aw.addr,   axi_zynq_req.aw.addr,   axi_dram_req.aw.addr} ),
  .m_axi_awlen  ( { axi_debug_req.aw.len,    axi_clint_req.aw.len,    axi_zynq_req.aw.len,    axi_dram_req.aw.len} ),
  .m_axi_awsize ( { axi_debug_req.aw.size,   axi_clint_req.aw.size,   axi_zynq_req.aw.size,   axi_dram_req.aw.size} ),
  .m_axi_awburst( { axi_debug_req.aw.burst,  axi_clint_req.aw.burst,  axi_zynq_req.aw.burst,  axi_dram_req.aw.burst} ),
  .m_axi_awlock ( { axi_debug_req.aw.lock,   axi_clint_req.aw.lock,   axi_zynq_req.aw.lock,   axi_dram_req.aw.lock} ),
  .m_axi_awcache( { axi_debug_req.aw.cache,  axi_clint_req.aw.cache,  axi_zynq_req.aw.cache,  axi_dram_req.aw.cache} ),
  .m_axi_awprot ( { axi_debug_req.aw.prot,   axi_clint_req.aw.prot,   axi_zynq_req.aw.prot,   axi_dram_req.aw.prot} ),
  .m_axi_awqos  ( { axi_debug_req.aw.qos,    axi_clint_req.aw.qos,    axi_zynq_req.aw.qos,    axi_dram_req.aw.qos} ),
  .m_axi_awvalid( { axi_debug_req.aw_valid,  axi_clint_req.aw_valid,  axi_zynq_req.aw_valid,  axi_dram_req.aw_valid} ),
  .m_axi_awready( { axi_debug_resp.aw_ready, axi_clint_resp.aw_ready, axi_zynq_resp.aw_ready, axi_dram_resp.aw_ready} ),
  .m_axi_wdata  ( { axi_debug_req.w.data,    axi_clint_req.w.data,    axi_zynq_req.w.data,    axi_dram_req.w.data} ),
  .m_axi_wstrb  ( { axi_debug_req.w.strb,    axi_clint_req.w.strb,    axi_zynq_req.w.strb,    axi_dram_req.w.strb} ),
  .m_axi_wlast  ( { axi_debug_req.w.last,    axi_clint_req.w.last,    axi_zynq_req.w.last,    axi_dram_req.w.last} ),
  .m_axi_wvalid ( { axi_debug_req.w_valid,   axi_clint_req.w_valid,   axi_zynq_req.w_valid,   axi_dram_req.w_valid} ),
  .m_axi_wready ( { axi_debug_resp.w_ready,  axi_clint_resp.w_ready,  axi_zynq_resp.w_ready,  axi_dram_resp.w_ready} ),
  .m_axi_bid    ( { axi_debug_resp.b.id,     axi_clint_resp.b.id,     axi_zynq_resp.b.id,     axi_dram_resp.b.id} ),
  .m_axi_bresp  ( { axi_debug_resp.b.resp,   axi_clint_resp.b.resp,   axi_zynq_resp.b.resp,   axi_dram_resp.b.resp} ),
  .m_axi_bvalid ( { axi_debug_resp.b_valid,  axi_clint_resp.b_valid,  axi_zynq_resp.b_valid,  axi_dram_resp.b_valid} ),
  .m_axi_bready ( { axi_debug_req.b_ready,   axi_clint_req.b_ready,   axi_zynq_req.b_ready,   axi_dram_req.b_ready} ),
  .m_axi_arid   ( { axi_debug_req.ar.id,     axi_clint_req.ar.id,     axi_zynq_req.ar.id,     axi_dram_req.ar.id} ),
  .m_axi_araddr ( { axi_debug_req.ar.addr,   axi_clint_req.ar.addr,   axi_zynq_req.ar.addr,   axi_dram_req.ar.addr} ),
  .m_axi_arlen  ( { axi_debug_req.ar.len,    axi_clint_req.ar.len,    axi_zynq_req.ar.len,    axi_dram_req.ar.len} ),
  .m_axi_arsize ( { axi_debug_req.ar.size,   axi_clint_req.ar.size,   axi_zynq_req.ar.size,   axi_dram_req.ar.size} ),
  .m_axi_arburst( { axi_debug_req.ar.burst,  axi_clint_req.ar.burst,  axi_zynq_req.ar.burst,  axi_dram_req.ar.burst} ),
  .m_axi_arlock ( { axi_debug_req.ar.lock,   axi_clint_req.ar.lock,   axi_zynq_req.ar.lock,   axi_dram_req.ar.lock} ),
  .m_axi_arcache( { axi_debug_req.ar.cache,  axi_clint_req.ar.cache,  axi_zynq_req.ar.cache,  axi_dram_req.ar.cache} ),
  .m_axi_arprot ( { axi_debug_req.ar.prot,   axi_clint_req.ar.prot,   axi_zynq_req.ar.prot,   axi_dram_req.ar.prot} ),
  .m_axi_arqos  ( { axi_debug_req.ar.qos,    axi_clint_req.ar.qos,    axi_zynq_req.ar.qos,    axi_dram_req.ar.qos} ),
  .m_axi_arvalid( { axi_debug_req.ar_valid,  axi_clint_req.ar_valid,  axi_zynq_req.ar_valid,  axi_dram_req.ar_valid} ),
  .m_axi_arready( { axi_debug_resp.ar_ready, axi_clint_resp.ar_ready, axi_zynq_resp.ar_ready, axi_dram_resp.ar_ready} ),
  .m_axi_rid    ( { axi_debug_resp.r.id,     axi_clint_resp.r.id,     axi_zynq_resp.r.id,     axi_dram_resp.r.id} ),
  .m_axi_rdata  ( { axi_debug_resp.r.data,   axi_clint_resp.r.data,   axi_zynq_resp.r.data,   axi_dram_resp.r.data} ),
  .m_axi_rresp  ( { axi_debug_resp.r.resp,   axi_clint_resp.r.resp,   axi_zynq_resp.r.resp,   axi_dram_resp.r.resp} ),
  .m_axi_rlast  ( { axi_debug_resp.r.last,   axi_clint_resp.r.last,   axi_zynq_resp.r.last,   axi_dram_resp.r.last} ),
  .m_axi_rvalid ( { axi_debug_resp.r_valid,  axi_clint_resp.r_valid,  axi_zynq_resp.r_valid,  axi_dram_resp.r_valid} ),
  .m_axi_rready ( { axi_debug_req.r_ready,   axi_clint_req.r_ready,   axi_zynq_req.r_ready,   axi_dram_req.r_ready} )
);










endmodule
