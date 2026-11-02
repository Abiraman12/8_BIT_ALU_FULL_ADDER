`timescale 1ns/1ps

// 8-bit ALU + memory to store results
// Each memory location holds 10 bits: {zero, carry_borrow, result[7:0]}
module alu8_store (
    input  wire        clk,
    input  wire        we,        // write enable (1 = store ALU output)
    input  wire [3:0]  addr,      // memory address (0 to 15)
    input  wire [7:0]  A,
    input  wire [7:0]  B,
    input  wire [2:0]  opcode,
    output reg  [9:0]  dout       // data read back from memory
);

    // Original ALU (alu8.v is used as it is)
    wire [7:0] result;
    wire       carry_borrow;
    wire       zero;

    alu8 alu (
        .A(A),
        .B(B),
        .opcode(opcode),
        .result(result),
        .carry_borrow(carry_borrow),
        .zero(zero)
    );

    // Memory: 16 locations, 10 bits each
    reg [9:0] mem [0:15];

    always @(posedge clk) begin
        if (we)
            mem[addr] <= {zero, carry_borrow, result};   // store data
        dout <= mem[addr];                               // read data
    end

endmodule
