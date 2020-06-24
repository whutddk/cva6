// Copyright 2018 - 2019 ETH Zurich and University of Bologna.
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//
// Author: Florian Zaruba <zarubaf@iis.ee.ethz.ch>
// Description: Instruction Re-aligner
//
// This module takes 32-bit aligned cache blocks and extracts the instructions.
// As we are supporting the compressed instruction set extension in a 32 bit instruction word
// are up to 2 compressed instructions.
// Furthermore those instructions can be arbitrarily interleaved which makes it possible to fetch
// only the lower part of a 32 bit instruction.
// Furthermore we need to handle the case if we want to start fetching from an unaligned
// instruction e.g. a branch.

import ariane_pkg::*;

module instr_realign (
    input  logic                              clk_i,
    input  logic                              rst_ni,
    input  logic                              flush_i,
    input  logic                              valid_i,
    output logic                              serving_unaligned_o, // we have an unaligned instruction in [0]
    input  logic [riscv::VLEN-1:0]            address_i,
    input  logic [FETCH_WIDTH-1:0]            data_i,
    output logic [INSTR_PER_FETCH-1:0]        valid_o,
    output logic [INSTR_PER_FETCH-1:0][riscv::VLEN-1:0]  addr_o,
    output logic [INSTR_PER_FETCH-1:0][31:0]  instr_o
);
    // as a maximum we support a fetch width of 64-bit, hence there can be 4 compressed instructions
    logic [3:0] instr_is_compressed;

    for (genvar i = 0; i < INSTR_PER_FETCH; i ++) begin
        // LSB != 2'b11
        assign instr_is_compressed[i] = ~&data_i[i * 16 +: 2];
    end

    // save the unaligned part of the instruction to this ff
    logic [15:0] unaligned_instr_d,   unaligned_instr_q;
    // the last instruction was unaligned
    logic unaligned_d, unaligned_q;
    // register to save the unaligned address
    logic [riscv::VLEN-1:0] unaligned_address_d, unaligned_address_q;
    // we have an unaligned instruction
    assign serving_unaligned_o = unaligned_q;

    // Instruction re-alignment
    if (FETCH_WIDTH == 32) begin : realign_bp_32
        always_comb begin : re_align
            unaligned_d = unaligned_q;
            unaligned_address_d = {address_i[riscv::VLEN-1:2], 2'b10};
            unaligned_instr_d = data_i[31:16];

            valid_o[0] = valid_i;
            instr_o[0] = (unaligned_q) ? {data_i[15:0], unaligned_instr_q} : data_i[31:0];
            addr_o[0]  = (unaligned_q) ? unaligned_address_q : address_i;

            valid_o[1] = 1'b0;
            instr_o[1] = '0;
            addr_o[1]  = {address_i[riscv::VLEN-1:2], 2'b10};

            // this instruction is compressed or the last instruction was unaligned
            // 这里是指令没有对齐
            if (instr_is_compressed[0] || unaligned_q) begin //前面是16指令，或32未对齐，没有对齐
                // check if this is instruction is still unaligned e.g.: it is not compressed
                // if its compressed re-set unaligned flag
                // for 32 bit we can simply check the next instruction and whether it is compressed or not
                // if it is compressed the next fetch will contain an aligned instruction
                // is instruction 1 also compressed
                // yes? -> no problem, no -> we've got an unaligned instruction
                if (instr_is_compressed[1]) begin //后面是压缩指令，再下一次就对齐了
                    unaligned_d = 1'b0;
                    valid_o[1] = valid_i;
                    instr_o[1] = {16'b0, data_i[31:16]};
                end else begin                     //后面不是压缩指令
                    // save the upper bits for next cycle
                    unaligned_d = 1'b1;
                    unaligned_instr_d = data_i[31:16];
                    unaligned_address_d = {address_i[riscv::VLEN-1:2], 2'b10};
                end
            end // else -> normal fetch

            // we started to fetch on a unaligned boundary with a whole instruction -> wait until we've
            // received the next instruction
            //这里是地址没有对齐
            if (valid_i && address_i[1]) begin
                // the instruction is not compressed so we can't do anything in this cycle
                if (!instr_is_compressed[0]) begin
                    valid_o = '0;
                    unaligned_d = 1'b1;
                    unaligned_address_d = {address_i[riscv::VLEN-1:2], 2'b10};
                    unaligned_instr_d = data_i[15:0];
                // the instruction isn't compressed but only the lower is ready
                end else begin
                    valid_o = 1'b1;
                end
            end
        end
    

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (~rst_ni) begin
            unaligned_q         <= 1'b0;
            unaligned_address_q <= '0;
            unaligned_instr_q   <= '0;
        end else begin
            if (valid_i) begin
                unaligned_address_q <= unaligned_address_d;
                unaligned_instr_q   <= unaligned_instr_d;
            end

            if (flush_i) begin
                unaligned_q <= 1'b0;
            end else if (valid_i) begin
                unaligned_q <= unaligned_d;
            end
        end
    end
endmodule
