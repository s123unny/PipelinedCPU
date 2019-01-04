module ALU_Control(
    funct_i    ,
    ALUOp_i    ,
    ALUCtrl_o  
);

input [9:0] funct_i;
input [1:0] ALUOp_i;
output reg [2:0] ALUCtrl_o;


always @(funct_i or ALUOp_i) begin
	if (ALUOp_i == 2'b11) begin //addi
		ALUCtrl_o = 3'b010;
	end
	else if (ALUOp_i == 2'b01) begin
		ALUCtrl_o = 3'b110; //sub
	end
	else if (ALUOp_i == 2'b00) begin
		ALUCtrl_o = 3'b010; //add
	end
	else begin //10 R
		case (funct_i)
			10'b0000000000: ALUCtrl_o <= 3'b010; //add
			10'b0000001000: ALUCtrl_o <= 3'b100; //mul
			10'b0100000000: ALUCtrl_o <= 3'b110; //sub
			10'b0000000111: ALUCtrl_o <= 3'b000; //and
			10'b0000000110: ALUCtrl_o <= 3'b001; //or
			default:ALUCtrl_o <= 3'b000;
		endcase
	end
end
endmodule