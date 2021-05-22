module m_conv_1(
    input clk,
    input rst,
    input [7:0] d_in,
    input start,
    input layer_0_ready,
    input layer_1_write_complete,
    output reg [9:0] ram_write_addr = 10'd0,
    output reg [7:0] d_out,
    // layer_1_ready置1下一拍时d_out有效
    output layer_1_ready
);

    // 设输入图像大小为28x28，卷积核大小为3x3
    parameter img_raw = 5'd28;
    parameter img_line = 5'd28;
    parameter img_size = 10'd784;
    parameter convolution_size = 7'd84;
    parameter kernel_count = 4'd9;
    parameter kernel_size = 2'd3;

    // 移位寄存器存储三排图像数据
    reg [7:0] shift_reg [convolution_size - 1:0];
    reg [6:0] i = 7'd0;
    always @(posedge clk) begin
        if(!rst) begin
            for(i = 7'd0; i < convolution_size; i = i + 7'd1)
                shift_reg[i] <= 8'd0;
        end
        else begin
            if(start) begin
                shift_reg[convolution_size - 1] <= d_in;
                for(i = 7'd1; i < convolution_size; i = i + 7'd1)
                    shift_reg[i - 1] <= shift_reg[i];
            end
            else begin
                for(i = 7'd0; i < convolution_size; i = i + 7'd1)
                    shift_reg[i] <= 8'd0;
            end
        end
    end

    // 构造3x3卷积核
    wire [7:0] k1 [kernel_count - 1:0];
    assign k1[0] = 8'd1;//1 2 3
    assign k1[1] = 8'd2;//2 3 1  14 e   11 b   11 b
    assign k1[2] = 8'd3;//3 1 2
    assign k1[3] = 8'd4;//2 3 1
    assign k1[4] = 8'd5;//3 1 2  29 1d  29 20  32 20
    assign k1[5] = 8'd6;//1 2 3
    assign k1[6] = 8'd7;//3 1 2
    assign k1[7] = 8'd8;//1 2 3  47 2f  50 32  47 2f
    assign k1[8] = 8'd9;//2 3 1

    // 构造3x3卷积数据
    reg [7:0] mult_data [kernel_count - 1:0];
    reg [3:0] j = 4'd0;
    always @(posedge clk) begin
        if(!rst) begin
            for(j = 4'd0; j < kernel_count; j = j + 4'd1)
                mult_data[j] <= 8'd0;
        end
        else begin
            if(start) begin
                mult_data[2] <= shift_reg[0];
                mult_data[5] <= shift_reg[28];
                mult_data[8] <= shift_reg[56];
                for(j = 4'd0; j < kernel_size - 1; j = j + 4'd1) begin
                    mult_data[j] <= mult_data[j + 1];
                    mult_data[j + 3] <= mult_data[j + 3 + 1];
                    mult_data[j + 6] <= mult_data[j + 6 + 1];
                end
            end
            else begin
                for(j = 4'd0; j < kernel_count; j = j + 4'd1)
                    mult_data[j] <= 8'd0;
            end
        end
    end

    // 乘法运算
    wire [15:0] mult [kernel_count - 1:0];
    genvar k;
    generate
        for(k = 0; k < kernel_count; k = k + 1)
        begin: conv1_mult
            mult_8 mult_8(
                .clk(clk),
                .rst(rst),
                .d_in_a(k1[k]),
                .d_in_b(mult_data[k]),
                .start(layer_0_ready & !layer_1_write_complete),
                .d_out(mult[k])
            );
        end
    endgenerate

    // 加法运算
    reg [15:0] adder_1 = 16'd0;
    reg [15:0] adder_2 = 16'd0;
    reg [15:0] adder_3 = 16'd0;
    reg [15:0] adder_4 = 16'd0;
    always @(posedge clk) begin
        if(!rst) begin
            adder_1 <= 16'd0;
            adder_2 <= 16'd0;
            adder_3 <= 16'd0;
            adder_4 <= 16'd0;
            d_out <= 8'd0;
        end
        else begin
            if(layer_0_ready & !layer_1_write_complete) begin
                adder_1 <= mult[0] + mult[1] + mult[2];
                adder_2 <= mult[3] + mult[4] + mult[5];
                adder_3 <= mult[6] + mult[7] + mult[8];
                adder_4 <= adder_1 + adder_2 + adder_3;
                // 右移代替除法，注意四舍五入
                // if(adder_4[7])
                //     d_out <= (adder_4 >> 8) + 8'd1;
                // else
                //     d_out <= adder_4 >> 8;
                d_out <= adder_4;
            end
            else begin
                adder_1 <= 16'd0;
                adder_2 <= 16'd0;
                adder_3 <= 16'd0;
                adder_4 <= 16'd0;
                d_out <= 8'd0;
            end
        end
    end

    // 判断输出有效，layer_0_ready后第4拍有d_out的有效数据
    parameter out_ready = 3'd4;
    parameter out_end = 10'd679;// 26 x 26 + 4 - 1
    reg [9:0] out_count = 10'd0;
    reg [4:0] line_count = 5'd0;
    always @(posedge clk) begin
        if(!rst) begin
            out_count <= 10'd0;
            line_count <= 5'd0;
        end
        else begin
            if(layer_0_ready & !layer_1_write_complete) begin
                if(out_count < out_ready + img_raw - 1'b1) begin
                    out_count <= out_count + 10'd1;
                end
                else begin
                    out_count <= out_ready;
                    if(line_count < img_line - kernel_size + 1'b1) begin
                        line_count <= line_count + 5'd1;
                    end
                end
            end
            else begin
                out_count <= 10'd0;
                line_count <= 5'd0;
            end
        end
    end
    assign layer_1_ready = ((out_count >= out_ready) && (out_count <= out_ready + img_raw - kernel_size)) && (line_count < img_line -kernel_size + 1'b1);

    // 设置写地址
    parameter layer_1_output_num = 10'd676;
    always @(posedge clk) begin
        if(!rst) begin
            ram_write_addr <= 10'd0;
        end
        else begin
            if(layer_1_ready) begin
                if(ram_write_addr < layer_1_output_num - 1) begin
                    ram_write_addr <= ram_write_addr + 10'd1;
                end
                else begin
                    ram_write_addr <= 10'd0;
                end
            end
        end
    end

endmodule