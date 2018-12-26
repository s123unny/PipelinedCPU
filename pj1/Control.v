module Control(
    Op_i       ,
    ALUOp_o    ,
    ALUSrc_o   ,
    RegWrite_o ,
    MemWrite_o ,
    MemRead_o  ,
    Mem2Reg_o  ,
    Branch_o   ,
);

input [6:0] Op_i;
output reg ALUSrc_o, RegWrite_o, MemWrite_o, MemRead_o, Mem2Reg_o, Branch_o;
output reg [1:0] ALUOp_o;

//0100011 sw 00
//0000011 lw 00
//1100011 beq 01
//0010011 addi 11
//0110011 R 10
always @(Op_i) begin
	if (Op_i == 7'b0010011) begin //immd
		ALUOp_o <= 2'b11;
		ALUSrc_o <= 1'b1;
		RegWrite_o <= 1'b1;
		MemWrite_o <= 1'b0;
		MemRead_o <= 1'b0;
		Mem2Reg_o <= 1'b0;
		Branch_o <= 1'b0;
	end
	else if (Op_i == 7'b1100011) begin //beq
		ALUOp_o <= 2'b01;
		ALUSrc_o <= 1'b0;
		RegWrite_o <= 1'b0;
		MemWrite_o <= 1'b0;
		MemRead_o <= 1'b0;
		Mem2Reg_o <= 1'b0;
		Branch_o <= 1'b1;
	end
	else if (Op_i == 7'b0110011) begin //R
		ALUOp_o <= 2'b10;
		ALUSrc_o <= 1'b0;
		RegWrite_o <= 1'b1;
		MemWrite_o <= 1'b0;
		MemRead_o <= 1'b0;
		Mem2Reg_o <= 1'b0;
		Branch_o <= 1'b0;
	end
	else if (Op_i == 7'b0000000) begin //no instruction
		ALUOp_o <= 2'b00;
		ALUSrc_o <= 1'b1;
		RegWrite_o <= 1'b0;
		MemWrite_o <= 1'b0;
		MemRead_o <= 1'b0;
		Mem2Reg_o <= 1'b0;
		Branch_o <= 1'b0;
	end
	else begin //sw lw
		ALUOp_o <= 2'b00;
		ALUSrc_o <= 1'b1;
		Branch_o <= 1'b0;
		if (Op_i == 7'b0100011) begin //sw
			RegWrite_o <= 1'b0;
			MemWrite_o <= 1'b1;
			MemRead_o <= 1'b0;
			Mem2Reg_o <= 1'b0;
		end
		else begin
			RegWrite_o <= 1'b1; //lw
			MemWrite_o <= 1'b0;
			MemRead_o <= 1'b1;
			Mem2Reg_o <= 1'b1;
		end
	end
	
end
endmodule

