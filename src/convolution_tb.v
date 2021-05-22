`timescale 1ns/1ns
module  convolution_tb();
    reg clk;
    reg rst;
    reg [7:0] data;

    ConvolutionNetTop ConvolutionNetTop(
        .clk(clk),
        .rst(rst),
        .d_in(data),
        .conv_start(1'b1)
    );

    initial begin
        clk <= 1'b0;
        rst <= 1'b1;
        data <= 8'd1;
        forever begin
            #10 clk <= 1'b1;
            #10 clk <= 1'b0;
        end
    end

    always @(posedge clk) begin
        case(data)
            8'd1: begin
                data <= 8'd2;
            end
            8'd2: begin
                data <= 8'd3;
            end
            8'd3: begin
                data <= 8'd4;
            end
            8'd4: begin
                data <= 8'd5;
            end
            8'd5: begin
                data <= 8'd1;
            end
            default: begin
                data <= 8'd1;
            end
        endcase
    end

endmodule