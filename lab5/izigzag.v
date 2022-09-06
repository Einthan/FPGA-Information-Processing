`timescale 1ns / 1ps

module izigzag(
clk,
rst,
zigzag,
outdata,
finish
    );
    
input clk,rst;
input[32*64-1:0] zigzag;//[64th data (32bits)]..[2nd data][1st data] Q(15,16)
output reg[32*64-1:0] outdata;
output reg finish;

always@(posedge clk or negedge rst)begin
    if(~rst)begin
        outdata<=0;
        finish<=0;
    end
    else begin
    // Example:
    // outdata[31:0]<=zigzag[31:0]; (outdata[32 * 1 -1 :32*0] =    zigzag[32 * 1 -1 :32*0]) -->0 is first data
    // outdata[63:32]<=zigzag[63:32]; (outdata[32 * 2 -1 :32*1] =   zigzag[32 * 2 -1 :32*1])2nd data to 2nd data
    // outdata[287:256]<=zigzag[95:64]; (outdata[32 * 9 -1 :32*8] =    zigzag[32 * 3 -1 :32*2]) -->3rd data to 9th data
	//matrix-> left to right, code: right to left
    // Start of your code ====================================
	 outdata[31:0]<=zigzag[31:0];    //1
     outdata[63:32]<=zigzag[63:32]; //2
     outdata[287:256]<=zigzag[95:64];  //3  
	 outdata[543:512]<=zigzag[127:96];  //4
	 outdata[319:288]<=zigzag[159:128];  //5
	 outdata[95:64]<=zigzag[191:160];  //6
	 outdata[127:96]<=zigzag[223:192];  //7
	 outdata[351:320]<=zigzag[255:224];  //8
	 outdata[575:544]<=zigzag[287:256];  //9
	 outdata[799:768]<=zigzag[319:288]; //10
	 outdata[1055:1024]<=zigzag[351:320]; //11
	 outdata[831:800]<=zigzag[383:352]; //12
	 outdata[607:576]<=zigzag[415:384]; //13
	 outdata[383:352]<=zigzag[447:416];  //14
	 outdata[159:128]<=zigzag[479:448]; //15
	 outdata[191:160]<=zigzag[511:480]; //16
	 outdata[415:384]<=zigzag[543:512];  //17
	 outdata[639:608]<=zigzag[575:544];  //18
	 outdata[863:832]<=zigzag[607:576]; //19
	 outdata[1087:1056]<=zigzag[639:608];  //20
	 outdata[1311:1280]<=zigzag[671:640];  //21
	 outdata[1567:1536]<=zigzag[703:672]; //22
	 outdata[1343:1312]<=zigzag[735:704];  //23
	 outdata[1119:1088]<=zigzag[767:736];  //24
	 outdata[895:864]<=zigzag[799:768];  //25
	 outdata[671:640]<=zigzag[831:800]; //26
	 outdata[447:416]<=zigzag[863:832]; //27
	 outdata[223:192]<=zigzag[895:864];  //28
	 outdata[255:224]<=zigzag[927:896];  //29
	 outdata[479:448]<=zigzag[959:928];  //30
	 outdata[703:672]<=zigzag[991:960];  //31
	 outdata[927:896]<=zigzag[1023:992];  //32
	 outdata[1151:1120]<=zigzag[1055:1024];//33
	 outdata[1375:1344]<=zigzag[1087:1056];//34
	 outdata[1599:1568]<=zigzag[1119:1088];//35
	 outdata[1823:1792]<=zigzag[1151:1200];//36
	 outdata[1855:1824]<=zigzag[1183:1152];//37
	 outdata[1631:1600]<=zigzag[1215:1184]; //38
	 outdata[1407:1376]<=zigzag[1247:1216];//39
	 outdata[1183:1152]<=zigzag[1279:1248];//40
	 outdata[959:928]<=zigzag[1311:1280];//41
	 outdata[735:704]<=zigzag[1343:1312];//42
	 outdata[511:480]<=zigzag[1375:1344];//43
	 outdata[767:736]<=zigzag[1407:1376];//44
	 outdata[991:960]<=zigzag[1439:1408];//45
	 outdata[1215:1184]<=zigzag[1471:1440];//46
	 outdata[1439:1408]<=zigzag[1503:1472];//47
	 outdata[1663:1632]<=zigzag[1535:1504];//48
	 outdata[1887:1856]<=zigzag[1567:1536];//49
	 outdata[1919:1888]<=zigzag[1599:1568];//50
	 outdata[1695:1664]<=zigzag[1631:1600];//51
	 outdata[1471:1440]<=zigzag[1663:1632];//52
	 outdata[1247:1216]<=zigzag[1695:1664];//53
	 outdata[1023:992]<=zigzag[1727:1696];//54
	 outdata[1279:1248]<=zigzag[1759:1728];//55
	 outdata[1503:1472]<=zigzag[1791:1760];//56
	 outdata[1727:1696]<=zigzag[1823:1792];//57
	 outdata[1951:1920]<=zigzag[1855:1824];//58
	 outdata[1983:1952]<=zigzag[1887:1856];//59
	 outdata[1759:1728]<=zigzag[1919:1888];//60
	 outdata[1535:1504]<=zigzag[1951:1920];//61
	 outdata[1791:1760]<=zigzag[1983:1952];//62
	 outdata[2015:1984]<=zigzag[2015:1984];//63
	 outdata[2047:2016]<=zigzag[2047:2016];//64

    // End of your code ======================================
    finish<=1;
    end
end

endmodule
