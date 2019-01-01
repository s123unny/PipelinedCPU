module ID_EX(
    clk_i      ,
    ALUOp_i    ,
    ALUSrc_i   ,
    RegWrite_i ,
    MemWrite_i ,
    MemRead_i  ,
    Mem2Reg_i  ,
    Branch_i   ,
    ALUOp_o    ,
	ALUSrc_o   ,
    RegWrite_o ,
    MemWrite_o ,
    MemRead_o  ,
    Mem2Reg_o  ,
    Branch_o   ,

    RSdata_i   ,
    RTdata_i   ,
    imm_i      ,
    funct_i    ,
    RDaddr_i   ,
    RSdata_o   ,
    RTdata_o   ,
    imm_o      ,
    funct_o    ,
    RDaddr_o   ,

    RSaddr_i   ,
    RTaddr_i   ,
    RSaddr_o   ,
    RTaddr_o   ,

	stall_i    ,
);

input                   clk_i;
input       [1:0]       ALUOp_i;
input ALUSrc_i, RegWrite_i, MemWrite_i, MemRead_i, Mem2Reg_i, Branch_i, stall_i;
output reg  [1:0]       ALUOp_o;
output reg  ALUSrc_o, RegWrite_o, MemWrite_o, MemRead_o, Mem2Reg_o, Branch_o;

input       [31:0]      pc_i;
output reg  [31:0]      pc_o;

input       [31:0]       RSdata_i;
input       [31:0]       RTdata_i;
input       [31:0]      imm_i;
input       [9:0]       funct_i;
input       [4:0]       RDaddr_i;

output reg  [31:0]       RSdata_o;
output reg  [31:0]       RTdata_o;
output reg  [31:0]       imm_o;
output reg  [9:0]       funct_o;
output reg  [4:0]       RDaddr_o;

input       [4:0]       RSaddr_i, RTaddr_i;
output reg  [4:0]       RSaddr_o, RTaddr_o;

always @(posedge clk_i) begin
	if (stall_i == 1'b1) begin
    	ALUOp_o <= ALUOp_o;
		ALUSrc_o <= ALUSrc_o;
    	RegWrite_o <= RegWrite_o; 
    	MemWrite_o <= MemWrite_o; 
    	MemRead_o <= MemRead_o; 
    	Mem2Reg_o <= Mem2Reg_o;
    	RSdata_o <= RSdata_o;
    	RTdata_o <= RTdata_o;
    	imm_o <= imm_o;
		funct_o <= funct_o;
    	RDaddr_o <= RDaddr_o;
    	Branch_o <= Branch_o;
    	RSaddr_o <= RSaddr_o;
    	RTaddr_o <= RTaddr_o;
	end
	else begin
    	ALUOp_o <= ALUOp_i;
		ALUSrc_o <= ALUSrc_i;
    	RegWrite_o <= RegWrite_i; 
    	MemWrite_o <= MemWrite_i; 
    	MemRead_o <= MemRead_i; 
    	Mem2Reg_o <= Mem2Reg_i;
    	RSdata_o <= RSdata_i;
    	RTdata_o <= RTdata_i;
    	imm_o <= imm_i;
		funct_o <= funct_i;
    	RDaddr_o <= RDaddr_i;
    	Branch_o <= Branch_i;
    	RSaddr_o <= RSaddr_i;
    	RTaddr_o <= RTaddr_i;
	end
	
end
endmodule
