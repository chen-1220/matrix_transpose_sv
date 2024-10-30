//RAM的读控制器：当接收到rd_command的脉冲后，在下个时钟开始依次按列读取一帧的数据
module rd_ctrl #(
    parameter   ADDR_WIDTH  =   18,
    parameter   DATA_WIDTH  =   32,
    parameter   ROW         =   64,
    parameter   CLO         =   2400
)(
    input   logic                       clk             ,
    input   logic                       rst             ,
    input   logic                       rd_command      ,
    output  logic                       rd_en           ,
    output  logic   [ADDR_WIDTH-1:0]    rd_addr         ,
    output  logic                       rd_finish
);

    assign  rd_finish   =   rd_addr ==  ROW*CLO - 1;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_en   <=  1'b0;
        end
        else if (rd_command) begin
            rd_en   <=  1'b1;
        end
        else if (rd_addr == ROW*CLO - 1) begin
            rd_en   <=  1'b0;
        end
        else begin
            rd_en   <=  rd_en;
        end
    end


    logic   [$clog2(CLO)-1:0]   clo_cnt;
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_addr <=  '0;
            clo_cnt <=  12'h1;
        end
        else if (rd_en && rd_addr != ROW*CLO - 1) begin
            if (rd_addr + CLO > ROW*CLO - 1) begin
                rd_addr <= clo_cnt;
                clo_cnt <= clo_cnt + 1'b1;
            end
            else begin
                rd_addr <=  rd_addr + CLO;
            end
        end
        else begin
            rd_addr <=  '0;
            clo_cnt <=  12'h1;
        end
    end



endmodule
