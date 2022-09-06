`timescale 1ns / 1ps

module butterfly_time(
Fer,	// Real part of the even input.
Fei,	// Imag part of the even input.
For,	// Real part of the odd input.
Foi,	// Imag part of the odd input.
Wr,		// Real part of the weight input.
Wi,		// Imag part of the weight input.
o0r,	// Real part of output 0.
o0i,	// Imag part of output 0.
o1r,	// Real part of output 1.
o1i		// Imag part of output 1.
    );

parameter width=8;
parameter decimal=4;

input[width-1:0] Fer,Fei,For,Foi,Wr,Wi;
output[width-1:0] o0r,o0i,o1r,o1i;

wire[7:0] m0,m1,m2,m3,mr,mi;
// multiplication of complex numbers: m = Fo*W 
multiply #(.width(width),.decimal(decimal)) mp0(For,Wr,m0);
multiply #(.width(width),.decimal(decimal)) mp1(For,Wi,m1);
multiply #(.width(width),.decimal(decimal)) mp2(Foi,Wr,m2);
multiply #(.width(width),.decimal(decimal)) mp3(Foi,Wi,m3);

assign mr=m0-m3;
assign mi=m1+m2;

assign o0r=Fer+mr;
assign o0i=Fei+mi;

assign o1r=Fer-mr;
assign o1i=Fei-mi;

endmodule


module butterfly_freq(
f0r,	// Real part of input 0.
f0i,	// Imag part of input 0.
f1r,	// Real part of input 1.
f1i,	// Imag part of input 1.
Wr,		// Real part of the weight input.
Wi,		// Imag part of the weight input.
o0r,	// Real part of output 0.
o0i,	// Imag part of output 0.
o1r,	// Real part of output 1.
o1i		// Imag part of output 1.
    );

parameter width=8;
parameter decimal=4;

input[width-1:0] f0r,f0i,f1r,f1i,Wr,Wi;
output[width-1:0] o0r,o0i,o1r,o1i;

// Start of your code
wire[7:0] m4,m5,m6,m7,r,i;

assign r = f0r - f1r;
assign i = f0i -f1i;
// multiplication of complex numbers: m = Fo*W 

multiply #(.width(width),.decimal(decimal)) mp4(r,Wr,m4);
multiply #(.width(width),.decimal(decimal)) mp5(i,Wi,m5);
multiply #(.width(width),.decimal(decimal)) mp6(r,Wi,m6);
multiply #(.width(width),.decimal(decimal)) mp7(i,Wr,m7);

//imaginary is 0
assign o0r= f0r+f1r;
assign o0i= f0i+f1i;

assign o1r=m4-m5;
assign o1i=m6+m7;

// End of your code

endmodule