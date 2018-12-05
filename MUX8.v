module MUX8(
    data2_i,
    select_i,
    data_o
);

output reg	[31:0]	data_o;
input	[31:0]	data2_i;
input	select_i;

always	@(data1_i or data2_i or select_i)
	if	(select_i == 1'b0)
		data_o = 32'b0;
	else
		data_o = data2_i;
endmodule