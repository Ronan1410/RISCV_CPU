//Program Counter
module Program_Counter(clk, rst, PC_in, PC_out);
    input clk, rst;
    input [31:0] PC_in;
    output reg [31:0] PC_out;

    always @(posedge clk or posedge rst)
    begin
        if(rst)
            PC_out <= 32'b0;
        else
            PC_out <= PC_in;
    end
endmodule

//PC + 4

module PCplus4(fromPC, NextoPC);
    input [31:0] fromPC;
    output [31:0] NextoPC;

    assign NextoPC = fromPC + 4;

endmodule

//Instruction Memory

module InstructionMemory(clk, rst, read_address, instruction_out);

    input clk, rst;
    input [31:0] read_address;
    output reg [31:0] instruction_out;
    integer k;

    reg [31:0] instruction_memory [63:0];

    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            for (k = 0; k < 64; k = k + 1) begin
                instruction_memory[k] <= 32'b0;
            end
        end
        else
        instruction_out <= instruction_memory[read_address];
    end
endmodule

//Register File

module RegisterFile(clk, rst, RegWrite, Reg1, Reg2, destination_reg, write_data, read_data1, read_data2);

    input clk, rst, RegWrite;
    input [4:0] Reg1, Reg2, destination_reg;
    input [31:0] write_data;
    output reg [31:0] read_data1, read_data2;
    integer k;

    reg [31:0] Registers[31:0];

    always @(posedge clk or posedge rst)
    begin
        if (rst)
        begin
            for (k = 0; k < 32; k = k + 1) begin
                Registers[k] <= 32'b0;
            end
        end
        else if (RegWrite)
        begin
            Registers[destination_reg] <= write_data;
        end
    end

    assign read_data1 = Registers[Reg1];
    assign read_data2 = Registers[Reg2];

endmodule

// Immediate Generator
module Immediate_Generator(Opcode, instruction, Immediate_extent);

    input [7:0] Opcode;
    input [31:0] instruction;
    output [31:0] Immediate_extent;

    always @(*)
    begin
        case (Opcode)
            7'b0000011: // I-type
                Immediate_extent = {{20{instruction[31]}}, instruction[31:20]};
            7'b0100011: // S-type
                Immediate_extent = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            7'b1100011: // B-type
                Immediate_extent = {{19{instruction[31]}}, instruction[31], instruction[30:25], instruction[11:0], 1'b0};
        endcase
    end

endmodule

//Control Unit
module Control_Unit(instruction, Branch, MemRead, MemToReg, ALUOp, MemWrite, ALUSrc, RegWrite);

    input [6:0] instruction;
    output Branch, MemRead, MemToReg, MemWrite, ALUSrc, RegWrite;
    output [1:0] ALUOp;

    always @(*)
    begin
        case(instruction)
            7'b0110011: //R-type
            {
                ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp
            } <= 8'b001000_01;

            7'b0000011: //I-type
            {
                ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp
            } <= 8'111100_00;

            7'b0100011: //S-type
            {
                ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp
            } <= 8'b100010_00;

            7'b1100011: //B-type
            {
                ALUSrc, MemToReg, RegWrite, MemRead, MemWrite, Branch, ALUOp
            } <= 8'b000001_01;
        endcase
    end
endmodule


//ALU

module ALU_unit(A, B, Control_in, ALU_Result, zero);

    input [31:0] A, B;
    input [3;0] Control_in;
    output reg [31:0] ALU_Result;
    output reg zero;

    always @(control_in, or A or B)
    begin
        case(Control_in)
            4'b0000: //AND
            begin
                zero <= 0;
                ALU_Result <= A & B;
            end
            4'b0001: //OR
            begin
                zero <= 0;
                ALU_Result <= A | B;
            end
            4'b0010: //ADD
            begin
                zero <= 0;
                ALU_Result <= A + B;
            end
            4'b0110: //SUB
            begin
                if (A == B)
                    zero <= 1;
                else
                    zero <= 0;

                ALU_Result <= A - B;
            end
        endcase
    end
endmodule