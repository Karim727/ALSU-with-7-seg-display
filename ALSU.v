module ALSU(clk,rst,A,B,cin,serial_in,red_op_A,red_op_B,opcode,bypass_A,bypass_B,direction,an,seg,leds);
parameter INPUT_PRIORITY = "A"; // or "B"
parameter FULL_ADDER = "ON"; // or "OFF"
input clk,rst,cin,serial_in,red_op_A,red_op_B,bypass_A,bypass_B,direction; // direction = 1 -> shift left
input [2:0] opcode,A,B;
output reg [15:0] leds;

output [3:0] an; // anodes 
output [6:0] seg; // cathodes

reg [5:0] out; // out is modified as reg

reg op_invalid; // Flag to indicate invalid operation

reg [2:0] A_reg,B_reg,opcode_reg;
wire [5:0] out_add,out_mult;
reg cin_reg,serial_in_reg,red_op_A_reg,red_op_B_reg,bypass_A_reg,bypass_B_reg,direction_reg;
    
seven_seg_controller uut_seven_seg(
    .clk(clk),
    .rst(rst),
    .result(out),
    .invalid(op_invalid),
    .an(an),
    .seg(seg)
);


always @(posedge clk, posedge rst) begin

    if(rst)begin
        cin_reg <= 0;
        serial_in_reg <= 0;
        red_op_A_reg <= 0;
        red_op_B_reg <= 0;
        bypass_A_reg <= 0;
        bypass_B_reg <= 0;
        direction_reg <= 0;
        A_reg <= 0;
        B_reg <= 0;
        opcode_reg <= 0;
        leds <= 0;
    end
    else begin
        cin_reg <= cin;
        serial_in_reg <= serial_in;
        red_op_A_reg <= red_op_A;
        red_op_B_reg <= red_op_B;
        bypass_A_reg <= bypass_A;
        bypass_B_reg <= bypass_B;
        direction_reg <= direction;
        A_reg <= A;
        B_reg <= B;
        opcode_reg <= opcode;
    end
end

always@(posedge clk, posedge rst)begin
    if(rst) leds <= 0;
    else begin
        if(op_invalid) leds <= ~leds;
        else leds <= 0;
    end
end

always @(posedge clk, posedge rst) begin
    op_invalid <= 0; // reset op_invalid flag
    if(rst)begin
        out <= 6'b000000;
    end
    else begin
    if(bypass_A_reg || bypass_B_reg) begin
        case({bypass_A_reg, bypass_B_reg})
            2'b10: out <= A_reg; 
            2'b01: out <= B_reg;  
            2'b11: begin
                if(INPUT_PRIORITY == "A") begin
                    out <= A_reg; // Bypass A takes priority
                end else begin
                    out <= B_reg; // Bypass B takes priority
                end
            end
        endcase
    end
    else begin
        case(opcode_reg)
        
            3'b000: begin // AND
                if(red_op_A_reg || red_op_B_reg) begin
                    case({red_op_A_reg, red_op_B_reg})
                        2'b10: out <= {5'b0, &A_reg}; 
                        2'b01: out <= {5'b0, &B_reg};
                        2'b11: out <= (INPUT_PRIORITY == "A") ? {5'b0, &A_reg} : {5'b0, &B_reg};
                    endcase
                end
                else
                out <= A_reg & B_reg;
            end
            3'b001: begin // XOR
                if(red_op_A_reg || red_op_B_reg) begin
                    case({red_op_A_reg, red_op_B_reg})
                        2'b10: out <= {5'b0, ^A_reg};
                        2'b01: out <= {5'b0, ^B_reg};
                        2'b11: out <= (INPUT_PRIORITY == "A") ? {5'b0, ^A_reg} : {5'b0, ^B_reg};
                    endcase
                end
                else
                out <= (A_reg ^ B_reg);
            end
            3'b010:  /*out <= out_add;*/  out <= (FULL_ADDER == "ON") ? A_reg + B_reg + cin_reg : A_reg + B_reg;
                
            
            3'b011: /*out <= out_mult;*/ out <= A_reg * B_reg;
            
            3'b100: begin
                if(direction_reg) begin // shfit left
                    out <= {out[4:0], serial_in_reg};
                end else begin // shift right
                    out <= {serial_in_reg, out[5:1]};
                end
            end
            3'b101: begin
                if(direction_reg) begin // rotate left
                        out <= {out[4:0],out[5]};
                    end else begin // rotate right
                        out <= {out[0], out[5:1]};
                    end
            end
            default: op_invalid <= 1; // Invalid opcode
    endcase
    end

    if((red_op_A_reg || red_op_B_reg) && !(opcode_reg == 3'b000 || opcode_reg == 3'b001 ))// Last Invalid operation
        op_invalid <= 1;
    if(op_invalid)
        out <= 6'b000000;
end
end


endmodule

