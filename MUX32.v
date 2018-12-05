module MUX32(
    data1_i    ,
    data2_i    ,
    data3_i    ,
    select_i   ,
    data_o     
);

input [31:0] data1_i;
input [31:0] data2_i;
input [31:0] data3_i;
input select_i;
output reg [31:0] data_o;

always @(data1_i or data2_i or data3_i or select_i) begin
	if (select_i == 2'b00) begin // operand come from register file
		data_o <= data1_i;
	end
    else if (select_i == 2'b01) begin // operand come from data memory
        data_o <= data2_i;
    end
	else if (select_i == 2'b10) begin //operand come from previous ALU result
		data_o <= data3_i;
	end
end

endmodule
