module m_layer_input_0(
    input clk,
    input rst,
    input [7:0] d_in,
    input start,
    output layer_0_ready
);

    // 输入图像为28x28，卷积核为3x3
    parameter img_size = 10'd784;
    parameter convolution_size = 7'd84;
    parameter kernel_size = 2'd3;
    reg [9:0] pix_count = 10'd0;

    always @(posedge clk) begin
        if(!rst) begin
            pix_count <= 10'd0;
        end
        else begin
            if(start) begin
                if(pix_count < img_size) begin
                    pix_count <= pix_count + 10'd1;
                end
            end
            else begin
                pix_count <= 10'd0;
            end
        end
    end

    assign layer_0_ready = pix_count >= convolution_size + kernel_size;

endmodule