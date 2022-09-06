`timescale 1ns / 1ps

module kalman_tb(

    );
    
parameter len=2;		// # of reg size.
parameter dsize=16;		// Width of each data.
parameter decimal=10;	// Width of fraction.

reg clk,rst;
reg [dsize-1:0] n;
reg[dsize-1:0] u;
reg[dsize*len-1:0] z;
reg[dsize*len-1:0] x0;
reg[dsize*len*len-1:0] P0;
reg[dsize*len*len-1:0] F,H,Q,R;
reg[dsize*len-1:0] B;
wire[dsize-1:0] no;
wire[dsize*len-1:0] xo;
wire outen;
reg[3:0] i;

kalman k0(
clk,
rst,
n,      // Input: Index of the inputs.
u,      // Input: Scalar: Acceleration.
z,      // Input: 1x2 Z Vector; Measurement of x.
x0,     // Initial state of x.
P0,     // Initial state of P.
F,      // Input: 2x2 F Matrix.
B,      // Input: 2x1 B Vector.
Q,      // Input: 2x2 Q Matrix.
H,      // Input: 2x2 H Matrix.
R,      // Input: 2x2 R Matrix.
no,     // Output: n_out.
xo,     // Output: x_out.
outen   // Output: output enable: a flag signal. 
);

initial begin
i=0;
n = 0;
u=0;
z=0;
x0=1;
P0=0;
F=1012;
H=64'b0000000000000001000000000000000000000000000000000000000000000001;
Q=64'b0000000110011000000000000000000000000000110011000000000000000000;
R=64'b0000000110011000000000000000000000000000110011000000000000000000;
B=901;


clk = 0;
rst = 0;
#4 rst = 1;
end

always #1 begin
    clk<=~clk;
end
always@(posedge clk)begin

    if(rst) begin
    if (i<100) begin
    n = n+1;
    u=u+1;
    z=z+1;
    i=i+1;
    end
    end
end

endmodule
