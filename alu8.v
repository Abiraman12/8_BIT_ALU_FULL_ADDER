`timescale 1ns/1ps

//==================================================
// 1-bit Full Adder
//==================================================
module full_adder (
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);

assign sum  = a ^ b ^ cin;
assign cout = (a & b) | (b & cin) | (a & cin);

endmodule


//==================================================
// 8-bit ALU (ripple-carry adder built from 8 full adders)
//
// opcode  operation
// 000     ADD
// 001     SUBTRACT   (A - B  =  A + ~B + 1)
// 010     AND
// 011     OR
// 100     XOR
// others  result = 0
//==================================================
module alu8 (
    input  [7:0] A,
    input  [7:0] B,
    input  [2:0] opcode,
    output reg [7:0] result,
    output reg       carry_borrow,
    output reg       zero
);

// ---------- Adder / Subtractor section ----------
wire       sub_en;          // 1 when opcode = SUBTRACT
wire [7:0] B_mod;           // B or ~B
wire [8:0] c;               // carry chain: c[0] = cin, c[8] = final carry out
wire [7:0] sum;             // adder output

assign sub_en = (opcode == 3'b001);
assign B_mod  = B ^ {8{sub_en}};   // invert B for subtraction
assign c[0]   = sub_en;            // +1 for two's complement

genvar i;
generate
    for (i = 0; i < 8; i = i + 1) begin : FA_CHAIN
        full_adder fa (
            .a   (A[i]),
            .b   (B_mod[i]),
            .cin (c[i]),
            .sum (sum[i]),
            .cout(c[i+1])
        );
    end
endgenerate

// ---------- Operation select ----------
always @(*) begin

    result       = 8'b00000000;
    carry_borrow = 1'b0;

    case (opcode)

        3'b000: begin
            // ADD
            result       = sum;
            carry_borrow = c[8];        // carry out
        end

        3'b001: begin
            // SUBTRACT
            result       = sum;
            carry_borrow = ~c[8];       // borrow = NOT carry out  (1 when A < B)
        end

        3'b010: begin
            // AND
            result = A & B;
        end

        3'b011: begin
            // OR
            result = A | B;
        end

        3'b100: begin
            // XOR
            result = A ^ B;
        end

        default: begin
            result       = 8'b00000000;
            carry_borrow = 1'b0;
        end

    endcase

    // Zero flag
    if (result == 8'b00000000)
        zero = 1'b1;
    else
        zero = 1'b0;

end

endmodule
