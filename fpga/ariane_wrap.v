



module ariane_wrap (
		input S_AXI_ACLK,
		input S_AXI_ARESETN,
		input [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_AWADDR,
		input [2 : 0] S_AXI_AWPROT,
		input S_AXI_AWVALID,
		output S_AXI_AWREADY,
		input [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_WDATA,
		input [(C_S_AXI_DATA_WIDTH/8)-1 : 0] S_AXI_WSTRB,
		input S_AXI_WVALID,
		output S_AXI_WREADY,
		output [1 : 0] S_AXI_BRESP,
		output S_AXI_BVALID,
		input S_AXI_BREADY,
		input [C_S_AXI_ADDR_WIDTH-1 : 0] S_AXI_ARADDR,
		input [2 : 0] S_AXI_ARPROT,
		input S_AXI_ARVALID,
		output S_AXI_ARREADY,
		output [C_S_AXI_DATA_WIDTH-1 : 0] S_AXI_RDATA,
		output [1 : 0] S_AXI_RRESP,
		output S_AXI_RVALID,
		input S_AXI_RREADY
);

typedef struct packed {
      id_t     a;
      addr_t   b;
  } outType;

outType out;
assign out.a = out_a;
assign out.b = out_b;

test i_test(
	.clk(clk),
	.clk_en(clk_en),
	.rst_n(rst_n),
	.out(out)
);




endmodule











