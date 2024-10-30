/*
*   �ļ���  ��matrix_trans_top.sv
*   ģ����  ��matrix_trans_top
*   ����    ��Will Chen
*   ����    ��
*           -- 2024.10.19   ����ɷ�����֤
*           -- 2024.10.23   �޸�ģ��ӿ�Ϊaxi stream���ͣ�����ɷ�����֤
*           -- 2024.10.25   ���Ӷ�֡����ת�ù��ܣ�֡�䲻��Ҫ���ʱ��
*
*   ģ�鹦�ܣ�����ultraRAMʵ�ֵľ���ת��ģ�飬����ultraRAM��72bit*4096
*
*   ģ�������
*           --  ADDR_WIDTH          ��ultraRAM�ĵ�ַ���         
*           --  DATA_WIDTH          ��ultraRAM������λ��
*           --  ROW                 ����
*           --  CLO                 ����
*
*
*   �����źŵ�ʱ��Ҫ��
*           --                _   _   _   _   _   _   _   _   _   _
*           -- clk           | |_| |_| |_| |_| |_| |_| |_| |_| |_| 
*           --                        _____________________________
*           -- s_axis_tvalid ________|                             
*           --                        _____________________________
*           -- s_axis_tdata  ________/_____________________________
*
*   ����źŵ�ʱ��
*           --                 _   _   _   _   _   _   _   _   _   _
*           -- clk            | |_| |_| |_| |_| |_| |_| |_| |_| |_| 
*           --                             ________________________
*           -- m_axis_treaty _____________|                             
*           --                        _____________________________
*           -- m_axis_tvalid ________|                             
*           --                             ________________________
*           -- m_axis_tdata  _____________/________________________
*
*   ˵����
*           --  �����֡�����ݱ�������
*           --  ������û�����ֳɹ����ݻᱻ������
*
*/
module   matrix_trans_top #(
    parameter   ADDR_WIDTH      =   18      ,
    parameter   DATA_WIDTH      =   32      ,       
    parameter   ROW             =   64      ,
    parameter   CLO             =   2400    
)(
    input   logic                       clk             ,
    input   logic                       rst             ,

    input   logic   [DATA_WIDTH-1:0]    s_axis_tdata    ,
    input   logic                       s_axis_tvalid   ,
    output  logic                       s_axis_tready   ,

    output  logic   [DATA_WIDTH-1:0]    m_axis_tdata    ,
    output  logic                       m_axis_tvalid   ,
    input   logic                       m_axis_treaty   

); 

    ram_wrd_if                  #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) ram0();
    ram_wrd_if                  #(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) ram1();

    ram_manage_if               ram_manage();

    logic                       frame_start     ;
    logic   [DATA_WIDTH-1:0]    data_in         ;
    logic                       data_in_valid   ;
    logic   [DATA_WIDTH-1:0]    data_out        ;
    logic                       data_out_valid  ; 

    assign  frame_start     =   s_axis_tvalid & (~data_in_valid);
    assign  s_axis_tready   =   1'b1;
    assign  m_axis_tdata    =   (data_out_valid & m_axis_treaty)?  data_out : '0;       //���ֳɹ��ŷ�������
    assign  m_axis_tvalid   =   data_out_valid;

    always_ff @(posedge clk or posedge rst) begin
        if(rst) begin
            data_in         <=  '0;
            data_in_valid   <=  '0;
        end
        else begin
            data_in         <=  s_axis_tdata;
            data_in_valid   <=  s_axis_tvalid;
        end
    end

    wrd_manage u_wrd_manage(
        .clk             (clk          ),
        .rst             (rst          ),
        .data_in_valid   (data_in_valid),
        .frame_start     (frame_start  ),
        .ram_manage      (ram_manage   )
    );

    wrd_ctrl #(
        .ADDR_WIDTH      (ADDR_WIDTH    ),
        .DATA_WIDTH      (DATA_WIDTH    ),
        .ROW             (ROW           ),
        .CLO             (CLO           )
    )u_wrd_ctrl(
        .clk             (clk           ),
        .rst             (rst           ),
        .data_in         (data_in       ),
        .data_in_valid   (data_in_valid ),
        .data_out        (data_out      ),
        .data_out_valid  (data_out_valid),
        .ram_manage      (ram_manage    ),
        .ram0            (ram0          ),
        .ram1            (ram1          )
    );

    ultraRAM #(
        .ADDR_WIDTH     (ADDR_WIDTH  ),
        .DATA_WIDTH     (DATA_WIDTH  )
    ) u_ultraRAM0(
        .clk            (clk         ),
        .rst            (rst         ),
        .ram            (ram0        )
    );

    ultraRAM #(
        .ADDR_WIDTH     (ADDR_WIDTH  ),
        .DATA_WIDTH     (DATA_WIDTH  )
    ) u_ultraRAM1(
        .clk            (clk         ),
        .rst            (rst         ),
        .ram            (ram1        )
    );



endmodule
