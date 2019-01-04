module MUX8(
    data_i,
    select_i,
    data_o
);

output reg	[7:0]	data_o;
input	[7:0]	data_i;
input	select_i;

always	@(data_i or select_i)
	//if	(select_i == 1'b1)
	//	data_o <= 8'b0;
	//else
		data_o <= data_i;
endmodule
