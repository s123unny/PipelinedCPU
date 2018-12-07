module Sign_Extend(
    instruction     ,
    data_o     
);

input [31:0] instruction;
output reg [31:0] data_o;

always @(instruction) begin
	if (instruction == 7'b0100011) begin //s type
		data_o <= {{20{data_i[31]}},data_i[30:25],data_i[11:7]};	
	end
	else begin
		data_o <= {{20{data_i[31]}}, data_i[30:20]};
	end
end

assign 

endmodule