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
logic time_irq;
logic ipi;

logic sys_clk;



// logic ddr_sync_reset;
// logic ddr_clock_out;

logic rst_n;

// we need to switch reset polarity




// ROM
logic                    rom_req;
logic [AxiAddrWidth-1:0] rom_addr;
logic [AxiDataWidth-1:0] rom_rdata;

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
// AXI Xbar
// ---------------
axi_node_wrap_with_slices #(
    // three ports from Ariane (instruction, data and bypass)
    .NB_SLAVE           ( NBSlave                    ),
    .NB_MASTER          ( ariane_soc::NB_PERIPHERALS ),
    .NB_REGION          ( ariane_soc::NrRegion       ),
    .AXI_ADDR_WIDTH     ( AxiAddrWidth               ),
    .AXI_DATA_WIDTH     ( AxiDataWidth               ),
    .AXI_USER_WIDTH     ( AxiUserWidth               ),
    .AXI_ID_WIDTH       ( AxiIdWidthMaster           ),
    .MASTER_SLICE_DEPTH ( 2                          ),
    .SLAVE_SLICE_DEPTH  ( 2                          )
) i_axi_xbar (
    .clk          ( sys_clk        ),
    .rst_n        ( ndmreset_n ),
    .test_en_i    ( test_en    ),
    .slave        ( slave      ),
    .master       ( master     ),
    .start_addr_i ({
        ariane_soc::DebugBase,
        ariane_soc::ROMBase,
        ariane_soc::CLINTBase,
        ariane_soc::PLICBase,
        ariane_soc::ZYNQBase,
        // ariane_soc::UARTBase,
        // ariane_soc::TimerBase,
        // ariane_soc::SPIBase,
        // ariane_soc::EthernetBase,
        // ariane_soc::GPIOBase,
        ariane_soc::DRAMBase
    }),
    .end_addr_i   ({
        ariane_soc::DebugBase    + ariane_soc::DebugLength - 1,
        ariane_soc::ROMBase      + ariane_soc::ROMLength - 1,
        ariane_soc::CLINTBase    + ariane_soc::CLINTLength - 1,
        ariane_soc::PLICBase     + ariane_soc::PLICLength - 1,
        ariane_soc::ZYNQBase     + ariane_soc::ZYNQLength - 1,
        // ariane_soc::UARTBase     + ariane_soc::UARTLength - 1,
        // ariane_soc::TimerBase    + ariane_soc::TimerLength - 1,
        // ariane_soc::SPIBase      + ariane_soc::SPILength - 1,
        // ariane_soc::EthernetBase + ariane_soc::EthernetLength -1,
        // ariane_soc::GPIOBase     + ariane_soc::GPIOLength - 1,
        ariane_soc::DRAMBase     + ariane_soc::DRAMLength - 1
    }),
    .valid_rule_i (ariane_soc::ValidRule)
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

axi_master_connect i_dm_axi_master_connect (
  .axi_req_i(dm_axi_m_req),
  .axi_resp_o(dm_axi_m_resp),
  .master(slave[1])
);

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
    .boot_addr_i  ( ariane_soc::ROMBase ), // start fetching from ROM
    .hart_id_i    ( '0                  ),
    .irq_i        ( irq                 ),
    .ipi_i        ( ipi                 ),
    .time_irq_i   ( timer_irq           ),
    .debug_req_i  ( debug_req_irq       ),
    .axi_req_o    ( axi_ariane_req      ),
    .axi_resp_i   ( axi_ariane_resp     )
);

axi_master_connect i_axi_master_connect_ariane (.axi_req_i(axi_ariane_req), .axi_resp_o(axi_ariane_resp), .master(slave[0]));

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

axi_slave_connect i_axi_slave_connect_clint (.axi_req_o(axi_clint_req), .axi_resp_i(axi_clint_resp), .slave(master[ariane_soc::CLINT]));

// ---------------
// ROM
// ---------------
axi2mem #(
    .AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
    .AXI_ADDR_WIDTH ( AxiAddrWidth     ),
    .AXI_DATA_WIDTH ( AxiDataWidth     ),
    .AXI_USER_WIDTH ( AxiUserWidth     )
) i_axi2rom (
    .clk_i  ( sys_clk                     ),
    .rst_ni ( ndmreset_n              ),
    .slave  ( master[ariane_soc::ROM] ),
    .req_o  ( rom_req                 ),
    .we_o   (                         ),
    .addr_o ( rom_addr                ),
    .be_o   (                         ),
    .data_o (                         ),
    .data_i ( rom_rdata               )
);

