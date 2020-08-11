
module ariane_Soc_Wrap (
	input sys_clk,
	input RSTn,

	output [7:0] led,
	input [7:0] sw,

(* X_INTERFACE_PARAMETER = "FREQ_HZ 30000000" *)
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
	// input trst_n,
	input tck,
	input tms,
	input tdi,
	output tdo,
	input rx,
	output tx
	
);


ariane_xilinx bd_xilinx(
	.sys_clk(sys_clk),
	.RSTn(RSTn),

	.led(led),
	.sw(sw),

	.MEM_AXI_AWID(MEM_AXI_AWID),
	.MEM_AXI_AWADDR(MEM_AXI_AWADDR),
	.MEM_AXI_AWLEN(MEM_AXI_AWLEN),
	.MEM_AXI_AWSIZE(MEM_AXI_AWSIZE),
	.MEM_AXI_AWBURST(MEM_AXI_AWBURST),
	.MEM_AXI_AWLOCK(MEM_AXI_AWLOCK),
	.MEM_AXI_AWCACHE(MEM_AXI_AWCACHE),
	.MEM_AXI_AWPROT(MEM_AXI_AWPROT),
	.MEM_AXI_AWVALID(MEM_AXI_AWVALID),
	.MEM_AXI_AWREADY(MEM_AXI_AWREADY),
	.MEM_AXI_WDATA(MEM_AXI_WDATA),
	.MEM_AXI_WSTRB(MEM_AXI_WSTRB),
	.MEM_AXI_WLAST(MEM_AXI_WLAST),

	.MEM_AXI_WVALID(MEM_AXI_WVALID),
	.MEM_AXI_WREADY(MEM_AXI_WREADY),
	.MEM_AXI_BID(MEM_AXI_BID),
	.MEM_AXI_BRESP(MEM_AXI_BRESP),

	.MEM_AXI_BVALID(MEM_AXI_BVALID),
	.MEM_AXI_BREADY(MEM_AXI_BREADY),
	.MEM_AXI_ARID(MEM_AXI_ARID),
	.MEM_AXI_ARADDR(MEM_AXI_ARADDR),
	.MEM_AXI_ARLEN(MEM_AXI_ARLEN),
	.MEM_AXI_ARSIZE(MEM_AXI_ARSIZE),
	.MEM_AXI_ARBURST(MEM_AXI_ARBURST),
	.MEM_AXI_ARLOCK(MEM_AXI_ARLOCK),
	.MEM_AXI_ARCACHE(MEM_AXI_ARCACHE),
	.MEM_AXI_ARPROT(MEM_AXI_ARPROT),

	.MEM_AXI_ARVALID(MEM_AXI_ARVALID),
	.MEM_AXI_ARREADY(MEM_AXI_ARREADY),
	.MEM_AXI_RID(MEM_AXI_RID),
	.MEM_AXI_RDATA(MEM_AXI_RDATA),
	.MEM_AXI_RRESP(MEM_AXI_RRESP),
	.MEM_AXI_RLAST(MEM_AXI_RLAST),
	.MEM_AXI_RVALID(MEM_AXI_RVALID),
	.MEM_AXI_RREADY(MEM_AXI_RREADY),

	// common part
	// input trst_n,
	.tck(tck),
	.tms(tms),
	.tdi(tdi),
	.tdo(tdo),
	.rx(rx),
	.tx(tx)
);


endmodule


