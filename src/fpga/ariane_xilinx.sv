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

  input  logic         sys_clk,

  input  logic         RSTn,

  // input  logic [ 7:0]  sw          ,


// PERIPHERALS BUS
    output wire [3 : 0] PERIP_AXI_AWID,
    output wire [63 : 0] PERIP_AXI_AWADDR,
    output wire [7 : 0] PERIP_AXI_AWLEN,
    output wire [2 : 0] PERIP_AXI_AWSIZE,
    output wire [1 : 0] PERIP_AXI_AWBURST,
    output wire PERIP_AXI_AWLOCK,
    output wire [3 : 0] PERIP_AXI_AWCACHE,
    output wire [2 : 0] PERIP_AXI_AWPROT,
    output wire PERIP_AXI_AWVALID,
    input wire  PERIP_AXI_AWREADY,
    output wire [63 : 0] PERIP_AXI_WDATA,
    output wire [7 : 0] PERIP_AXI_WSTRB,
    output wire PERIP_AXI_WLAST,
    output wire PERIP_AXI_WVALID,
    input wire PERIP_AXI_WREADY,
    input wire [3 : 0] PERIP_AXI_BID,
    input wire [1 : 0] PERIP_AXI_BRESP,
    input wire PERIP_AXI_BVALID,
    output wire PERIP_AXI_BREADY,
    output wire [3 : 0] PERIP_AXI_ARID,
    output wire [63 : 0] PERIP_AXI_ARADDR,
    output wire [7 : 0] PERIP_AXI_ARLEN,
    output wire [2 : 0] PERIP_AXI_ARSIZE,
    output wire [1 : 0] PERIP_AXI_ARBURST,
    output wire  PERIP_AXI_ARLOCK,
    output wire [3 : 0] PERIP_AXI_ARCACHE,
    output wire [2 : 0] PERIP_AXI_ARPROT,
    output wire  PERIP_AXI_ARVALID,
    input wire  PERIP_AXI_ARREADY,
    input wire [3 : 0] PERIP_AXI_RID,
    input wire [63 : 0] PERIP_AXI_RDATA,
    input wire [1 : 0] PERIP_AXI_RRESP,
    input wire PERIP_AXI_RLAST,
    input wire PERIP_AXI_RVALID,
    output wire PERIP_AXI_RREADY,
    output wire [4 : 0] PERIP_AXI_AWUSER,
    output wire [3 : 0] PERIP_AXI_AWQOS,
    output wire [4 : 0] PERIP_AXI_WUSER,
    input wire [4 : 0] PERIP_AXI_BUSER,
    output wire [4 : 0] PERIP_AXI_ARUSER,
    output wire [3 : 0] PERIP_AXI_ARQOS,
    input wire [4 : 0] PERIP_AXI_RUSER,
    output wire [3:0] PERIP_AXI_AWREGION,
    output wire [3:0] PERIP_AXI_ARREGION,




// BUS

	output wire [3 : 0] MEM_AXI_AWID,
	output wire [63 : 0] MEM_AXI_AWADDR,
	output wire [7 : 0] MEM_AXI_AWLEN,
	output wire [2 : 0] MEM_AXI_AWSIZE,
	output wire [1 : 0] MEM_AXI_AWBURST,
	output wire  MEM_AXI_AWLOCK,
	output wire [3 : 0] MEM_AXI_AWCACHE,
	output wire [2 : 0] MEM_AXI_AWPROT,
	// output wire [3 : 0] MEM_AXI_AWQOS,
// output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] MEM_AXI_AWUSER,
	output wire  MEM_AXI_AWVALID,
	input wire  MEM_AXI_AWREADY,
	output wire [63 : 0] MEM_AXI_WDATA,
	output wire [7 : 0] MEM_AXI_WSTRB,
	output wire  MEM_AXI_WLAST,
// output wire [C_M_AXI_WUSER_WIDTH-1 : 0] MEM_AXI_WUSER,
	output wire  MEM_AXI_WVALID,
	input wire  MEM_AXI_WREADY,
	input wire [3 : 0] MEM_AXI_BID,
	input wire [1 : 0] MEM_AXI_BRESP,
