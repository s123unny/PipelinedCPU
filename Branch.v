module Branch
(
	data1_in,
	data2_in,
    branch_i,
	data_o
);

input	data1_in;
input	data2_in;
output	data_o;

assign	data_o = (data1_in == data2_in && branch_i == 1'b1) ? 1'b1 : 1'b0 ;

endmodule
