`timescale 1ns/1ps

module alu8_store_tb;

    reg         clk, we;
    reg  [3:0]  addr;
    reg  [7:0]  A, B;
    reg  [2:0]  opcode;
    wire [9:0]  dout;          // {zero, carry_borrow, result[7:0]}

    alu8_store uut (
        .clk(clk),
        .we(we),
        .addr(addr),
        .A(A),
        .B(B),
        .opcode(opcode),
        .dout(dout)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    // Call this task to run the ALU and STORE the result at address ad
    task store_result(input [7:0] a_in, input [7:0] b_in,
                      input [2:0] op,   input [3:0] ad);
        begin
            @(negedge clk);
            A = a_in; B = b_in; opcode = op; addr = ad; we = 1;
            @(negedge clk);
            we = 0;
        end
    endtask

    // Call this task to READ the stored result from address ad
    task read_result(input [3:0] ad);
        begin
            @(negedge clk);
            addr = ad; we = 0;
            @(negedge clk);
            $display("  %2d    %b    %3d       %b          %b",
                     ad, dout[7:0], dout[7:0], dout[8], dout[9]);
        end
    endtask

    integer i;

    initial begin
        clk = 0; we = 0; addr = 0; A = 0; B = 0; opcode = 0;

        // ---------------- STORE ----------------
        store_result(8'd25,  8'd10,  3'b000, 4'd0);    // ADD : 25 + 10
        store_result(8'd255, 8'd1,   3'b000, 4'd1);    // ADD : 255 + 1 (carry)
        store_result(8'd200, 8'd100, 3'b000, 4'd2);    // ADD : 200 + 100 (carry)
        store_result(8'd50,  8'd20,  3'b001, 4'd3);    // SUB : 50 - 20
        store_result(8'd20,  8'd50,  3'b001, 4'd4);    // SUB : 20 - 50 (borrow)
        store_result(8'd100, 8'd100, 3'b001, 4'd5);    // SUB : 100 - 100 (zero)
        store_result(8'hCA,  8'hA6,  3'b010, 4'd6);    // AND : CA & A6
        store_result(8'hCA,  8'hA6,  3'b011, 4'd7);    // OR  : CA | A6
        store_result(8'hCA,  8'hA6,  3'b100, 4'd8);    // XOR : CA ^ A6
        store_result(8'hF0,  8'h0F,  3'b010, 4'd9);    // AND : F0 & 0F (zero)
        store_result(8'hFF,  8'hFF,  3'b111, 4'd10);   // Invalid opcode

        // ---------------- READ BACK ----------------
        $display("=====================================================");
        $display("       STORED 8-BIT ALU RESULTS (read from memory)");
        $display("=====================================================");
        $display("  Addr    Result     Dec   Carry/Borrow  Zero");
        $display("-----------------------------------------------------");

        for (i = 0; i < 11; i = i + 1)
            read_result(i[3:0]);

        $display("=====================================================");
        #10 $finish;
    end

endmodule
