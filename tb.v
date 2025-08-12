module ALSU_tb();
parameter INPUT_PRIORITY = "A"; 
parameter FULL_ADDER = "ON"; 
reg clk,rst,cin,serial_in,red_op_A,red_op_B,bypass_A,bypass_B,direction;
reg [2:0] opcode,A,B;
wire [15:0] leds;
wire [5:0] out;

always #5 clk = ~clk;

ALSU uut (
    .clk(clk),
    .rst(rst),
    .A(A),
    .B(B),
    .cin(cin),
    .serial_in(serial_in),
    .red_op_A(red_op_A),
    .red_op_B(red_op_B),
    .opcode(opcode),
    .bypass_A(bypass_A),
    .bypass_B(bypass_B),
    .direction(direction),
    .leds(leds),
    .out(out)
);

initial begin
// 2.1
clk = 0;
rst = 1;
cin = 0;
serial_in = 0;  
red_op_A = 0;
red_op_B = 0;
bypass_A = 0;
bypass_B = 0;
direction = 0;
A = 3'b000; 
B = 3'b000; 
opcode = 3'b000; 
@(negedge clk);
if(out != 6'b0 || leds != 16'b0) begin
    $display("2.1 Test failed");
end



// 2.2
bypass_A = 1;
bypass_B = 1;
rst = 0;
repeat(10) begin
A = $urandom_range(0, 7);
B = $urandom_range(0, 7);
opcode = $urandom_range(0, 5);
repeat(2)@(negedge clk);
if(out != A) // Since input priority is "A", output should be A.
    $display("2.2 Failed, expected %b, got %b", A, out);

end

// 2.3
bypass_A = 0;
bypass_B = 0;
opcode = 3'b000; // AND
repeat(10) begin
A = $urandom_range(0, 7);
B = $urandom_range(0, 7);
red_op_A = $urandom_range(0, 1);
red_op_B = $urandom_range(0, 1);

repeat(2)@(negedge clk);
    if(red_op_A)begin
        if(out != {5'b0, &A}) $display("Failed A AND reduction, expected %b, got %b", {5'b0, &A}, out); 
    end
    else if(red_op_B) begin
        if(out != {5'b0, &B}) $display("Failed B AND reduction, expected %b, got %b", {5'b0, &B}, out); 
    end
    else
        if(out != (A & B)) $display("Failed AND, expected %b, got %b ",A&B,out); 
end


// 2.4
opcode = 3'b001; // XOR 
repeat(10) begin
A = $urandom_range(0, 7);
B = $urandom_range(0, 7);
red_op_A = $urandom_range(0, 1);
red_op_B = $urandom_range(0, 1);


repeat(2)@(negedge clk);
    if(red_op_A)begin
        if(out != {5'b0, ^A}) $display("Failed A XOR reduction, expected %b, got %b", {5'b0, ^A}, out); 
    end
    else if(red_op_B) begin
        if(out != {5'b0, ^B}) $display("Failed B XOR reduction, expected %b, got %b", {5'b0, ^B}, out); 
    end
    else
        if(out != (A ^ B)) $display("Failed XOR, expected %b, got %b ",A^B,out); 

end

// 2.5
opcode = 3'b010; // Full Adder
red_op_A = 0;
red_op_B = 0;
repeat(10) begin
A = $urandom_range(0, 7);
B = $urandom_range(0, 7);
cin = $urandom_range(0, 1);

repeat(2)@(negedge clk);

if(out != (A + B + cin)) $display("Failed Full Adder"); 
    
end


// 2.6
opcode = 3'b011; // Multiplication
repeat(10) begin
A = $urandom_range(0, 7);
B = $urandom_range(0, 7);

repeat(2)@(negedge clk);

if(out != A*B) $display("Failed Multiplication"); 

end
// 2.5
opcode = 3'b100; // Shift
repeat(10) begin
A = $urandom_range(0, 7);
B = $urandom_range(0, 7);
serial_in = $urandom_range(0, 1);
direction = $urandom_range(0, 1); // 1 -> left, 0 -> right
repeat(2)@(negedge clk);

end

// 2.8
opcode = 3'b101; // Rotate
repeat(10) begin
A = $urandom_range(0, 7);
B = $urandom_range(0, 7);
serial_in = $urandom_range(0, 1);
direction = $urandom_range(0, 1); // 1 -> left, 0 -> right
repeat(2)@(negedge clk);    

end
$finish;
end
endmodule