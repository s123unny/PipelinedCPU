module Forwarding_Unit(
    EX_MEM_RegisterRd_i ,
    EX_MEM_RegWrite_i   ,
    MEM_WB_RegisterRd_i ,
    MEM_WB_RegWrite_i   ,
    ID_EX_RS_i ,
    ID_EX_RT_i ,
    ForwardA_o  ,
    ForwardB_o  ,
);

input   EX_MEM_RegWrite_i, MEM_WB_RegWrite_i;
input   [4:0]  EX_MEM_RegisterRd_i, MEM_WB_RegisterRd_i;
input   [4:0]  ID_EX_RS_i, ID_EX_RT_i;
output   [1:0]  ForwardA_o;
output   [1:0]  ForwardB_o;

assign ForwardA_o = (EX_MEM_RegWrite_i == 1'b1 && 
                    EX_MEM_RegisterRd_i != 5'b0 &&
                    EX_MEM_RegisterRd_i == ID_EX_RS_i) ? 2'b10 : 
                    (MEM_WB_RegWrite_i == 1'b1 &&
                    MEM_WB_RegisterRd_i != 5'b0 &&
                    MEM_WB_RegisterRd_i == ID_EX_RS_i) ? 2'b01 :
                    2'b00;
assign ForwardB_o = (EX_MEM_RegWrite_i == 1'b1 && 
                    EX_MEM_RegisterRd_i != 5'b0 &&
                    EX_MEM_RegisterRd_i == ID_EX_RT_i) ? 2'b10 : 
                    (MEM_WB_RegWrite_i == 1'b1 &&
                    MEM_WB_RegisterRd_i != 5'b0 &&
                    MEM_WB_RegisterRd_i == ID_EX_RT_i) ? 2'b01 :
                    2'b00;

endmodule
