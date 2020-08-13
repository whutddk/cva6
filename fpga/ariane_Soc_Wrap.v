
module ariane_Soc_Wrap (
	input sys_clk,
	input RSTn,

	output [7:0] led,
	// input [7:0] sw,

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

    wire [3 : 0] PERIP_AXI_AWID;
    wire [63 : 0] PERIP_AXI_AWADDR;
    wire [7 : 0] PERIP_AXI_AWLEN;
    wire [2 : 0] PERIP_AXI_AWSIZE;
    wire [1 : 0] PERIP_AXI_AWBURST;
    wire PERIP_AXI_AWLOCK;
    wire [3 : 0] PERIP_AXI_AWCACHE;
    wire [2 : 0] PERIP_AXI_AWPROT;
    wire PERIP_AXI_AWVALID;
    wire  PERIP_AXI_AWREADY;
    wire [63 : 0] PERIP_AXI_WDATA;
    wire [7 : 0] PERIP_AXI_WSTRB;
    wire PERIP_AXI_WLAST;
    wire PERIP_AXI_WVALID;
    wire PERIP_AXI_WREADY;
    wire [3 : 0] PERIP_AXI_BID;
    wire [1 : 0] PERIP_AXI_BRESP;
    wire PERIP_AXI_BVALID;
    wire PERIP_AXI_BREADY;
    wire [3 : 0] PERIP_AXI_ARID;
    wire [63 : 0] PERIP_AXI_ARADDR;
    wire [7 : 0] PERIP_AXI_ARLEN;
    wire [2 : 0] PERIP_AXI_ARSIZE;
    wire [1 : 0] PERIP_AXI_ARBURST;
    wire  PERIP_AXI_ARLOCK;
    wire [3 : 0] PERIP_AXI_ARCACHE;
    wire [2 : 0] PERIP_AXI_ARPROT;
    wire  PERIP_AXI_ARVALID;
    wire  PERIP_AXI_ARREADY;
    wire [3 : 0] PERIP_AXI_RID;
    wire [63 : 0] PERIP_AXI_RDATA;
    wire [1 : 0] PERIP_AXI_RRESP;
    wire PERIP_AXI_RLAST;
    wire PERIP_AXI_RVALID;
    wire PERIP_AXI_RREADY;
    wire [4 : 0] PERIP_AXI_AWUSER;
    wire [3 : 0] PERIP_AXI_AWQOS;
    wire [4 : 0] PERIP_AXI_WUSER;
    wire [4 : 0] PERIP_AXI_BUSER;
    wire [4 : 0] PERIP_AXI_ARUSER;
    wire [3 : 0] PERIP_AXI_ARQOS;
    wire [4 : 0] PERIP_AXI_RUSER;
    wire [3:0] PERIP_AXI_AWREGION;
    wire [3:0] PERIP_AXI_ARREGION;


ariane_xilinx bd_xilinx(
	.sys_clk(sys_clk),
	.RSTn(RSTn),

	// .sw(sw),

    .PERIP_AXI_AWID(PERIP_AXI_AWID),
    .PERIP_AXI_AWADDR(PERIP_AXI_AWADDR),
    .PERIP_AXI_AWLEN(PERIP_AXI_AWLEN),
    .PERIP_AXI_AWSIZE(PERIP_AXI_AWSIZE),
    .PERIP_AXI_AWBURST(PERIP_AXI_AWBURST),
    .PERIP_AXI_AWLOCK(PERIP_AXI_AWLOCK),
    .PERIP_AXI_AWCACHE(PERIP_AXI_AWCACHE),
    .PERIP_AXI_AWPROT(PERIP_AXI_AWPROT),
    .PERIP_AXI_AWVALID(PERIP_AXI_AWVALID),
    .PERIP_AXI_AWREADY(PERIP_AXI_AWREADY),
    .PERIP_AXI_WDATA(PERIP_AXI_WDATA),
    .PERIP_AXI_WSTRB(PERIP_AXI_WSTRB),
    .PERIP_AXI_WLAST(PERIP_AXI_WLAST),
    .PERIP_AXI_WVALID(PERIP_AXI_WVALID),
    .PERIP_AXI_WREADY(PERIP_AXI_WREADY),
    .PERIP_AXI_BID(PERIP_AXI_BID),
    .PERIP_AXI_BRESP(PERIP_AXI_BRESP),
    .PERIP_AXI_BVALID(PERIP_AXI_BVALID),
    .PERIP_AXI_BREADY(PERIP_AXI_BREADY),
    .PERIP_AXI_ARID(PERIP_AXI_ARID),
    .PERIP_AXI_ARADDR(PERIP_AXI_ARADDR),
    .PERIP_AXI_ARLEN(PERIP_AXI_ARLEN),
    .PERIP_AXI_ARSIZE(PERIP_AXI_ARSIZE),
    .PERIP_AXI_ARBURST(PERIP_AXI_ARBURST),
    .PERIP_AXI_ARLOCK(PERIP_AXI_ARLOCK),
    .PERIP_AXI_ARCACHE(PERIP_AXI_ARCACHE),
    .PERIP_AXI_ARPROT(PERIP_AXI_ARPROT),
    .PERIP_AXI_ARVALID(PERIP_AXI_ARVALID),
    .PERIP_AXI_ARREADY(PERIP_AXI_ARREADY),
    .PERIP_AXI_RID(PERIP_AXI_RID),
    .PERIP_AXI_RDATA(PERIP_AXI_RDATA),
    .PERIP_AXI_RRESP(PERIP_AXI_RRESP),
    .PERIP_AXI_RLAST(PERIP_AXI_RLAST),
    .PERIP_AXI_RVALID(PERIP_AXI_RVALID),
    .PERIP_AXI_RREADY(PERIP_AXI_RREADY),
    .PERIP_AXI_AWUSER(PERIP_AXI_AWUSER),
    .PERIP_AXI_AWQOS(PERIP_AXI_AWQOS),
    .PERIP_AXI_WUSER(PERIP_AXI_WUSER),
    .PERIP_AXI_BUSER(PERIP_AXI_BUSER),
    .PERIP_AXI_ARUSER(PERIP_AXI_ARUSER),
    .PERIP_AXI_ARQOS(PERIP_AXI_ARQOS),
    .PERIP_AXI_RUSER(PERIP_AXI_RUSER),
    .PERIP_AXI_AWREGION(PERIP_AXI_AWREGION),
    .PERIP_AXI_ARREGION(PERIP_AXI_ARREGION),



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














    assign PERIP_AXI_BUSER = 1'b0;
    assign PERIP_AXI_RUSER = 1'b0;



    wire [31:0] s_axi_gpio_awaddr;
    wire [7:0]  s_axi_gpio_awlen;
    wire [2:0]  s_axi_gpio_awsize;
    wire [1:0]  s_axi_gpio_awburst;
    wire [3:0]  s_axi_gpio_awcache;
    wire        s_axi_gpio_awvalid;
    wire        s_axi_gpio_awready;
    wire [31:0] s_axi_gpio_wdata;
    wire [3:0]  s_axi_gpio_wstrb;
    wire        s_axi_gpio_wlast;
    wire        s_axi_gpio_wvalid;
    wire        s_axi_gpio_wready;
    wire [1:0]  s_axi_gpio_bresp;
    wire        s_axi_gpio_bvalid;
    wire        s_axi_gpio_bready;
    wire [31:0] s_axi_gpio_araddr;
    wire [7:0]  s_axi_gpio_arlen;
    wire [2:0]  s_axi_gpio_arsize;
    wire [1:0]  s_axi_gpio_arburst;
    wire [3:0]  s_axi_gpio_arcache;
    wire        s_axi_gpio_arvalid;
    wire        s_axi_gpio_arready;
    wire [31:0] s_axi_gpio_rdata;
    wire [1:0]  s_axi_gpio_rresp;
    wire        s_axi_gpio_rlast;
    wire        s_axi_gpio_rvalid;
    wire        s_axi_gpio_rready;

        // system-bus is 64-bit, convert down to 32 bit
        xlnx_axi_dwidth_converter i_xlnx_axi_dwidth_converter_gpio (
            .s_axi_aclk     ( sys_clk              ),
            .s_axi_aresetn  ( RSTn             ),
            .s_axi_awid     ( PERIP_AXI_AWID         ),
            .s_axi_awaddr   ( PERIP_AXI_AWADDR[31:0] ),
            .s_axi_awlen    ( PERIP_AXI_AWLEN        ),
            .s_axi_awsize   ( PERIP_AXI_AWSIZE       ),
            .s_axi_awburst  ( PERIP_AXI_AWBURST      ),
            .s_axi_awlock   ( PERIP_AXI_AWLOCK       ),
            .s_axi_awcache  ( PERIP_AXI_AWCACHE      ),
            .s_axi_awprot   ( PERIP_AXI_AWPROT      ),
            .s_axi_awregion ( PERIP_AXI_AWREGION     ),
            .s_axi_awqos    ( PERIP_AXI_AWQOS  ),
            .s_axi_awvalid  ( PERIP_AXI_AWVALID     ),
            .s_axi_awready  (  PERIP_AXI_AWREADY   ),
            .s_axi_wdata    ( PERIP_AXI_WDATA      ),
            .s_axi_wstrb    ( PERIP_AXI_WSTRB     ),
            .s_axi_wlast    ( PERIP_AXI_WLAST       ),
            .s_axi_wvalid   ( PERIP_AXI_WVALID      ),
            .s_axi_wready   ( PERIP_AXI_WREADY    ),
            .s_axi_bid      ( PERIP_AXI_BID        ),
            .s_axi_bresp    ( PERIP_AXI_BRESP     ),
            .s_axi_bvalid   ( PERIP_AXI_BVALID     ),
            .s_axi_bready   ( PERIP_AXI_BREADY      ),
            .s_axi_arid     ( PERIP_AXI_ARID      ),
            .s_axi_araddr   ( PERIP_AXI_ARADDR[31:0] ),
            .s_axi_arlen    ( PERIP_AXI_ARLEN      ),
            .s_axi_arsize   ( PERIP_AXI_ARSIZE       ),
            .s_axi_arburst  ( PERIP_AXI_ARBURST    ),
            .s_axi_arlock   ( PERIP_AXI_ARLOCK      ),
            .s_axi_arcache  ( PERIP_AXI_ARCACHE   ),
            .s_axi_arprot   ( PERIP_AXI_ARPROT    ),
            .s_axi_arregion ( PERIP_AXI_ARREGION     ),
            .s_axi_arqos    ( PERIP_AXI_ARQOS       ),
            .s_axi_arvalid  ( PERIP_AXI_ARVALID    ),
            .s_axi_arready  ( PERIP_AXI_ARREADY     ),
            .s_axi_rid      ( PERIP_AXI_RID       ),
            .s_axi_rdata    ( PERIP_AXI_RDATA    ),
            .s_axi_rresp    ( PERIP_AXI_RRESP     ),
            .s_axi_rlast    ( PERIP_AXI_RLAST     ),
            .s_axi_rvalid   ( PERIP_AXI_RVALID   ),
            .s_axi_rready   ( PERIP_AXI_RREADY    ),

            .m_axi_awaddr   ( s_axi_gpio_awaddr  ),
            .m_axi_awlen    ( s_axi_gpio_awlen   ),
            .m_axi_awsize   ( s_axi_gpio_awsize  ),
            .m_axi_awburst  ( s_axi_gpio_awburst ),
            .m_axi_awlock   (                    ),
            .m_axi_awcache  ( s_axi_gpio_awcache ),
            .m_axi_awprot   (                    ),
            .m_axi_awregion (                    ),
            .m_axi_awqos    (                    ),
            .m_axi_awvalid  ( s_axi_gpio_awvalid ),
            .m_axi_awready  ( s_axi_gpio_awready ),
            .m_axi_wdata    ( s_axi_gpio_wdata   ),
            .m_axi_wstrb    ( s_axi_gpio_wstrb   ),
            .m_axi_wlast    ( s_axi_gpio_wlast   ),
            .m_axi_wvalid   ( s_axi_gpio_wvalid  ),
            .m_axi_wready   ( s_axi_gpio_wready  ),
            .m_axi_bresp    ( s_axi_gpio_bresp   ),
            .m_axi_bvalid   ( s_axi_gpio_bvalid  ),
            .m_axi_bready   ( s_axi_gpio_bready  ),
            .m_axi_araddr   ( s_axi_gpio_araddr  ),
            .m_axi_arlen    ( s_axi_gpio_arlen   ),
            .m_axi_arsize   ( s_axi_gpio_arsize  ),
            .m_axi_arburst  ( s_axi_gpio_arburst ),
            .m_axi_arlock   (                    ),
            .m_axi_arcache  ( s_axi_gpio_arcache ),
            .m_axi_arprot   (                    ),
            .m_axi_arregion (                    ),
            .m_axi_arqos    (                    ),
            .m_axi_arvalid  ( s_axi_gpio_arvalid ),
            .m_axi_arready  ( s_axi_gpio_arready ),
            .m_axi_rdata    ( s_axi_gpio_rdata   ),
            .m_axi_rresp    ( s_axi_gpio_rresp   ),
            .m_axi_rlast    ( s_axi_gpio_rlast   ),
            .m_axi_rvalid   ( s_axi_gpio_rvalid  ),
            .m_axi_rready   ( s_axi_gpio_rready  )
        );

        xlnx_axi_gpio i_xlnx_axi_gpio (
            .s_axi_aclk    ( sys_clk                  ),
            .s_axi_aresetn ( RSTn                 ),
            .s_axi_awaddr  ( s_axi_gpio_awaddr[8:0] ),
            .s_axi_awvalid ( s_axi_gpio_awvalid     ),
            .s_axi_awready ( s_axi_gpio_awready     ),
            .s_axi_wdata   ( s_axi_gpio_wdata       ),
            .s_axi_wstrb   ( s_axi_gpio_wstrb       ),
            .s_axi_wvalid  ( s_axi_gpio_wvalid      ),
            .s_axi_wready  ( s_axi_gpio_wready      ),
            .s_axi_bresp   ( s_axi_gpio_bresp       ),
            .s_axi_bvalid  ( s_axi_gpio_bvalid      ),
            .s_axi_bready  ( s_axi_gpio_bready      ),
            .s_axi_araddr  ( s_axi_gpio_araddr[8:0] ),
            .s_axi_arvalid ( s_axi_gpio_arvalid     ),
            .s_axi_arready ( s_axi_gpio_arready     ),
            .s_axi_rdata   ( s_axi_gpio_rdata       ),
            .s_axi_rresp   ( s_axi_gpio_rresp       ),
            .s_axi_rvalid  ( s_axi_gpio_rvalid      ),
            .s_axi_rready  ( s_axi_gpio_rready      ),
            .gpio_io_i     ( 'd0                     ),
            .gpio_io_o     ( led                 ),
            .gpio_io_t     (                        ),
            .gpio2_io_i    ()
        );

        assign s_axi_gpio_rlast = 1'b1;
        assign s_axi_gpio_wlast = 1'b1;











endmodule