// input wire [C_M_AXI_BUSER_WIDTH-1 : 0] MEM_AXI_BUSER,
	input wire  MEM_AXI_BVALID,
	output wire  MEM_AXI_BREADY,
	output wire [3 : 0] MEM_AXI_ARID,
	output wire [63 : 0] MEM_AXI_ARADDR,
	output wire [7 : 0] MEM_AXI_ARLEN,
	output wire [2 : 0] MEM_AXI_ARSIZE,
	output wire [1 : 0] MEM_AXI_ARBURST,
	output wire  MEM_AXI_ARLOCK,
	output wire [3 : 0] MEM_AXI_ARCACHE,
	output wire [2 : 0] MEM_AXI_ARPROT,
// 	output wire [3 : 0] MEM_AXI_ARQOS,
// output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] MEM_AXI_ARUSER,
	output wire  MEM_AXI_ARVALID,
	input wire  MEM_AXI_ARREADY,
	input wire [3 : 0] MEM_AXI_RID,
	input wire [63 : 0] MEM_AXI_RDATA,
	input wire [1 : 0] MEM_AXI_RRESP,
	input wire  MEM_AXI_RLAST,
// input wire [C_M_AXI_RUSER_WIDTH-1 : 0] MEM_AXI_RUSER,
	input wire  MEM_AXI_RVALID,
	output wire  MEM_AXI_RREADY,

  // common part
  // input logic      trst_n      ,
  input  logic        tck         ,
  input  logic        tms         ,
  input  logic        tdi         ,
  output wire         tdo         ,
  input  logic        rx          ,
  output logic        tx
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


logic rtc;





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


assign ndmreset_n = ~ndmreset & RSTn;

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
		// ariane_soc::ROMBase,
		ariane_soc::CLINTBase,
		ariane_soc::PLICBase,
		ariane_soc::UARTBase,
		ariane_soc::TimerBase,
		// ariane_soc::SPIBase,
		// ariane_soc::EthernetBase,
		ariane_soc::GPIOBase,
		ariane_soc::DRAMBase
	}),
	.end_addr_i   ({
		ariane_soc::DebugBase    + ariane_soc::DebugLength - 1,
		// ariane_soc::ROMBase      + ariane_soc::ROMLength - 1,
		ariane_soc::CLINTBase    + ariane_soc::CLINTLength - 1,
		ariane_soc::PLICBase     + ariane_soc::PLICLength - 1,
		ariane_soc::UARTBase     + ariane_soc::UARTLength - 1,
		ariane_soc::TimerBase    + ariane_soc::TimerLength - 1,
		// ariane_soc::SPIBase      + ariane_soc::SPILength - 1,
		// ariane_soc::EthernetBase + ariane_soc::EthernetLength -1,
		ariane_soc::GPIOBase     + ariane_soc::GPIOLength - 1,
		ariane_soc::DRAMBase     + ariane_soc::DRAMLength - 1
	}),
	.valid_rule_i (ariane_soc::ValidRule)
);

