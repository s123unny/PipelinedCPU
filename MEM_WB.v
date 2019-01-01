module MEM_WB(
    clk_i      ,
    RegWrite_i ,
    Mem2Reg_i  ,
    RegWrite_o ,
    Mem2Reg_o  ,

    ReadData_i ,
    ALU_data_i ,
	RDaddr_i   ,
    ReadData_o ,
    ALU_data_o ,
	RDaddr_o   ,

	stall_i    ,
);

input clk_i;
input RegWrite_i, Mem2Reg_i, stall_i;
output reg RegWrite_o, Mem2Reg_o;

input [31:0] ReadData_i, ALU_data_i;
output reg [31:0] ReadData_o, ALU_data_o;
input       [4:0]     RDaddr_i;
output reg  [4:0]     RDaddr_o;

always @(posedge clk_i) begin
	if (stall_i == 1'b1) begin
    	RegWrite_o <= RegWrite_o; 
    	Mem2Reg_o <= Mem2Reg_o;
    	ReadData_o <= ReadData_o;
    	ALU_data_o <= ALU_data_o;
		RDaddr_o <= RDaddr_o;
	end
	else begin
    	RegWrite_o <= RegWrite_i; 
    	Mem2Reg_o <= Mem2Reg_i;
    	ReadData_o <= ReadData_i;
    	ALU_data_o <= ALU_data_i;
		RDaddr_o <= RDaddr_i;
	end
end
endmodule
