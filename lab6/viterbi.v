`timescale 1ns / 1ps

module viterbi(
clk,
rst,
codein, // input: the code word sequence; length = param(lenin) = 10.
states, // input: state; length: 2^(k-1)*2*r = 16. 8 expected parity bits
codeout, // output: decoded message; length: lenout = 5.
finish// output: 1 bit flag signal.

    );

parameter r=2; // Number of parity bits in each cycle.
parameter K=3; // Max convolutional window size.
parameter lenin=10; // Length of the input code word.
parameter lenout=5; // Length of the output decoded message.

parameter maskcode=(1<<r)-1; // 11.
parameter maskstate=(1<<(K-1))-1; // 11.
parameter maskpath=(1<<K)-1; // 111. take lower 3 bits.

input clk,rst;
input[lenin-1:0] codein;
input[(1<<(K-1))*2*r-1:0] states; // input: state; length: 2^(k-1)*2*r = 16.
output reg[lenout-1:0] codeout;
output reg finish;
//output reg[7:0] mins;

// Some registers/wiers you may use.
// You can uncomment them or create your own.
 reg[7:0] tmp;
 reg[7:0] mins;
 reg[7:0] state;
 reg[7:0] code_count;
 reg[7:0] count;
 reg[7:0] i;
 reg[7:0] j;
  reg[7:0] k;
  reg[7:0] a;
  reg[7:0] place;
 reg[7:0] mindis;
  reg[7:0] index;
 reg[lenin-1:0] codetmp;
 reg[r-1:0] code; // code word we exam each time.
 wire[(1<<(K-1))*2*r-1:0] dis_path_out; // length: 16.
reg[(1<<(K-1))*K-1:0] paths[4:0]; //each K: [input dir 0/1: 1bit][last state: (K-1)bits]
 reg[(1<<(K-1))*8-1:0] dis[1:0]; // 4*8 // path metrics
 wire[(1<<(K-1))*K-1:0] pmu_path_out;
 wire[(1<<(K-1))*8-1:0] pmu_dis_out;


// Example of the instantiation of the bmu module
// You can uncomment it or create your own.
// Branch Metric Unit
 bmu #(.r(r),.K(K)) b0(
 clk,
 rst,
 code,
 states,
 dis_path_out
     );


// Example of the instantiation of the pmu module
// You can uncomment it or create your own.
// Path Metric Unit
 pmu #(.r(r),.K(K)) p0(
 clk,
 rst,
 dis[1],
 dis_path_out,
 pmu_path_out,
 pmu_dis_out
     );




always@(posedge clk or negedge rst)begin
    if(~rst)begin
        // Start of your code
        tmp=0;
        k<=0;
        i<=1;
        codeout<=0;
        code<=0;
        finish<=0;
        count<=0;
        code_count <=0;
        state<=0;
        mins<='hff;
        dis[0] <= (~(0)) & (~(0)<<8);
        dis[1] <=(~(0));
        for(j=0; j < 1<<(K-1)-1; j=j+1) begin
        paths[j]=0;
        end
        mindis<='hff;
       
        index<=0;
        // End of your code
    end
    else begin
        // Start of your code
        case(state)
            0: begin
                code = codein>>(lenin -2*i); //read 2bits
                code_count=code_count+2; //pointer move 2 bits forwards
                dis[1]=dis[0];
                i=i+1;
                state=1;
            end
            1: begin
                    if(count<3) begin
                        count = count+1;//wait 2 clock cycles
                    end
                    else begin
                        count=0;
                        state=2;
                    end
                end
             2: begin
                    paths[index]<=pmu_path_out;//store data and stage for the specific code
                    dis[0]<=pmu_dis_out;
                    index= index+1;
                    if(code_count ==10) begin //to next stage when all code is read from stage 0
                    state = 3;
                    end 
                    else begin
                        state=0;
                    end
                
                end
             3: begin
                for(j=0;j<4;j=j+1) begin//find the last distance output with min pm
                   if(mindis> dis[0]<< 8*j) begin
                    mindis = dis[0] << (8*j);
                    place=j;
                   end
                 end
                 state = 4;
                end
               
               4: begin
               tmp = paths[index]>>(place*3); //4matrix * 3length, starting from last
                index=index-1;
               for(j=4;j>-1;j=j-1)begin
              
    
                while(tmp>1) begin
                    tmp=tmp>>1;
                 end
                 if(j==4) begin//finding the first bit
                    codetmp= tmp;
                 end 
                 else begin
                     codetmp=codetmp| (tmp<<4-j);
                  end
                 mins=dis[0]>>(8*(4-j));
                 tmp = paths[index]>>(mins*3); //try to backtrack the pervious stage
                index=index-1;
                                 
                end
                codeout=codetmp;
                finish=1;

                end
            endcase
        // End of your code
    

    end
end

endmodule
