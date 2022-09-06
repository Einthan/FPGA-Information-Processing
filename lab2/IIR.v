`timescale 1ns / 1ps

module IIR(
clk,
rst,
a,b,c,d,
x,
y
);

input clk,rst;
input[7:0] a,b,c,d;
input[7:0] x;
output[7:0] y;

reg[7:0] x_1; 
reg[7:0] y_1,y_2;

/*************** Your code here ***************/

wire[7:0] r0,r1,r2,r3;

// r0 = a*x;
// r1 = b*x1;
// r2 = c*y1;
// r3 = d*y2
multiply m0(a,x,r0);
multiply m1(b,x_1,r1);

multiply m2(c,y_1,r2);
multiply m3(d,y_2,r3);
// y = a*x + b*x1 + c*y1 + d*y2;
assign y=r0+r1+r2+r3;

always@(posedge clk or negedge rst)begin
    if(~rst)begin
        x_1<=0;
        y_1<=0;
        y_2<=0;
    end
    else begin
        x_1=x;
        y_1<=y;
        y_2<=y_1;
    end
end


/********************* Done *********************/


endmodule
