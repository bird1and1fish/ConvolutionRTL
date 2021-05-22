module ConvolutionNetTop (
    input clk,
    input rst,
    input [7:0] d_in,
    input conv_start
);
    wire layer_0_ready;
    wire layer_1_ready;
    wire [7:0] layer_1_conv_tmp;
    wire layer_2_read_en;
    wire [7:0] layer_1_conv;
    wire layer_1_write_complete;
    wire layer_2_relu_begin;
    wire [9:0] conv_ram_write_addr;
    wire [9:0] conv_ram_read_addr;
    wire [7:0] layer_2_max_tmp;
    wire layer_2_data_available;
    wire layer_2_ready;

    m_layer_input_0 m_layer_input_0(
        .clk(clk),
        .rst(rst),
        .d_in(d_in),
        .start(conv_start),
        .layer_0_ready(layer_0_ready)
    );

    m_conv_1 m_conv_1(
        .clk(clk),
        .rst(rst),
        .d_in(d_in),
        .start(conv_start),
        .layer_0_ready(layer_0_ready),
        .layer_1_write_complete(layer_1_write_complete),
        .ram_write_addr(conv_ram_write_addr),
        .d_out(layer_1_conv_tmp),
        .layer_1_ready(layer_1_ready)
    );

    m_layer_input_1 m_layer_input_1(
        .clk(clk),
        .rst(rst),
        .d_in(layer_1_conv_tmp),
        .wr_en(layer_1_ready),
        .rd_en(layer_2_read_en),
        .wr_addr(conv_ram_write_addr),
        .rd_addr(conv_ram_read_addr),
        .d_out(layer_1_conv),
        .layer_1_write_complete(layer_1_write_complete),
        .layer_2_relu_begin(layer_2_relu_begin)
    );

    m_max_relu_2 m_max_relu_2(
        .clk(clk),
        .rst(rst),
        .layer_2_relu_begin(layer_2_relu_begin),
        .d_in(layer_1_conv),
        .rd_en(layer_2_read_en),
        .ram_read_addr(conv_ram_read_addr),
        .d_out(layer_2_max_tmp),
        .data_available(layer_2_data_available),
        .layer_2_ready(layer_2_ready)
    );

endmodule