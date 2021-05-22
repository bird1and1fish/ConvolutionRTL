module m_layer_input_1(
    input clk,
    input rst,
    input [7:0] d_in,
    input wr_en,
    input rd_en,
    input [6:0] wr_addr,
    input [6:0] rd_addr,
    output wire [7:0] d_out,
    output reg layer_1_write_complete = 1'b0,
    output reg layer_2_relu_begin = 1'b0
);

    // 定义第一卷积层输出缓存大小，由于池化卷积核是2x2，只需要构造一个4x26大小的乒乓缓存
    parameter left_ram_size = 6'd52;
    parameter layer_1_output_num = 10'd676;
    reg [9:0] wr_count = 10'd0;

    conv_ram conv_ram(
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .wr_addr(wr_addr),
        .rd_addr(rd_addr),
        .d_in(d_in),
        .d_out(d_out)
    );

    always @(posedge clk) begin
        if(!rst) begin
            layer_1_write_complete <= 1'b0;
            layer_2_relu_begin <= 1'b0;
            wr_count <= 10'd0;
        end
        else begin
            if(wr_en) begin
                if(wr_count == left_ram_size - 1) begin
                    layer_2_relu_begin <= 1'b1;
                end
                if(wr_count < layer_1_output_num - 1) begin
                    wr_count <= wr_count + 10'd1;
                end
                else begin
                    layer_1_write_complete <= 1'b1;
                end
            end
        end
    end

endmodule