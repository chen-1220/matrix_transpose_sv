//RAM的读写控制器：当接收到command脉冲之后可以同时进行对RAM的读写操作
module wrd_ctrl #(
    parameter   ADDR_WIDTH  =   18      ,
    parameter   DATA_WIDTH  =   32      ,
    parameter   ROW         =   64      ,
    parameter   CLO         =   2400    
)(
    input   logic                       clk             ,
    input   logic                       rst             ,
    input   logic   [DATA_WIDTH-1:0]    data_in         ,
    input   logic                       data_in_valid   ,
    output  logic   [DATA_WIDTH-1:0]    data_out        ,
    output  logic                       data_out_valid  ,
    ram_manage_if.s_manage              ram_manage      ,
    ram_wrd_if.m_ram                    ram0            ,
    ram_wrd_if.m_ram                    ram1            

);


    logic                       wr_en         ;
    logic   [ADDR_WIDTH-1:0]    wr_addr       ;
    logic   [DATA_WIDTH-1:0]    wr_data       ;
    logic                       wr_finish     ;

    logic                       rd_en         ;
    logic   [ADDR_WIDTH-1:0]    rd_addr       ;
    logic                       rd_finish     ;

    always_comb begin
        if (!ram_manage.wr_ram_number) begin
            ram0.wr_en                  =  wr_en        ;
            ram0.wr_addr                =  wr_addr      ; 
            ram0.wr_data                =  wr_data      ; 
            ram_manage.wr_finish_0      =  wr_finish    ; 
            ram1.wr_en                  =  0            ;
            ram1.wr_addr                =  0            ; 
            ram1.wr_data                =  0            ; 
            ram_manage.wr_finish_1      =  0            ; 
        end
        else begin
            ram0.wr_en                  =  0            ;
            ram0.wr_addr                =  0            ; 
            ram0.wr_data                =  0            ; 
            ram_manage.wr_finish_0      =  0            ; 
            ram1.wr_en                  =  wr_en        ;
            ram1.wr_addr                =  wr_addr      ; 
            ram1.wr_data                =  wr_data      ; 
            ram_manage.wr_finish_1      =  wr_finish    ; 
        end
    end

    always_comb begin
        if (!ram_manage.rd_ram_number) begin
            ram0.rd_en                  =   rd_en       ;
            ram0.rd_addr                =   rd_addr     ;
            ram_manage.rd_finish_0      =   rd_finish   ;
            ram1.rd_en                  =   0           ;
            ram1.rd_addr                =   0           ;
            ram_manage.rd_finish_1      =   0           ;
        end
        else begin
            ram0.rd_en                  =   0           ;
            ram0.rd_addr                =   0           ;
            ram_manage.rd_finish_0      =   0           ;
            ram1.rd_en                  =   rd_en       ;
            ram1.rd_addr                =   rd_addr     ;
            ram_manage.rd_finish_1      =   rd_finish   ;
        end
    end

    assign  data_out        =   ram0.rd_valid? ram0.rd_data : ram1.rd_valid? ram1.rd_data : '0;
    assign  data_out_valid  =   ram0.rd_valid || ram1.rd_valid;

    wr_ctrl #(
        .ADDR_WIDTH  (ADDR_WIDTH),
        .DATA_WIDTH  (DATA_WIDTH),
        .ROW         (ROW       ),
        .CLO         (CLO       )
    ) u_wr_ctrl (
        .clk            (clk                        ),
        .rst            (rst                        ),
        .wr_command     (ram_manage.wr_command      ),       //脉冲信号，开始写帧数据
        .data_in        (data_in                    ),
        .data_in_valid  (data_in_valid              ),
        .wr_en          (wr_en                      ),
        .wr_addr        (wr_addr                    ),
        .wr_data        (wr_data                    ),
        .wr_finish      (wr_finish                  )
    );

    rd_ctrl #(
        .ADDR_WIDTH  (ADDR_WIDTH),
        .DATA_WIDTH  (DATA_WIDTH),
        .ROW         (ROW       ),
        .CLO         (CLO       )
    )u_rd_ctrl(
        .clk         (clk                   ),
        .rst         (rst                   ),
        .rd_command  (ram_manage.rd_command ),
        .rd_en       (rd_en                 ),
        .rd_addr     (rd_addr               ),
        .rd_finish   (rd_finish             )
    );
endmodule
