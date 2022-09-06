`timescale 1ns / 1ps

module huffmandecode(
clk,
huffrst,
code,
hufftable,
huffsymbol,
huffdata,
hufflength,
hufffinish
    );
input clk,huffrst;
input[15:0] code;
input[8*16-1:0] hufftable;
input[8*256-1:0] huffsymbol;
output reg[7:0] huffdata;
output reg[7:0] hufflength;
output reg hufffinish;

reg[7:0] ub;
reg[7:0] n;
reg[7:0] comp;
reg[7:0] sc;
reg[7:0] index;
reg[7:0] count;
reg[7:0] dummy;

always@(posedge clk or negedge huffrst)begin
    if(~huffrst)begin
    // Start of your code ====================================
		hufffinish<=0;
		 ub <= 0;  //uperbound to zero
		 n <=0;; //set n to 0
		 comp<=0;
		 sc<=0;
		 index<=0;
		 dummy<=0;
		 huffdata<=0;

    // End of your code ======================================
    end
    else begin
    // Start of your code ====================================
    if(hufffinish ==0) begin
	if(n < 16) begin  //check if n is within the range of length-1, not, will go to else
		 
		 
		 comp = (code >> (15-n)) & 'hff;//set code to compare be the top n bits code
	     dummy = (hufftable >> (8*n)) & 'hff;
		 ub = (ub<<1) + dummy; // update uperbound
		 count =(hufftable >> (8*n)) & 'hff;
		sc = sc + count;  // update symbol count
		
		if(comp < ub) begin //check code is within uperbound
		    index = sc-(ub-comp);  //distance is uperbound minus code
			hufflength =n+1;  //length is the length of the code
			huffdata = (huffsymbol >> (8*index)) & 'hff;;  //data is the symbol, from the huffsymbol index 
			hufffinish = 1;
		end
		n = n + 1; //increment loop 
		
	end	
	else begin 
	    hufflength <=0;
		hufffinish<=1;
		huffdata<='hff;

	end
	end
	
    // End of your code ======================================    
    end
end


endmodule
