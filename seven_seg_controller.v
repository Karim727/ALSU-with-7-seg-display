module seven_seg_controller(clk,rst,result,invalid,an,seg);
input [5:0] result;
input clk,rst;
input invalid;
output reg [3:0] an; // anodes 
output reg [6:0] seg; // cathodes
reg [4:0] digit;
reg [2:0] digit_sel;
reg [19:0] digit_period; // Refresh Period should be between 1ms - 16ms, since the basys 3 FPGA clk is set to 
                      // 100Mhz, i.e. 10ns period, then for 1ms for each digit, then a 4ms (1ms * 4)
                      // refresh period is needed. Thus the digit period is 10ns * 10^5 = 1ms.
reg [3:0]digit;

always@(*) begin
    if(invalid)
        case(an)
        4'b1110: seg = 7'b1001100; //4
        4'b1101: seg = 7'b0000001; //0
        4'b1011: seg = 7'b1001100; //4
        4'b0111: seg = 7'b0110000; //E
        endcase
    else if(an == 4'b1110 || an == 4'b1101) 
        case(digit) // ca,cb,cc,cd,ce,cf,cg 
        4'b0000: seg = 7'b0000001; // "0"  
        4'b0001: seg = 7'b1001111; // "1" 
        4'b0010: seg = 7'b0010010; // "2" 
        4'b0011: seg = 7'b0000110; // "3" 
        4'b0100: seg = 7'b1001100; // "4" 
        4'b0101: seg = 7'b0100100; // "5" 
        4'b0110: seg = 7'b0100000; // "6" 
        4'b0111: seg = 7'b0001111; // "7" 
        4'b1000: seg = 7'b0000000; // "8"  
        4'b1001: seg = 7'b0000100; // "9" 

        4'b1010: seg = 7'b0001000; // "A" 
        4'b1011: seg = 7'b1100000; // "b" 
        4'b1100: seg = 7'b0110001; // "C" 
        4'b1101: seg = 7'b1000010; // "d" 
        4'b1110: seg = 7'b0110000; // "E" 
        4'b1111: seg = 7'b0111000; // "F" 
        default: seg = 7'b0000001; // "0"
        endcase
    else if(an == 4'b0111 || an == 4'b1011)
        seg = 7'b1111110; // '-'

end

always@(*)begin
    case(digit_sel)
    2'b00: begin an = 4'b1110; digit = result[3:0]; end // AN0 (right most digit)
    2'b01: begin an = 4'b1101; digit = result[5:4]; end // AN1
    2'b10: begin an = 4'b1011; end // AN2 
    2'b11: begin an = 4'b0111;  end // AN3 (left most digit)
    endcase
end

always@(posedge clk, posedge rst) begin
    if(rst)begin
        digit_period <= 0;
        digit_sel <= 0;
    end
    else begin
        if(digit_period >= 99_999) begin
            digit_period <=0;
            digit_sel = digit_sel + 1;
        end
        else
            digit_period =  digit_period + 1;
    end
end

endmodule
