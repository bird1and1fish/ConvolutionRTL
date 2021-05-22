module conv_ram(
    input clk,
    input rst,
    input wr_en,
    input rd_en,
    input [9:0] wr_addr,
    input [9:0] rd_addr,
    input [7:0] d_in,
    output reg [7:0] d_out
);

    // 定义第一卷积层输出图像大小
    parameter layer_1_output_num = 10'd676;
    reg [7:0] layer_1_bram [layer_1_output_num - 1:0];
    reg [9:0] i;

    always @(posedge clk) begin
        if(!rst) begin
            d_out <= 8'b0;
            for(i = 0; i < layer_1_output_num; i = i + 10'd1)
                layer_1_bram[i] <= 8'd0;
        end
        else begin
            if(wr_en) begin
                layer_1_bram[wr_addr] <= d_in;
            end
            else if(rd_en) begin
                d_out <= layer_1_bram[rd_addr];
            end
            else begin
                d_out <= 8'b0;
            end
        end
    end

endmodule