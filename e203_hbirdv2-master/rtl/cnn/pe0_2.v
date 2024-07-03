module pe0_2(
	input 							clk,
	input 							rst_n,
		
	input 			signed	[7:0]		image_in,
	input 			signed	[7:0]		weight,
	output 		reg	signed	[7:0]		product
);

always@(posedge clk or negedge rst_n)begin
	if(!rst_n)begin
		product <= 8'b0;
	end
	else begin
		product <= image_in * weight;
	end
end

endmodule