// ---------------
// Debug Module
// ---------------
dmi_jtag i_dmi_jtag (
	.clk_i                ( sys_clk                ),
	.rst_ni               ( RSTn                ),
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
	.trst_ni              ( 1'b1 ),
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
	.clk_i            ( sys_clk              ),
	.rst_ni           ( RSTn             ), // PoR
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
	.dmi_rst_ni       ( RSTn             ),
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
	.clk_i      ( sys_clk                    ),
	.rst_ni     ( RSTn                     ),
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
	.clk_i                 ( sys_clk                   ),
	.rst_ni                ( RSTn                     ),
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
	.clk_i        ( sys_clk          ),
	.rst_ni       ( ndmreset_n          ),
	.boot_addr_i  ( ariane_soc::DRAMBase ), 
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
// divide clock by two
always_ff @(posedge sys_clk or negedge ndmreset_n) begin
  if (~ndmreset_n) begin
	rtc <= 0;
  end else begin
	rtc <= rtc ^ 1'b1;
  end
end

ariane_axi::req_t    axi_clint_req;
ariane_axi::resp_t   axi_clint_resp;

clint #(
	.AXI_ADDR_WIDTH ( AxiAddrWidth     ),
	.AXI_DATA_WIDTH ( AxiDataWidth     ),
	.AXI_ID_WIDTH   ( AxiIdWidthSlaves ),
	.NR_CORES       ( 1                )
) i_clint (
	.clk_i       ( sys_clk        ),
	.rst_ni      ( ndmreset_n     ),
	.testmode_i  ( test_en        ),
	.axi_req_i   ( axi_clint_req  ),
	.axi_resp_o  ( axi_clint_resp ),
	.rtc_i       ( rtc            ),
	.timer_irq_o ( timer_irq      ),
	.ipi_o       ( ipi            )
);

axi_slave_connect i_axi_slave_connect_clint (.axi_req_o(axi_clint_req), .axi_resp_i(axi_clint_resp), .slave(master[ariane_soc::CLINT]));

// ---------------
// Peripherals
// ---------------


ariane_peripherals #(
	.AxiAddrWidth ( AxiAddrWidth     ),
	.AxiDataWidth ( AxiDataWidth     ),
	.AxiIdWidth   ( AxiIdWidthSlaves ),
	.AxiUserWidth ( AxiUserWidth     ),
	.InclUART     ( 1'b1             )

) i_ariane_peripherals (
	.clk_i        ( sys_clk                   ),
	.rst_ni       ( ndmreset_n                   ),
	.plic         ( master[ariane_soc::PLIC]     ),
	.uart         ( master[ariane_soc::UART]     ),
	// .spi          ( master[ariane_soc::SPI]      ),
	// .ethernet     ( master[ariane_soc::Ethernet] ),
	.timer        ( master[ariane_soc::Timer]    ),
	.irq_o        ( irq                          ),
	.rx_i         ( rx                           ),
	.tx_o         ( tx                           )

);


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
	.clk_i  ( sys_clk                 ),
	.rst_ni ( ndmreset_n               ),
	.slv    ( master[ariane_soc::DRAM] ),
	.mst    ( dram                     )
);


	assign MEM_AXI_AWID = dram.aw_id;
	assign MEM_AXI_AWADDR = dram.aw_addr;
	assign MEM_AXI_AWLEN = dram.aw_len;
	assign MEM_AXI_AWSIZE = dram.aw_size;
	assign MEM_AXI_AWBURST = dram.aw_burst;
	assign MEM_AXI_AWLOCK = dram.aw_lock;
	assign MEM_AXI_AWCACHE = dram.aw_cache;
	assign MEM_AXI_AWPROT = dram.aw_prot;
	assign MEM_AXI_AWVALID = dram.aw_valid;
	assign dram.aw_ready = MEM_AXI_AWREADY;
	assign MEM_AXI_WDATA = dram.w_data;
	assign MEM_AXI_WSTRB = dram.w_strb;
	assign MEM_AXI_WLAST = dram.w_last;
	assign MEM_AXI_WVALID = dram.w_valid;
	assign dram.w_ready = MEM_AXI_WREADY;
	assign dram.b_id = MEM_AXI_BID;
	assign dram.b_resp = MEM_AXI_BRESP;
	assign dram.b_valid = MEM_AXI_BVALID;
	assign MEM_AXI_BREADY = dram.b_ready;
	assign MEM_AXI_ARID = dram.ar_id;
	assign MEM_AXI_ARADDR = dram.ar_addr;
	assign MEM_AXI_ARLEN = dram.ar_len;
	assign MEM_AXI_ARSIZE = dram.ar_size;
	assign MEM_AXI_ARBURST = dram.ar_burst;
	assign MEM_AXI_ARLOCK = dram.ar_lock;
	assign MEM_AXI_ARCACHE = dram.ar_cache;
	assign MEM_AXI_ARPROT = dram.ar_prot;
	assign MEM_AXI_ARVALID = dram.ar_valid;
	assign dram.ar_ready = MEM_AXI_ARREADY;
	assign dram.r_id = MEM_AXI_RID;
	assign dram.r_data = MEM_AXI_RDATA;
	assign dram.r_resp = MEM_AXI_RRESP;
	assign dram.r_last = MEM_AXI_RLAST;
	assign dram.r_valid = MEM_AXI_RVALID;
	assign MEM_AXI_RREADY = dram.r_ready;




