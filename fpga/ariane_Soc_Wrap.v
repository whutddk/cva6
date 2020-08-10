
module ariane_Soc_Wrap (
	input sys_clk,
	input RSTn,

	output [7:0] led,
	input [7:0] sw,

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


