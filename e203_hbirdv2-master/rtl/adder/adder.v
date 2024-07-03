module adder (
    input              clk,
    input              rst_n,
    input              enable,
    input       [31:0] in1,
    input       [31:0] in2,
    output reg  [31:0] out,
    output reg         overflow
);

// 内部寄存器定义
reg [8:0] sum7_0;           
reg [8:0] sum15_8;           
reg [8:0] sum23_16;
reg [8:0] sum31_24;
reg [31:0] operand1_reg, operand2_reg;  
reg carry;                      
reg [1:0] stage;                      


// 加载输入到寄存器并进行加法运算
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // 异步复位
        operand1_reg <= 32'd0;
        operand2_reg <= 32'd0;
        sum7_0 <= 9'd0;
        sum15_8 <= 9'd0;
        sum23_16 <= 9'd0;
        sum31_24 <= 9'd0;
        carry <= 1'b0;
        out <= 32'd0;
        stage <= 2'b0;
    end else if (enable) begin
        if (stage == 2'b0) begin
            operand1_reg <= in1;
            operand2_reg <= in2;
            sum7_0 <= operand1_reg[7:0] + operand2_reg[7:0];
            stage <= 2'd1;  
        end else if (stage == 2'd1) begin
            sum15_8 <= operand1_reg[15:8] + operand2_reg[15:8] + sum7_0[8]; 
            stage <= 2'd2;
        end else if (stage == 2'd2) begin
            sum23_16 <= operand1_reg[23:16] + operand2_reg[23:16] + sum15_8[8]; 
            stage <= 2'd3;
        end else if (stage == 2'd3) begin
            sum31_24 <= operand1_reg[31:24] + operand2_reg[31:24] + sum23_16[8]; 
            out <= {sum31_24[7:0], sum23_16[7:0], sum15_8[7:0], sum7_0[7:0]};  
            stage <= 1'd0;  
        end
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        overflow <= 0;
    else if(enable)
        overflow <= sum31_24[8];
end

endmodule
