`timescale 1ns / 1ps

module kalman(
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

parameter len=2;		// # of input size.
parameter dsize=16;		// Width of each data.
parameter decimal=10;	// Width of fraction.

parameter umat=64'b0000000000000001000000000000000000000000000000000000000000000001; //unit matrix

input clk,rst;
input[dsize-1:0] n;
input[dsize-1:0] u;
input[dsize*len-1:0] z;
input[dsize*len-1:0] x0;
input[dsize*len*len-1:0] P0;
input[dsize*len*len-1:0] F,H,Q,R;
input[dsize*len-1:0] B;
output reg[dsize-1:0] no;
output reg[dsize*len-1:0] xo;
output reg outen;


reg[dsize-1:0] mi[1:0][3:0];
wire[dsize-1:0] mo[3:0];

wire[dsize*2*2-1:0] mmin1;
wire[dsize*2*2-1:0] mmin2;
wire[dsize*2*2-1:0] mmout;

assign mmin1[dsize-1:0]=mi[0][0];            
assign mmin1[2*dsize-1:dsize]=mi[0][1];
assign mmin1[3*dsize-1:2*dsize]=mi[0][2];
assign mmin1[4*dsize-1:3*dsize]=mi[0][3];

assign mmin2[dsize-1:0]=mi[1][0];
assign mmin2[2*dsize-1:dsize]=mi[1][1];
assign mmin2[3*dsize-1:2*dsize]=mi[1][2];
assign mmin2[4*dsize-1:3*dsize]=mi[1][3];

assign mo[0]=mmout[dsize-1:0];
assign mo[1]=mmout[2*dsize-1:dsize];
assign mo[2]=mmout[3*dsize-1:2*dsize];
assign mo[3]=mmout[4*dsize-1:3*dsize];


/////////////////////////////////////////////////////////////////////
//  | mo[0] mo[1] |     | mi[0][0] mi[0][1] |   | mi[1][0] mi[1][1] |
//  | mo[2] mo[3] | =   | mi[0][2] mi[0][3] | x | mi[1][2] mi[1][3] |
/////////////////////////////////////////////////////////////////////
matmul22 #(.size(dsize),.decimal(decimal)) mm0(mmin1,mmin2,mmout);

reg[dsize-1:0] divin;
wire[dsize-1:0] divout;

// divout = 1 / divin.
divider #(.size(dsize),.decimal(decimal)) d0(divin,divout);


 reg[dsize-1:0] nk;
 reg zenk;
 reg[dsize*len-1:0] uk,zk,xkm,xkp,yk;    // Vector; Width = 16x2 = 32.
 reg[dsize*len*len-1:0] Pkm,Kk,Pkp;      // Matrix; Width = 16x2x2 = 64.

reg[7:0] count;
reg[dsize*len*len-1:0] pki;
reg[dsize*len-1:0] xki;
reg[7:0] state;
reg[dsize*len*len-1:0] tmp1;
reg[dsize*len*len-1:0] tmp2;
reg[dsize*len*len-1:0] tmp3;
reg[dsize*len*len-1:0] tmp4;

reg[dsize*len*len-1:0] f,h,q,r;   //f(1,t,0,1)
reg[dsize*len-1:0] b;       //(a*t^2,1)
always@(posedge clk or negedge rst)begin
    if(~rst)begin
    tmp1<=0;
    tmp2<=0;
    tmp3<=0;
    tmp4<=0;
	state<=0;
	nk<=0;
	zenk<=0;
	xkm<=0;
	xkp<=0;
	yk<=0;
	uk<=0;
	zk<=0;
	Kk<=0;
	Pkm<=0;
	Pkp<=0;
	xki<=0;
	pki<=0;
	count<=0;
	f<=0;
	h<=0;
	q<=0;//64'b00000001100110000000000000000000000000110011000000000000000000; //[0.2,0,0.2,0]
	r<=0;//64'b00000001100110000000000000000000000000110011000000000000000000;
	b<=0;
	xo<=0;
	no<=0;
	outen<=0;

    end
    else begin
	case(state)
	0: begin
        nk<=n;
        uk<=0;
        zk<=z;
        xki<=x0;
        pki<=P0;
        f<=F;
        h<=H;
        q<=Q;
        r<=R;
        b<=B;
        state<=1;
        count<=0;
        end
        //xk- will be the output at the second last stage --->xo
     1: begin
     if(count ==0)begin
        mi[0][0]=f[dsize-1:0];
        mi[0][1]=f[2*dsize-1:dsize];
        mi[0][2]=f[3*dsize-1:2*dsize];
        mi[0][3]=f[4*dsize-1:3*dsize];
        
        mi[1][0]=xki[1*dsize-1:0];   
        mi[1][1]=16'b0000000000000000;
        mi[1][2]=xki[2*dsize-1:1*dsize];
        mi[1][3]=16'b0000000000000000;
        
        tmp1=mmout;
        count<=count+1;
       state<=1;
        end
        if(count ==1) begin
        mi[0][0]=B[dsize-1:0];
        mi[0][1]=B[2*dsize-1:dsize];
        mi[0][2]=B[3*dsize-1:2*dsize];
        mi[0][3]=B[4*dsize-1:3*dsize];
        
        mi[1][0]=uk[1*dsize-1:0];
        mi[1][1]=16'b0000000000000000;
        mi[1][2]=uk[2*dsize-1:1*dsize];
        mi[1][3]=16'b0000000000000000;
        
        tmp2=mmout;
        count<=count+1;
       state<=1;
        end
         if(count ==2) begin
        tmp3=tmp1+tmp2;
        
        xkp[2*dsize-1:1*dsize]=tmp3[3*dsize-1:2*dsize];
         xkp[1*dsize-1:0]=tmp3[1*dsize-1:0];
        count<=0;
         state<=2;
         end
        end
        
        2: begin
        if(count==0) begin
        mi[0][0]=f[dsize-1:0];
        mi[0][1]=f[2*dsize-1:dsize];
        mi[0][2]=f[3*dsize-1:2*dsize];
        mi[0][3]=f[4*dsize-1:3*dsize];
        
        mi[1][0]=pki[dsize-1:0];
        mi[1][1]=pki[2*dsize-1:1*dsize];
        mi[1][2]=pki[3*dsize-1:2*dsize];
        mi[1][3]=pki[4*dsize-1:3*dsize];
        
        tmp1=mmout;
        count<=count+1;
        state<=2;
        end
        if(count==1) begin
        mi[0][0]=tmp1[dsize-1:0];
        mi[0][1]=tmp1[2*dsize-1:dsize];
        mi[0][2]=tmp1[3*dsize-1:2*dsize];
        mi[0][3]=tmp1[4*dsize-1:3*dsize];
        
        mi[1][0]=f[dsize-1:0];
        mi[1][1]=f[3*dsize-1:2*dsize];
        mi[1][2]=f[2*dsize-1:1*dsize];
        mi[1][3]=f[4*dsize-1:3*dsize];
        
        tmp2=mmout;
        
        Pkp=tmp2+q;
        count<=0;
         state<=3;
         end
        end
        3: begin
        if(count==0) begin
        mi[0][0]=h[dsize-1:0];
        mi[0][1]=h[2*dsize-1:dsize];
        mi[0][2]=h[3*dsize-1:2*dsize];
        mi[0][3]=h[4*dsize-1:3*dsize];
        
        mi[1][0]= xkp[dsize-1:0];
        mi[1][1]= 16'b0000000000000000;
        mi[1][2]= xkp[2*dsize-1:1*dsize];
        mi[1][3]= 16'b0000000000000000;
        
        tmp1=mmout;
        count <= count +1;
        state<=3;
        end
        if(count==1) begin
        tmp2[31:0]={tmp1[3*dsize-1:2*dsize],tmp1[1*dsize-1:0]};
        yk=zk-tmp2[31:0];
        count<=0;
         state<=4;
         end
         
        end
        4: begin
        if(count==0) begin
        mi[0][0]=h[dsize-1:0];
        mi[0][1]=h[2*dsize-1:dsize];
        mi[0][2]=h[3*dsize-1:2*dsize];
        mi[0][3]=h[4*dsize-1:3*dsize];
        
        mi[1][0]= Pkp[dsize-1:0];
        mi[1][1]= Pkp[2*dsize-1:dsize];
        mi[1][2]= Pkp[3*dsize-1:2*dsize];
        mi[1][3]= Pkp[4*dsize-1:3*dsize];
        
        tmp1=mmout;
        count <= count + 1;
        state<=4;
        end
        if(count==1) begin
        mi[0][0]=tmp1[dsize-1:0];
        mi[0][1]=tmp1[2*dsize-1:dsize];
        mi[0][2]=tmp1[3*dsize-1:2*dsize];
        mi[0][3]=tmp1[4*dsize-1:3*dsize];
        
        mi[1][0]= h[dsize-1:0];
        mi[1][1]= h[3*dsize-1:2*dsize];
        mi[1][2]= h[2*dsize-1:dsize];
        mi[1][3]= h[4*dsize-1:3*dsize];
        count <= count +1;
        tmp2=mmout;
        state<=4;
        end
        if(count==2) begin
        tmp3=r+tmp2;
        
        tmp1= (tmp3[dsize-1:0])*(tmp3[4*dsize-1:3*dsize]);
        tmp2=(tmp3[2*dsize-1:1*dsize])*(tmp3[3*dsize-1:2*dsize]);
        //two's complement for subtraction
        tmp4[15:0]=(tmp2^ 'hffff) + 16'b000001_000000000000;
        count <= count+1;
        state<=4;
        end
        if(count==3) begin
        //tmp1= (tmp3[dsize-1:0])*(tmp3[4*dsize-1:3*dsize])-(tmp3[2*dsize-1:1*dsize])*(tmp3[3*dsize-1:2*dsize]);
        //ad+(-bc)
        divin=tmp1+tmp4[15:0];
        count <= count+1;
        state<=4;
        end
        if(count==4) begin
        //inverse matrix
      
        tmp4[dsize-1:0]=divout*tmp3[4*dsize-1:3*dsize];
        tmp4[2*dsize-1:dsize]=divout*(tmp3[2*dsize-1:dsize]^ 'hffff) + 16'b000001_000000000000;// new b=-det*B
        tmp4[3*dsize-1:2*dsize]=divout*(tmp3[3*dsize-1:2*dsize]^ 'hffff) + 16'b000001_000000000000;//new c=-det*C
        tmp4[4*dsize-1:3*dsize]=divout*tmp3[dsize-1:0];
 
        
 
        mi[0][0]= Pkp[dsize-1:0];
        mi[0][1]= Pkp[2*dsize-1:dsize];
        mi[0][2]= Pkp[3*dsize-1:2*dsize];
        mi[0][3]= Pkp[4*dsize-1:3*dsize];
        
        mi[1][0]=h[dsize-1:0];
        mi[1][1]=h[3*dsize-12*dsize];
        mi[1][2]=h[2*dsize-1:1*dsize];
        mi[1][3]=h[4*dsize-1:3*dsize];
        tmp1=mmout;
        count <= count + 1;
        state<=4;
        end
        if(count==5) begin
        mi[0][0]= tmp1[dsize-1:0];
        mi[0][1]= tmp1[2*dsize-1:dsize];
        mi[0][2]= tmp1[3*dsize-1:2*dsize];
        mi[0][3]= tmp1[4*dsize-1:3*dsize];
        
        mi[1][0]= tmp4[dsize-1:0];
        mi[1][1]= tmp4[2*dsize-1:dsize];
        mi[1][2]= tmp4[3*dsize-1:2*dsize];
        mi[1][3]= tmp4[4*dsize-1:3*dsize];
        
        Kk=mmout;
        count<=0;
         state<=5;
         
         end
        end
        5: begin
        if(count==0) begin
        mi[0][0]=Kk[dsize-1:0];
        mi[0][1]=Kk[2*dsize-1:dsize];
        mi[0][2]=Kk[3*dsize-1:2*dsize];
        mi[0][3]=Kk[4*dsize-1:3*dsize];
        
        mi[1][0]= yk[dsize-1:0];
        mi[1][1]= 16'b0000000000000000;
        mi[1][2]= yk[2*dsize-1:1*dsize];
        mi[1][3]= 16'b0000000000000000;       
        tmp1=mmout;       
        state<=5;
        count <= count+1;
        end
         if(count==1) begin
        xkm=xkp+{tmp1[3*dsize-1:2*dsize],tmp1[dsize-1:0]};
        //xki=xkm;
        
        //xo=xkm;//output of x when???
        count<=0;
        state <=6;
        end
        end
        6: begin
        if(count==0) begin
        mi[0][0]=Kk[dsize-1:0];
        mi[0][1]=Kk[2*dsize-1:dsize];
        mi[0][2]=Kk[3*dsize-1:2*dsize];
        mi[0][3]=Kk[4*dsize-1:3*dsize];
        
        mi[1][0]= h[dsize-1:0];
        mi[1][1]= h[2*dsize-1:dsize];
        mi[1][2]= h[3*dsize-1:2*dsize];
        mi[1][3]= h[4*dsize-1:3*dsize];
        
        tmp1=mmout;
       state<=6;
        count <= count +1;
        end
        if(count==1) begin
         tmp2=umat-tmp1;
        mi[0][0]=tmp2[dsize-1:0];
        mi[0][1]=tmp2[2*dsize-1:dsize];
        mi[0][2]=tmp2[3*dsize-1:2*dsize];
        mi[0][3]=tmp2[4*dsize-1:3*dsize];
        
        mi[1][0]= Pkp[dsize-1:0];
        mi[1][1]= Pkp[2*dsize-1:dsize];
        mi[1][2]= Pkp[3*dsize-1:2*dsize];
        mi[1][3]= Pkp[4*dsize-1:3*dsize];
        
        Pkm=mmout;
        //pki=Pkm;
        count<=0;
        state<=7;
        end
        end
        
        7: begin//output,then update and return to state 1 for newloop
        if(count==0) begin
            xo<=xkm;
            no<=nk;
            outen<=1;
            count <= count +1;
            state<=7;
            end
            
        if(count==1) begin
            nk<=n;
            uk<=u;
            zk<=z;
            xki<=xkm;
            pki<=Pkm;
            f<=F;
            h<=H;
            b<=B;
            outen <=0;
            state<=1;
            count<=0;
            end
        
        end
	
	endcase
        
    end
end

endmodule