bootrom i_bootrom (
    .clk_i   ( sys_clk       ),
    .req_i   ( rom_req   ),
    .addr_i  ( rom_addr  ),
    .rdata_o ( rom_rdata )
);

// ---------------
// Peripherals
// ---------------


// ariane_peripherals #(
//     .AxiAddrWidth ( AxiAddrWidth     ),
//     .AxiDataWidth ( AxiDataWidth     ),
//     .AxiIdWidth   ( AxiIdWidthSlaves ),
//     .AxiUserWidth ( AxiUserWidth     ),
//     .InclUART     ( 1'b1             ),
//     .InclGPIO     ( 1'b1             )
// ) i_ariane_peripherals (
//     .clk_i        ( clk                          ),
//     .rst_ni       ( ndmreset_n                   ),
//     .plic         ( master[ariane_soc::PLIC]     ),
//     .uart         ( master[ariane_soc::UART]     ),
//     .spi          ( master[ariane_soc::SPI]      ),
//     .gpio         ( master[ariane_soc::GPIO]     ),
//     .ethernet     ( master[ariane_soc::Ethernet] ),
//     .timer        ( master[ariane_soc::Timer]    ),
//     .irq_o        ( irq                          ),
//     .rx_i         ( rx                           ),
//     .tx_o         ( tx                           ),

//       .leds_o         ( led                       )

// );


// ---------------------
// Board peripherals
// ---------------------


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


// logic clkfb;

//    MMCME2_BASE #(
//       .BANDWIDTH("OPTIMIZED"),   // Jitter programming (OPTIMIZED, HIGH, LOW)
//       .CLKFBOUT_MULT_F(10.0),     // Multiply value for all CLKOUT (2.000-64.000).
//       .CLKFBOUT_PHASE(0.0),      // Phase offset in degrees of CLKFB (-360.000-360.000).
//       .CLKIN1_PERIOD(10.0),       // Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
//       // CLKOUT0_DIVIDE - CLKOUT6_DIVIDE: Divide amount for each CLKOUT (1-128)
//       .CLKOUT1_DIVIDE(20),
//       .CLKOUT2_DIVIDE(8),
//       .CLKOUT3_DIVIDE(1),
//       .CLKOUT4_DIVIDE(20),
//       .CLKOUT5_DIVIDE(1),
//       .CLKOUT6_DIVIDE(1),
//       .CLKOUT0_DIVIDE_F(1.0),    // Divide amount for CLKOUT0 (1.000-128.000).
//       // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for each CLKOUT (0.01-0.99).
//       .CLKOUT0_DUTY_CYCLE(0.5),
//       .CLKOUT1_DUTY_CYCLE(0.5),
//       .CLKOUT2_DUTY_CYCLE(0.5),
//       .CLKOUT3_DUTY_CYCLE(0.5),
//       .CLKOUT4_DUTY_CYCLE(0.5),
//       .CLKOUT5_DUTY_CYCLE(0.5),
//       .CLKOUT6_DUTY_CYCLE(0.5),
//       // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for each CLKOUT (-360.000-360.000).
//       .CLKOUT0_PHASE(0.0),
//       .CLKOUT1_PHASE(0.0),
//       .CLKOUT2_PHASE(0.0),
//       .CLKOUT3_PHASE(0.0),
//       .CLKOUT4_PHASE(0.0),
//       .CLKOUT5_PHASE(0.0),
//       .CLKOUT6_PHASE(0.0),
//       .CLKOUT4_CASCADE("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
//       .DIVCLK_DIVIDE(1),         // Master division value (1-106)
//       .REF_JITTER1(0.0),         // Reference input jitter in UI (0.000-0.999).
//       .STARTUP_WAIT("FALSE")     // Delays DONE until MMCM is locked (FALSE, TRUE)
//    )
//    MMCME2_BASE_inst (
//       // Clock Outputs: 1-bit (each) output: User configurable clock outputs
//       .CLKOUT0(clk),     // 50 MHz
//       .CLKOUT0B(),   
//       .CLKOUT1(),     
//       .CLKOUT1B(),   
//       .CLKOUT2(),     // 125 MHz quadrature (90 deg phase shift)
//       .CLKOUT2B(),   
//       .CLKOUT3(),     // 50 MHz clock
//       .CLKOUT3B(),   
//       .CLKOUT4(),     
//       .CLKOUT5(),     
//       .CLKOUT6(),     
//       // Feedback Clocks: 1-bit (each) output: Clock feedback ports
//       .CLKFBOUT(clkfb),   // 1-bit output: Feedback clock
//       .CLKFBOUTB(), // 1-bit output: Inverted CLKFBOUT
//       // Status Ports: 1-bit (each) output: MMCM status ports
//       .LOCKED(pll_locked),       // 1-bit output: LOCK
//       // Clock Inputs: 1-bit (each) input: Clock input
//       .CLKIN1(sys_clk),       // 100mhz
//       // Control Ports: 1-bit (each) input: MMCM control ports
//       .PWRDWN(),       // 1-bit input: Power-down
//       .RST(cpu_reset),             // 1-bit input: Reset
//       // Feedback Clocks: 1-bit (each) input: Clock feedback ports
//       .CLKFBIN(clkfb)      // 1-bit input: Feedback clock
//    );


