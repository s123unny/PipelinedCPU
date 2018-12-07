module Sign_Extend(
    instruction     ,
    data_o     
);

input [31:0] instruction;
output reg [31:0] data_o;

always @(instruction) begin
	if (instruction == 7'b0100011) begin //s type
		data_o <= {{21{instruction[31]}},instruction[30:25],instruction[11:7]};	
	end
	else begin
		data_o <= {{21{instruction[31]}}, instruction[30:20]};
	end
end

endmodule
