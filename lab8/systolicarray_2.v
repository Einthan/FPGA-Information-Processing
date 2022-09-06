
`timescale 1ns / 1ps

module systolicarray_2(
clk,
rst,
mi0,
mi1,
mo
    );

parameter size=8;
parameter decimal=4;

input clk,rst;


input[4*size-1:0] mi0;
input[4*size-1:0] mi1;
output wire[4*size-1:0] mo;

reg[4*size-1:0] mor;
reg [8:0] state;

reg[size-1:0] umi1[3:0];
reg[size-1:0] umi2[3:0];
reg[size-1:0] uai[3:0];
wire[size-1:0] uoutmi1[3:0];
wire[size-1:0] uoutmi2[3:0];
wire[size-1:0] uout[3:0];


systolicarray_2_unit u0(clk,rst,umi1[0],umi2[0],uai[0],uoutmi1[0],uoutmi2[0],uout[0]);
systolicarray_2_unit u1(clk,rst,umi1[1],umi2[1],uai[1],uoutmi1[1],uoutmi2[1],uout[1]);
systolicarray_2_unit u2(clk,rst,umi1[2],umi2[2],uai[2],uoutmi1[2],uoutmi2[2],uout[2]);
systolicarray_2_unit u3(clk,rst,umi1[3],umi2[3],uai[3],uoutmi1[3],uoutmi2[3],uout[3]);


assign mo = mor;

always@(posedge clk or negedge rst)begin
    if(~rst)begin
    // Start of your code.  
        mor<=0;    
        state<=0;
        uai[0]<=0;
        uai[1]<=0;
        uai[2]<=0;
        uai[3]<=0;
        umi1[0]<=0;
        umi1[1]<=0;
        umi1[2]<=0;
        umi1[3]<=0;
        umi2[0]<=0;
        umi2[1]<=0;
        umi2[2]<=0;
        umi2[3]<=0;
    // End of your code.
    end
    else begin
    // Start of your code.
    case(state) 
        0:begin   //a1,1
            umi1[0]<=mi0[7:0];
            umi2[0]<=mi1[7:0];
           
            state<=1;
            end
         1:begin
         
         //a12*b21
            umi1[0]<=mi0[15:8];
            umi2[0]<=mi1[23:16];
      
            state<=2;
            end
           2:begin
               //a21*b12
                umi1[2]<=mi0[23:16];
                umi2[1]<=mi1[15:8];
            
                //get the update uout from state 0
                umi1[1]<=uoutmi1[0];
                umi2[2]<=uoutmi2[0];
                state<=3;
            end
          3: begin
                umi1[2]<=mi0[31:24];//a22,b22
                umi2[1]<=mi1[31:24];
                
                mor[7:0]<=uout[0];//out c11
                umi1[1]<=uoutmi1[0];//get update from state1
                umi2[2]<=uoutmi2[0];
                state<=4;
            end
          4: begin   
                   umi1[3]<=uoutmi1[2];//update from state2
                   umi2[3]<=uoutmi2[1];
                state<=5;
            end
           5: begin
                umi1[3]<=uoutmi1[2];//update from state 3
                umi2[3]<=uoutmi2[1];
                mor[15:8]<=uout[1];//outc12,c21
                mor[23:16]<=uout[2];
                state<=6;
                end
           6: begin
                state<=7;
                end
           7:begin
                mor[31:24]<=uout[3];//out c22
                state<=8;
                end
           8:begin 
                //wait a state for output
             end
        endcase 
    // End of your code.
       end
end

endmodule
