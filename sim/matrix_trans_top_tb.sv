`timescale  1ns/1ns

module matrix_trans_top_tb;

    parameter ADDR_WIDTH    =      18; 
    parameter DATA_WIDTH    =      32; 
    parameter ROW           =      64; 
    parameter CLO           =      2400; 

    bit clk;
    bit rst;
    bit [DATA_WIDTH-1:0]    s_axis_tdata;
    bit [DATA_WIDTH-1:0]    m_axis_tdata;
    bit s_axis_tvalid;
    bit m_axis_tvalid;
    bit s_axis_tready;

    initial begin
        $dumpfile("rtl.vcd");
        $dumpvars(0, matrix_trans_top_tb);
    end

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1;
        #200
        rst = 0;
        @(posedge clk)
        //发送一帧数据
        repeat(5)
        begin
            gen_frame_data_1;
            gen_frame_data_2;
        end
        #1000
        $stop;
    end

    task gen_frame_data_1; 
        s_axis_tvalid = 1'b0;
        //产生数据
        for (int i = 0; i < ROW ; i++) begin
            s_axis_tdata = 0;
            for (int j = 0; j < CLO ; j++) begin
                s_axis_tdata = j;
                s_axis_tvalid = 1'b1;
                @(posedge clk);
            end
        end
        s_axis_tvalid = 1'b0;
    endtask
    task gen_frame_data_2; 
        s_axis_tvalid = 1'b0;
        //产生数据
        for (int i = 0; i < ROW ; i++) begin
            s_axis_tdata = 0;
            for (int j = CLO; j > 0 ; j--) begin
                s_axis_tdata = j;
                s_axis_tvalid = 1'b1;
                @(posedge clk);
            end
        end
        s_axis_tvalid = 1'b0;
    endtask

    matrix_trans_top  #(
        .ADDR_WIDTH  (ADDR_WIDTH),
        .DATA_WIDTH  (DATA_WIDTH),
        .ROW         (ROW       ),
        .CLO         (CLO       )
    )u_matrix_trans_top(
        .clk                (clk            ),
        .rst                (rst            ),
        .s_axis_tdata       (s_axis_tdata   ),
        .s_axis_tvalid      (s_axis_tvalid  ),
        .s_axis_tready      (s_axis_tready  ),
        .m_axis_tdata       (m_axis_tdata   ),
        .m_axis_tvalid      (m_axis_tvalid  ),
        .m_axis_treaty      (1'b1)
    ); 
endmodule
