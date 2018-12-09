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
output reg  [1:0]  ForwardA_o;
output reg  [1:0]  ForwardB_o;

always @(EX_MEM_RegisterRd_i or EX_MEM_RegWrite_i or MEM_WB_RegisterRd_i or MEM_WB_RegWrite_i or ID_EX_RS_i or ID_EX_RT_i) begin
    ForwardA_o <= 2'b00; 
    ForwardB_o <= 2'b00;
    if (EX_MEM_RegWrite_i == 1'b1 && EX_MEM_RegisterRd_i != 5'b0 && EX_MEM_RegisterRd_i == ID_EX_RS_i) begin
        ForwardA_o <= 2'b10; 
    end
    else if (MEM_WB_RegWrite_i == 1'b1 && MEM_WB_RegisterRd_i != 5'b0 && MEM_WB_RegisterRd_i == ID_EX_RS_i)  begin
        ForwardA_o <= 2'b01; 
    end
    else begin
        ForwardA_o <= 2'b00;
    end

    if (EX_MEM_RegWrite_i == 1'b1 && EX_MEM_RegisterRd_i != 5'b0 && EX_MEM_RegisterRd_i == ID_EX_RT_i) begin
        ForwardB_o <= 2'b10; 
    end
    else if (MEM_WB_RegWrite_i == 1'b1 && MEM_WB_RegisterRd_i != 5'b0 && MEM_WB_RegisterRd_i == ID_EX_RT_i)  begin
        ForwardB_o <= 2'b01; 
    end
    else begin
        ForwardB_o <= 2'b00;
    end
    // ForwardA_o <= (EX_MEM_RegWrite_i == 1'b1 && 
    //                 EX_MEM_RegisterRd_i != 5'b0 &&
    //                 EX_MEM_RegisterRd_i == ID_EX_RS_i) ? 2'b10 : 
    //                 (MEM_WB_RegWrite_i == 1'b1 &&
    //                 MEM_WB_RegisterRd_i != 5'b0 &&
    //                 MEM_WB_RegisterRd_i == ID_EX_RS_i) ? 2'b01 :
    //                 2'b00;
    // ForwardB_o <= (EX_MEM_RegWrite_i == 1'b1 && 
    //                 EX_MEM_RegisterRd_i != 5'b0 &&
    //                 EX_MEM_RegisterRd_i == ID_EX_RT_i) ? 2'b10 : 
    //                 (MEM_WB_RegWrite_i == 1'b1 &&
    //                 MEM_WB_RegisterRd_i != 5'b0 &&
    //                 MEM_WB_RegisterRd_i == ID_EX_RT_i) ? 2'b01 :
    //                 2'b00;
end

endmodule

