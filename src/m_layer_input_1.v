module m_layer_input_1(
    input clk,
    input rst,
    input [7:0] d_in,
    input wr_en,
    input rd_en,
    input [9:0] wr_addr,
    input [9:0] rd_addr,
    output wire [7:0] d_out,
    output reg layer_1_write_complete = 1'b0
);

    // 定义第一卷积层输出图像大小
    parameter layer_1_output_num = 10'd676;

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
        end
        else begin
            if(wr_en) begin
                if(wr_addr == layer_1_output_num - 1) begin
                    layer_1_write_complete <= 1'b1;
                end
            end
        end
    end

endmodule