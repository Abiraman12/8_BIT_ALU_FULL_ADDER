`timescale 1ns/1ps

module alu8_tb;

reg [7:0] A;
reg [7:0] B;
reg [2:0] opcode;

wire [7:0] result;
wire       carry_borrow;
wire       zero;

alu8 uut (
    .A(A),
    .B(B),
    .opcode(opcode),
    .result(result),
    .carry_borrow(carry_borrow),
    .zero(zero)
);

initial begin

    $display("=====================================================================");
    $display("                        8-BIT ALU SIMULATION");
    $display("=====================================================================");
    $display("Time      A          B         OP     Result      Carry/Borrow Zero");
    $display("---------------------------------------------------------------------");

    $monitor("%4t   %b  %b   %b   %b      %b        %b",
             $time, A, B, opcode, result, carry_borrow, zero);

    // ADD: 25 + 10 = 35
    A = 8'd25;
    B = 8'd10;
    opcode = 3'b000;
    #20;

    // ADD: 255 + 1 = 0 with carry
    A = 8'd255;
    B = 8'd1;
    opcode = 3'b000;
    #20;

    // ADD: 200 + 100 = 300 -> 44 with carry
    A = 8'd200;
    B = 8'd100;
    opcode = 3'b000;
    #20;

    // SUB: 50 - 20 = 30
    A = 8'd50;
    B = 8'd20;
    opcode = 3'b001;
    #20;

    // SUB: 20 - 50 = 226 (-30 in 2's complement) with borrow
    A = 8'd20;
    B = 8'd50;
    opcode = 3'b001;
    #20;

    // SUB: 100 - 100 = 0 (zero flag)
    A = 8'd100;
    B = 8'd100;
    opcode = 3'b001;
    #20;

    // AND: 0xCA & 0xA6 = 0x82
    A = 8'hCA;
    B = 8'hA6;
    opcode = 3'b010;
    #20;

    // OR: 0xCA | 0xA6 = 0xEE
    A = 8'hCA;
    B = 8'hA6;
    opcode = 3'b011;
    #20;

    // XOR: 0xCA ^ 0xA6 = 0x6C
    A = 8'hCA;
    B = 8'hA6;
    opcode = 3'b100;
    #20;

    // AND zero result demonstration: 0xF0 & 0x0F = 0
    A = 8'hF0;
    B = 8'h0F;
    opcode = 3'b010;
    #20;

    // Invalid opcode -> result = 0
    A = 8'hFF;
    B = 8'hFF;
    opcode = 3'b111;
    #20;

    $display("=====================================================================");
    $display("                        SIMULATION COMPLETED");
    $display("=====================================================================");

    $stop;

end

endmodule