// PERIPHERALS BUS




        assign PERIP_AXI_AWID = master[ariane_soc::GPIO].aw_id;
        assign PERIP_AXI_AWADDR = master[ariane_soc::GPIO].aw_addr;
        assign PERIP_AXI_AWLEN = master[ariane_soc::GPIO].aw_len;
        assign PERIP_AXI_AWSIZE = master[ariane_soc::GPIO].aw_size;
        assign PERIP_AXI_AWBURST = master[ariane_soc::GPIO].aw_burst;
        assign PERIP_AXI_AWLOCK = master[ariane_soc::GPIO].aw_lock;
        assign PERIP_AXI_AWCACHE = master[ariane_soc::GPIO].aw_cache;
        assign PERIP_AXI_AWPROT = master[ariane_soc::GPIO].aw_prot;
        assign PERIP_AXI_AWVALID = master[ariane_soc::GPIO].aw_valid;
        assign master[ariane_soc::GPIO].aw_ready = PERIP_AXI_AWREADY;
        assign PERIP_AXI_WDATA = master[ariane_soc::GPIO].w_data;
        assign PERIP_AXI_WSTRB = master[ariane_soc::GPIO].w_strb;
        assign PERIP_AXI_WLAST = master[ariane_soc::GPIO].w_last;
        assign PERIP_AXI_WVALID = master[ariane_soc::GPIO].w_valid;
        assign master[ariane_soc::GPIO].w_ready = PERIP_AXI_WREADY;
        assign master[ariane_soc::GPIO].b_id = PERIP_AXI_BID;
        assign master[ariane_soc::GPIO].b_resp = PERIP_AXI_BRESP;
        assign master[ariane_soc::GPIO].b_valid = PERIP_AXI_BVALID;
        assign PERIP_AXI_BREADY = master[ariane_soc::GPIO].b_ready;
        assign PERIP_AXI_ARID = master[ariane_soc::GPIO].ar_id;
        assign PERIP_AXI_ARADDR = master[ariane_soc::GPIO].ar_addr;
        assign PERIP_AXI_ARLEN = master[ariane_soc::GPIO].ar_len;
        assign PERIP_AXI_ARSIZE = master[ariane_soc::GPIO].ar_size;
        assign PERIP_AXI_ARBURST = master[ariane_soc::GPIO].ar_burst;
        assign PERIP_AXI_ARLOCK = master[ariane_soc::GPIO].ar_lock;
        assign PERIP_AXI_ARCACHE = master[ariane_soc::GPIO].ar_cache;
        assign PERIP_AXI_ARPROT = master[ariane_soc::GPIO].ar_prot;
        assign PERIP_AXI_ARVALID = master[ariane_soc::GPIO].ar_valid;
        assign master[ariane_soc::GPIO].ar_ready = PERIP_AXI_ARREADY;
        assign master[ariane_soc::GPIO].r_id = PERIP_AXI_RID;
        assign master[ariane_soc::GPIO].r_data = PERIP_AXI_RDATA;
        assign master[ariane_soc::GPIO].r_resp = PERIP_AXI_RRESP;
        assign master[ariane_soc::GPIO].r_last = PERIP_AXI_RLAST;
        assign master[ariane_soc::GPIO].r_valid = PERIP_AXI_RVALID;
        assign PERIP_AXI_RREADY = master[ariane_soc::GPIO].r_ready;

    assign PERIP_AXI_AWUSER = master[ariane_soc::GPIO].aw_user;
    assign PERIP_AXI_AWQOS = master[ariane_soc::GPIO].aw_qos;
    assign PERIP_AXI_WUSER = master[ariane_soc::GPIO].w_user;
    assign master[ariane_soc::GPIO].b_user = PERIP_AXI_BUSER;
    assign PERIP_AXI_ARUSER = master[ariane_soc::GPIO].ar_user;
    assign PERIP_AXI_ARQOS = master[ariane_soc::GPIO].ar_qos;
    assign master[ariane_soc::GPIO].r_user = PERIP_AXI_RUSER;
    assign PERIP_AXI_AWREGION = master[ariane_soc::GPIO].aw_region;
    assign PERIP_AXI_ARREGION = master[ariane_soc::GPIO].ar_region;


















endmodule
