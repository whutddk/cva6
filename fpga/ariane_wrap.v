
		


module ariane_wrap (
	input  wire                         clk_i,
	input  wire                         rst_ni,
	// Core ID, Cluster ID and boot address are considered more or less static
	input  wire [63:0]                  boot_addr_i,  // reset boot address
	input  wire [63:0]                  hart_id_i,    // hart id in a multicore environment (reflected in a CSR)

	// Interrupt inputs
	input  wire [1:0]                   irq_i,        // level sensitive IR lines, mip & sip (async)
	input  wire                         ipi_i,        // inter-processor interrupts (async)
	// Timer facilities
	input  wire                         time_irq_i,   // timer interrupt in (async)
	input  wire                         debug_req_i,  // debug request (async)
		// input wire  M_AXI_ACLK,
		// input wire  M_AXI_ARESETN,
	output wire [3 : 0] M_AXI_AWID,
	output wire [63 : 0] M_AXI_AWADDR,
	output wire [7 : 0] M_AXI_AWLEN,
	output wire [2 : 0] M_AXI_AWSIZE,
	output wire [1 : 0] M_AXI_AWBURST,
	output wire  M_AXI_AWLOCK,
	output wire [3 : 0] M_AXI_AWCACHE,
	output wire [2 : 0] M_AXI_AWPROT,
	output wire [3 : 0] M_AXI_AWQOS,
// output wire [C_M_AXI_AWUSER_WIDTH-1 : 0] M_AXI_AWUSER,
	output wire  M_AXI_AWVALID,
	input wire  M_AXI_AWREADY,
	output wire [63 : 0] M_AXI_WDATA,
	output wire [7 : 0] M_AXI_WSTRB,
	output wire  M_AXI_WLAST,
// output wire [C_M_AXI_WUSER_WIDTH-1 : 0] M_AXI_WUSER,
	output wire  M_AXI_WVALID,
	input wire  M_AXI_WREADY,
	input wire [3 : 0] M_AXI_BID,
	input wire [1 : 0] M_AXI_BRESP,
// input wire [C_M_AXI_BUSER_WIDTH-1 : 0] M_AXI_BUSER,
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
// output wire [C_M_AXI_ARUSER_WIDTH-1 : 0] M_AXI_ARUSER,
	output wire  M_AXI_ARVALID,
	input wire  M_AXI_ARREADY,
	input wire [3 : 0] M_AXI_RID,
	input wire [63 : 0] M_AXI_RDATA,
	input wire [1 : 0] M_AXI_RRESP,
	input wire  M_AXI_RLAST,
// input wire [C_M_AXI_RUSER_WIDTH-1 : 0] M_AXI_RUSER,
	input wire  M_AXI_RVALID,
	output wire  M_AXI_RREADY

);


// ariane_interface i_ariane_interface(
// 	.clk_i(clk_i),
// 	.rst_ni(rst_ni),
// 	.boot_addr_i(boot_addr_i),
// 	.hart_id_i(hart_id_i),
// 	.irq_i(irq_i),
// 	.ipi_i(ipi_i),
// 	.time_irq_i(time_irq_i),
// 	.debug_req_i(debug_req_i),

// 	.M_AXI_AWID(M_AXI_AWID),
// 	.M_AXI_AWADDR(M_AXI_AWADDR),
// 	.M_AXI_AWLEN(M_AXI_AWLEN),
// 	.M_AXI_AWSIZE(M_AXI_AWSIZE),
// 	.M_AXI_AWBURST(M_AXI_AWBURST),
// 	.M_AXI_AWLOCK(M_AXI_AWLOCK),
// 	.M_AXI_AWCACHE(M_AXI_AWCACHE),
// 	.M_AXI_AWPROT(M_AXI_AWPROT),
// 	.M_AXI_AWQOS(M_AXI_AWQOS),
// 	.M_AXI_AWVALID(M_AXI_AWVALID),
// 	.M_AXI_AWREADY(M_AXI_AWREADY),
// 	.M_AXI_WDATA(M_AXI_WDATA),
// 	.M_AXI_WSTRB(M_AXI_WSTRB),
// 	.M_AXI_WLAST(M_AXI_WLAST),
// 	.M_AXI_WVALID(M_AXI_WVALID),
// 	.M_AXI_WREADY(M_AXI_WREADY),
// 	.M_AXI_BID(M_AXI_BID),
// 	.M_AXI_BRESP(M_AXI_BRESP),
// 	.M_AXI_BVALID(M_AXI_BVALID),
// 	.M_AXI_BREADY(M_AXI_BREADY),
// 	.M_AXI_ARID(M_AXI_ARID),
// 	.M_AXI_ARADDR(M_AXI_ARADDR),
// 	.M_AXI_ARLEN(M_AXI_ARLEN),
// 	.M_AXI_ARSIZE(M_AXI_ARSIZE),
// 	.M_AXI_ARBURST(M_AXI_ARBURST),
// 	.M_AXI_ARLOCK(M_AXI_ARLOCK),
// 	.M_AXI_ARCACHE(M_AXI_ARCACHE),
// 	.M_AXI_ARPROT(M_AXI_ARPROT),
// 	.M_AXI_ARQOS(M_AXI_ARQOS),
// 	.M_AXI_ARVALID(M_AXI_ARVALID),
// 	.M_AXI_ARREADY(M_AXI_ARREADY),
// 	.M_AXI_RID(M_AXI_RID),
// 	.M_AXI_RDATA(M_AXI_RDATA),
// 	.M_AXI_RRESP(M_AXI_RRESP),
// 	.M_AXI_RLAST(M_AXI_RLAST),
// 	.M_AXI_RVALID(M_AXI_RVALID),
// 	.M_AXI_RREADY(M_AXI_RREADY)

// );



endmodule











