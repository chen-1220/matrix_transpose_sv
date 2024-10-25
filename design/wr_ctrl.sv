//RAM的写控制器：当接收到wr_command的脉冲后，在下个时钟开始依次顺序的写入一帧数据
module wr_ctrl #(
    parameter   ADDR_WIDTH  =   18,
    parameter   DATA_WIDTH  =   32,
    parameter   ROW         =   64,
    parameter   CLO         =   2400
)(
    input   logic                       clk             ,
    input   logic                       rst             ,
    input   logic                       wr_command      ,       //脉冲信号，开始写帧数据
    input   logic   [DATA_WIDTH-1:0]    data_in         ,
    input   logic                       data_in_valid   ,
    output  logic                       wr_en           ,
    output  logic   [ADDR_WIDTH-1:0]    wr_addr         ,
    output  logic   [DATA_WIDTH-1:0]    wr_data         ,
    output  logic                       wr_finish           //标识当前写操作完成 
);
    
    logic   wr_ctrl_en;

    assign  wr_finish   =   wr_addr ==  ROW*CLO - 1;
    assign  wr_en       =   wr_ctrl_en & data_in_valid;
    assign  wr_data     =   data_in;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ctrl_en   <= 1'b0;
        end
        else if (wr_command) begin
            wr_ctrl_en   <= 1'b1;
        end
        else if (wr_addr == ROW*CLO - 1) begin
            wr_ctrl_en   <= 1'b0;
        end
        else begin
            wr_ctrl_en   <= wr_ctrl_en;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_addr <= '0;
        end
        else if (wr_en & wr_addr != ROW*CLO - 1) begin
            wr_addr <= wr_addr + 1'b1;
        end
        else begin
            wr_addr <= '0;
        end
    end


endmodule