// axi_bram i_axi_bram
//     (
//     .s_axi_aclk(clk),
//     .s_axi_aresetn(ndmreset_n),

//     .s_axi_awid(dram.aw_id),
//     .s_axi_awaddr(dram.aw_addr),
//     .s_axi_awlen(dram.aw_len),
//     .s_axi_awsize(dram.aw_size),
//     .s_axi_awburst(dram.aw_burst),
//     .s_axi_awlock(dram.aw_lock),
//     .s_axi_awcache(dram.aw_cache),
//     .s_axi_awprot(dram.aw_prot),
//     .s_axi_awvalid(dram.aw_valid),
//     .s_axi_awready(dram.aw_ready),
//     .s_axi_wdata(dram.w_data),
//     .s_axi_wstrb(dram.w_strb),
//     .s_axi_wlast(dram.w_last),
//     .s_axi_wvalid(dram.w_valid),
//     .s_axi_wready(dram.w_ready),
//     .s_axi_bid(dram.b_id),
//     .s_axi_bresp(dram.b_resp),
//     .s_axi_bvalid(dram.b_valid),
//     .s_axi_bready(dram.b_ready),
//     .s_axi_arid(dram.ar_id),
//     .s_axi_araddr(dram.ar_addr),
//     .s_axi_arlen(dram.ar_len),
//     .s_axi_arsize(dram.ar_size),
//     .s_axi_arburst(dram.ar_burst),
//     .s_axi_arlock(dram.ar_lock),
//     .s_axi_arcache(dram.ar_cache),
//     .s_axi_arprot(dram.ar_prot),
//     .s_axi_arvalid(dram.ar_valid),
//     .s_axi_arready(dram.ar_ready),
//     .s_axi_rid(dram.r_id),
//     .s_axi_rdata(dram.r_data),
//     .s_axi_rresp(dram.r_resp),
//     .s_axi_rlast(dram.r_last),
//     .s_axi_rvalid(dram.r_valid),
//     .s_axi_rready(dram.r_ready)
//   );

ariane_axi::req_t    axi_zynq_req;
ariane_axi::resp_t   axi_zynq_resp;

axi_slave_connect i_axi_slave_connect_zynq (.axi_req_o(axi_zynq_req), .axi_resp_i(axi_zynq_resp), .slave(master[ariane_soc::ZYNQ]));



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
    .S_AXI_HP0_wvalid(dram.w_valid),


  );















endmodule
