// Copyright 2018 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Xilinx Peripehrals

module ariane_peripherals #(
    parameter int AxiAddrWidth = -1,
    parameter int AxiDataWidth = -1,
    parameter int AxiIdWidth   = -1,
    parameter int AxiUserWidth = 1,
    parameter bit InclUART     = 1
) (
    input  logic       clk_i           , // Clock
    input  logic       rst_ni          , // Asynchronous reset active low

    AXI_BUS.Slave      uart            ,

    // UART
    input  logic       rx_i            ,
    output logic       tx_o            
);

    // ---------------
    // 2. UART
    // ---------------
    logic         uart_penable;
    logic         uart_pwrite;
    logic [31:0]  uart_paddr;
    logic         uart_psel;
    logic [31:0]  uart_pwdata;
    logic [31:0]  uart_prdata;
    logic         uart_pready;
    logic         uart_pslverr;

    axi2apb_64_32 #(
        .AXI4_ADDRESS_WIDTH ( AxiAddrWidth ),
        .AXI4_RDATA_WIDTH   ( AxiDataWidth ),
        .AXI4_WDATA_WIDTH   ( AxiDataWidth ),
        .AXI4_ID_WIDTH      ( AxiIdWidth   ),
        .AXI4_USER_WIDTH    ( AxiUserWidth ),
        .BUFF_DEPTH_SLAVE   ( 2            ),
        .APB_ADDR_WIDTH     ( 32           )
    ) i_axi2apb_64_32_uart (
        .ACLK      ( clk_i          ),
        .ARESETn   ( rst_ni         ),
        .test_en_i ( 1'b0           ),
        .AWID_i    ( uart.aw_id     ),
        .AWADDR_i  ( uart.aw_addr   ),
        .AWLEN_i   ( uart.aw_len    ),
        .AWSIZE_i  ( uart.aw_size   ),
        .AWBURST_i ( uart.aw_burst  ),
        .AWLOCK_i  ( uart.aw_lock   ),
        .AWCACHE_i ( uart.aw_cache  ),
        .AWPROT_i  ( uart.aw_prot   ),
        .AWREGION_i( uart.aw_region ),
        .AWUSER_i  ( uart.aw_user   ),
        .AWQOS_i   ( uart.aw_qos    ),
        .AWVALID_i ( uart.aw_valid  ),
        .AWREADY_o ( uart.aw_ready  ),
        .WDATA_i   ( uart.w_data    ),
        .WSTRB_i   ( uart.w_strb    ),
        .WLAST_i   ( uart.w_last    ),
        .WUSER_i   ( uart.w_user    ),
        .WVALID_i  ( uart.w_valid   ),
        .WREADY_o  ( uart.w_ready   ),
        .BID_o     ( uart.b_id      ),
        .BRESP_o   ( uart.b_resp    ),
        .BVALID_o  ( uart.b_valid   ),
        .BUSER_o   ( uart.b_user    ),
        .BREADY_i  ( uart.b_ready   ),
        .ARID_i    ( uart.ar_id     ),
        .ARADDR_i  ( uart.ar_addr   ),
        .ARLEN_i   ( uart.ar_len    ),
        .ARSIZE_i  ( uart.ar_size   ),
        .ARBURST_i ( uart.ar_burst  ),
        .ARLOCK_i  ( uart.ar_lock   ),
        .ARCACHE_i ( uart.ar_cache  ),
        .ARPROT_i  ( uart.ar_prot   ),
        .ARREGION_i( uart.ar_region ),
        .ARUSER_i  ( uart.ar_user   ),
        .ARQOS_i   ( uart.ar_qos    ),
        .ARVALID_i ( uart.ar_valid  ),
        .ARREADY_o ( uart.ar_ready  ),
        .RID_o     ( uart.r_id      ),
        .RDATA_o   ( uart.r_data    ),
        .RRESP_o   ( uart.r_resp    ),
        .RLAST_o   ( uart.r_last    ),
        .RUSER_o   ( uart.r_user    ),
        .RVALID_o  ( uart.r_valid   ),
        .RREADY_i  ( uart.r_ready   ),
        .PENABLE   ( uart_penable   ),
        .PWRITE    ( uart_pwrite    ),
        .PADDR     ( uart_paddr     ),
        .PSEL      ( uart_psel      ),
        .PWDATA    ( uart_pwdata    ),
        .PRDATA    ( uart_prdata    ),
        .PREADY    ( uart_pready    ),
        .PSLVERR   ( uart_pslverr   )
    );

    if (InclUART) begin : gen_uart
        apb_uart i_apb_uart (
            .CLK     ( clk_i           ),
            .RSTN    ( rst_ni          ),
            .PSEL    ( uart_psel       ),
            .PENABLE ( uart_penable    ),
            .PWRITE  ( uart_pwrite     ),
            .PADDR   ( uart_paddr[4:2] ),
            .PWDATA  ( uart_pwdata     ),
            .PRDATA  ( uart_prdata     ),
            .PREADY  ( uart_pready     ),
            .PSLVERR ( uart_pslverr    ),
            .INT     (),
            .OUT1N   (                 ), // keep open
            .OUT2N   (                 ), // keep open
            .RTSN    (                 ), // no flow control
            .DTRN    (                 ), // no flow control
            .CTSN    ( 1'b0            ),
            .DSRN    ( 1'b0            ),
            .DCDN    ( 1'b0            ),
            .RIN     ( 1'b0            ),
            .SIN     ( rx_i            ),
            .SOUT    ( tx_o            )
        );
    end else begin
        /* pragma translate_off */
        `ifndef VERILATOR
        mock_uart i_mock_uart (
            .clk_i     ( clk_i        ),
            .rst_ni    ( rst_ni       ),
            .penable_i ( uart_penable ),
            .pwrite_i  ( uart_pwrite  ),
            .paddr_i   ( uart_paddr   ),
            .psel_i    ( uart_psel    ),
            .pwdata_i  ( uart_pwdata  ),
            .prdata_o  ( uart_prdata  ),
            .pready_o  ( uart_pready  ),
            .pslverr_o ( uart_pslverr )
        );
        `endif
        /* pragma translate_on */
    end



endmodule
