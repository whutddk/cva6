


import ariane_pkg::*;

module ariane_interface (
	input  logic                         clk_i,
	input  logic                         rst_ni,
	// Core ID, Cluster ID and boot address are considered more or less static
	input  logic [63:0]                  boot_addr_i,  // reset boot address
	input  logic [63:0]                  hart_id_i,    // hart id in a multicore environment (reflected in a CSR)

	// Interrupt inputs
	input  logic [1:0]                   irq_i,        // level sensitive IR lines, mip & sip (async)
	input  logic                         ipi_i,        // inter-processor interrupts (async)
	// Timer facilities
	input  logic                         time_irq_i,   // timer interrupt in (async)
	input  logic                         debug_req_i,  // debug request (async)

	// memory side, AXI Master


		input wire  M_AXI_ACLK,
		input wire  M_AXI_ARESETN,



			output wire [3 : 0] M_AXI_AWID,
			output wire [63 : 0] M_AXI_AWADDR,
			output wire [7 : 0] M_AXI_AWLEN,
			output wire [2 : 0] M_AXI_AWSIZE,
			output wire [1 : 0] M_AXI_AWBURST,
			output wire  M_AXI_AWLOCK,
			output wire [3 : 0] M_AXI_AWCACHE,
			output wire [2 : 0] M_AXI_AWPROT,
			output wire [3 : 0] M_AXI_AWQOS,
		output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER,
			output wire  M_AXI_AWVALID,
			input wire  M_AXI_AWREADY,
			output wire [63 : 0] M_AXI_WDATA,
			output wire [7 : 0] M_AXI_WSTRB,
			output wire  M_AXI_WLAST,
		output wire [C_M_AXI_WUSER_WIDTH-1 : 0] M_AXI_WUSER,
			output wire  M_AXI_WVALID,
			input wire  M_AXI_WREADY,
			input wire [3 : 0] M_AXI_BID,
			input wire [1 : 0] M_AXI_BRESP,
		input wire [C_M_AXI_BUSER_WIDTH-1 : 0] M_AXI_BUSER,
			input wire  M_AXI_BVALID,
			output wire  M_AXI_BREADY,
			output wire [3 : 0] M_AXI_ARID,
			output wire [63 : 0] M_AXI_ARADDR,
			output wire [7 : 0] M_AXI_ARLEN,
			output wire [2 : 0] M_AXI_ARSIZE,
			output wire [1 : 0] M_AXI_ARBURST,
			output wire  M_AXI_ARLOCK,
			output wire [3 : 0] M_AXI_ARCACHE,
			output wire [2 : 0] M_AXI_ARPROT,
			output wire [3 : 0] M_AXI_ARQOS,
		output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER,
			output wire  M_AXI_ARVALID,
			input wire  M_AXI_ARREADY,
			input wire [3 : 0] M_AXI_RID,
			input wire [63 : 0] M_AXI_RDATA,
			input wire [1 : 0] M_AXI_RRESP,
			input wire  M_AXI_RLAST,
		input wire [C_M_AXI_RUSER_WIDTH-1 : 0] M_AXI_RUSER,
			input wire  M_AXI_RVALID,
			output wire  M_AXI_RREADY

);










	// ariane_axi::req_t             axi_req_o;


        // aw_chan_t axi_req_o_aw;

        logic [3:0]              axi_req_o_aw_id;
        assign M_AXI_AWID = axi_req_o_aw_id;

        logic [63:0]            axi_req_o_aw_addr;
        assign M_AXI_AWADDR = axi_req_o_aw_addr;

        logic [7:0]    axi_req_o_aw_len;
        assign M_AXI_AWLEN = axi_req_o_aw_len;

        logic [2:0]   axi_req_o_aw_size;
        assign M_AXI_AWSIZE = axi_req_o_aw_size;

        logic [1:0]  axi_req_o_aw_burst;
        assign M_AXI_AWBURST = axi_req_o_aw_burst;

        logic axi_req_o_aw_lock;
        assign M_AXI_AWLOCK = axi_req_o_aw_lock;

        logic [3:0]  axi_req_o_aw_cache;
        assign M_AXI_AWCACHE = axi_req_o_aw_cache;

        logic [2:0]   axi_req_o_aw_prot;
        assign M_AXI_AWPROT = axi_req_o_aw_prot;

        logic [3:0]    axi_req_o_aw_qos;
        assign M_AXI_AWQOS = axi_req_o_aw_qos;

        logic [3:0] axi_req_o_aw_region;

        logic [5:0]   axi_req_o_aw_atop;

        logic axi_req_o_aw_valid;
        assign M_AXI_AWVALID = axi_req_o_aw_valid;

        // w_chan_t  axi_req_o_w;
        logic [63:0] axi_req_o_w_data;
        assign M_AXI_WDATA = axi_req_o_w_data;

        logic [7:0] axi_req_o_w_strb;
        assign M_AXI_WSTRB = axi_req_o_w_strb;

        logic axi_req_o_w_last;
        assign M_AXI_WLAST = axi_req_o_w_last;

        logic axi_req_o_w_valid;
        assign M_AXI_WVALID = axi_req_o_w_valid;

        logic axi_req_o_b_ready;
        assign M_AXI_BREADY = axi_req_o_b_ready;
        // ar_chan_t axi_req_o_ar;
        logic [3:0]             axi_req_o_ar_id;
        assign M_AXI_ARID = axi_req_o_ar_id;

        logic [63:0]            axi_req_o_ar_addr;
        assign M_AXI_ARADDR = axi_req_o_ar_addr;

        logic [7:0]    axi_req_o_ar_len;
        assign M_AXI_ARLEN = axi_req_o_ar_len;

        logic [2:0]   axi_req_o_ar_size;
        assign M_AXI_ARSIZE = axi_req_o_ar_size;

        logic [1:0]  axi_req_o_ar_burst;
        assign M_AXI_ARBURST = axi_req_o_ar_burst;

        logic             axi_req_o_ar_lock;
        assign M_AXI_ARLOCK = axi_req_o_ar_lock;

        logic [3:0]  axi_req_o_ar_cache;
        assign M_AXI_ARCACHE = axi_req_o_ar_cache;

        logic [2:0]   axi_req_o_ar_prot;
        assign M_AXI_ARPROT = axi_req_o_ar_prot;

        logic [3:0]    axi_req_o_ar_qos;
        assign M_AXI_ARQOS = axi_req_o_ar_qos;

        logic [3:0] axi_req_o_ar_region;

        logic     axi_req_o_ar_valid;
        assign M_AXI_ARVALID = axi_req_o_ar_valid;

        logic     axi_req_o_r_ready;
        assign M_AXI_RREADY = axi_req_o_r_ready;







	// ariane_axi::resp_t            axi_resp_i;
			  logic     axi_resp_i_aw_ready = M_AXI_AWREADY;
        logic     axi_resp_i_ar_ready = M_AXI_ARREADY;
        logic     axi_resp_i_w_ready = M_AXI_WREADY;
        logic     axi_resp_i_b_valid = M_AXI_RVALID;
        // b_chan_t  axi_resp_i_b;
        logic [3:0]            axi_resp_i_b_id = M_AXI_BID;
        logic [1:0] axi_resp_i_b_resp = M_AXI_BRESP;

        logic     axi_resp_i_r_valid = M_AXI_BVALID;
        // r_chan_t  axi_resp_i_r;
        logic [3:0]            axi_resp_i_r_id = M_AXI_RID;
        logic [63:0]          axi_resp_i_r_data = M_AXI_RDATA;
        logic [1:0] axi_resp_i_r_resp = M_AXI_RRESP;
        logic axi_resp_i_r_last = M_AXI_RLAST;




ariane i_ariane #(
	parameter ariane_pkg::ariane_cfg_t ArianeCfg     = ariane_pkg::ArianeDefaultConfig
) (
	.clk_i(clk_i),
	.rst_ni(rst_ni),
	// Core ID, Cluster ID and boot address are considered more or less static
	.boot_addr_i(boot_addr_i),  // reset boot address
	.hart_id_i(hart_id_i),    // hart id in a multicore environment (reflected in a CSR)

	// Interrupt inputs
	.irq_i(irq_i),        // level sensitive IR lines, mip & sip (async)
	.ipi_i(ipi_i),        // inter-processor interrupts (async)
	// Timer facilities
	.time_irq_i(time_irq_i),   // timer interrupt in (async)
	.debug_req_i(debug_req_i),  // debug request (async)

	// memory side, AXI Master
	.axi_req_o(axi_req_o),
	.axi_resp_i(axi_resp_i)

);











endmodule








