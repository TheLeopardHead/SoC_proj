module pe_array(
	input 						clk,
	input 						rst_n,
	
	input 			[31:0]		weight0_in,
	input			[31:0]		weight1_in,
	input 			[31:0]		weight2_in,
	input			[31:0]		weight3_in,
	input 			[31:0]		data0_in,
	input			[31:0]		data1_in,
	input 			[31:0]		data2_in,
	input			[31:0]		data3_in,


	output 			[31:0]		result_00,
	output 			[31:0]		result_01,
	output 			[31:0]		result_02,
	output 			[31:0]		result_03,
	output 			[31:0]		result_10,
	output 			[31:0]		result_11,
	output 			[31:0]		result_12,
	output 			[31:0]		result_13,
	output 			[31:0]		result_20,
	output 			[31:0]		result_21,
	output 			[31:0]		result_22,
	output 			[31:0]		result_23,
	output 			[31:0]		result_30,
	output 			[31:0]		result_31,
	output 			[31:0]		result_32,
	output 			[31:0]		result_33,

	input 			[1:0]		mode 
);

wire 	[31:0]		image_data_01;
wire 	[31:0]		image_data_02;
wire 	[31:0]		image_data_03;
wire 	[31:0]		image_data_11;
wire 	[31:0]		image_data_12;
wire 	[31:0]		image_data_13;
wire 	[31:0]		image_data_21;
wire 	[31:0]		image_data_22;
wire 	[31:0]		image_data_23;
wire 	[31:0]		image_data_31;
wire 	[31:0]		image_data_32;
wire 	[31:0]		image_data_33;

wire	[31:0]		cur_weight_10;
wire	[31:0]		cur_weight_11;
wire	[31:0]		cur_weight_12;
wire	[31:0]		cur_weight_13;
wire	[31:0]		cur_weight_20;
wire	[31:0]		cur_weight_21;
wire	[31:0]		cur_weight_22;
wire	[31:0]		cur_weight_23;
wire	[31:0]		cur_weight_30;
wire	[31:0]		cur_weight_31;
wire	[31:0]		cur_weight_32;
wire	[31:0]		cur_weight_33;


pe pe00(
	.clk(clk),
	.rst_n(rst_n),

	.data_in(data0_in),
	.weight_in(weight0_in),
	.result(result_00),
	.data_out(image_data_01),
	.weight_out(cur_weight_10),
	.mode(mode)
);

pe pe01(
	.clk(clk),
	.rst_n(rst_n),

	.data_in(image_data_01),
	.weight_in(weight1_in),
	.result(result_01),
	.data_out(image_data_02),
	.weight_out(cur_weight_11),
	.mode(mode)
);

pe pe02(
	.clk(clk),
	.rst_n(rst_n),

	.data_in(image_data_02),
	.weight_in(weight2_in),
	.result(result_02),
	.data_out(image_data_03),
	.weight_out(cur_weight_12),
	.mode(mode)
);

pe pe03(
	.clk(clk),
	.rst_n(rst_n),

	.data_in(image_data_03),
	.weight_in(weight3_in),
	.result(result_03),
	.weight_out(cur_weight_13),
	.mode(mode)
);

pe pe10(
	.clk(clk),
	.rst_n(rst_n),

	.data_in(data1_in),
	.weight_in(cur_weight_10),
	.result(result_10),
	.data_out(image_data_11),
	.weight_out(cur_weight_20),
	.mode(mode)
);

pe pe11(
	.clk(clk),
	.rst_n(rst_n),

	.data_in(image_data_11),
	.weight_in(cur_weight_11),
	.result(result_11),
	.data_out(image_data_12),
	.weight_out(cur_weight_21),
	.mode(mode)
);

pe pe12(
	.clk(clk),
	.rst_n(rst_n),

	.data_in(image_data_12),
	.weight_in(cur_weight_12),
	.result(result_12),
	.data_out(image_data_13),
	.weight_out(cur_weight_22),
	.mode(mode)
);

pe pe13(
	.clk(clk),
	.rst_n(rst_n),

	.data_in(image_data_13),
	.weight_in(cur_weight_13),
	.result(result_13),
	.weight_out(cur_weight_23),
	.mode(mode)
);

pe pe20(
	.clk(clk),
	.rst_n(rst_n),

	.data_in(data2_in),
	.weight_in(cur_weight_20),
	.result(result_20),
	.data_out(image_data_21),
	.weight_out(cur_weight_30),
	.mode(mode)
);

pe pe21(
	.clk(clk),
	.rst_n(rst_n),

	.data_in(image_data_21),
	.weight_in(cur_weight_21),
	.result(result_21),
	.data_out(image_data_22),
	.weight_out(cur_weight_31),
	.mode(mode)
);

pe pe22(
	.clk(clk),
	.rst_n(rst_n),

	.data_in(image_data_22),
	.weight_in(cur_weight_22),
	.result(result_22),
	.data_out(image_data_23),
	.weight_out(cur_weight_32),
	.mode(mode)
);

pe pe23(
	.clk(clk),
	.rst_n(rst_n),

	.data_in(image_data_23),
	.weight_in(cur_weight_23),
	.result(result_23),
	.weight_out(cur_weight_33),
	.mode(mode)
);

pe pe30(
	.clk(clk),
	.rst_n(rst_n),

	.data_in(data3_in),
	.weight_in(cur_weight_30),
	.result(result_30),
    .data_out(image_data_31),
	.mode(mode)
);

pe pe31(
	.clk(clk),
	.rst_n(rst_n),

	.data_in(image_data_31),
	.weight_in(cur_weight_31),
	.result(result_31),
    .data_out(image_data_32),
	.mode(mode)
);

pe pe32(
	.clk(clk),
	.rst_n(rst_n),

	.data_in(image_data_32),
	.weight_in(cur_weight_32),
	.result(result_32),
    .data_out(image_data_33),
	.mode(mode)
);

pe pe33(
	.clk(clk),
	.rst_n(rst_n),

	.data_in(image_data_33),
	.weight_in(cur_weight_33),
	.result(result_33),
	.mode(mode)
);

endmodule
