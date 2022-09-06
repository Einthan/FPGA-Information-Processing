`timescale 1ns / 1ps

module IIR_unfold(
clk,
rst,
a,b,c,d,
x2k,x2k1,
y2k,y2k1
);

input clk,rst;
input[7:0] a,b,c,d;
input[7:0] x2k,x2k1;
output[7:0] y2k,y2k1;

reg[7:0] x_1[1:0];
reg[7:0] y_1[1:0],y_2[1:0];


/*************** Your code here ***************/
wire[7:0] w0, w1, w2, w3, w4, w5, w6, w7; 

//y2k
multiply m0(a,x2k,w0);
multiply m1(b, x_1[0], w1);
multiply m2(c,y_1[0],w2);
multiply m3(d,y_1[1],w3);

assign y2k = w0+w1+w2+w3;

//y2k1
multiply m4(a,x2k1,w4);
multiply m5(b,x2k, w5);
multiply m6(c,y2k,w6);
multiply m7(d,y_1[0],w7);

assign y2k1 = w4+w6+w7+w5;
//a<=b, b assign to a
always@(posedge clk or negedge rst)begin
    if(~rst)begin
        x_1[0]<=0;
        y_1[0]<=0;
        y_1[1]<=0;
    end
    else begin
        x_1[0]<=x2k1;
        y_1[0]<=y2k1;
        y_1[1]<=y2k;
 
    end
end


/********************* Done *********************/

endmodule
