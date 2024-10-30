//��װultraRAM

module ultraRAM #(
    parameter ADDR_WIDTH    = 18,
    parameter DATA_WIDTH    = 32
)(
    input   logic                       clk,
    input   logic                       rst,

    ram_wrd_if.s_ram                    ram

);

    localparam READ_LATENCY  = 7;           //�ӳ������������
    localparam MEMORY_SIZE   = 2**(ADDR_WIDTH)*DATA_WIDTH;
    //wire [$clog2(DATA_WIDTH)-1:0]   wea;
    wire [(DATA_WIDTH)-1:0]   wea;      
    logic                     rd_en_d[READ_LATENCY-1:0];

    assign  wea             = '1; 
    assign  ram.rd_valid    = rd_en_d[READ_LATENCY-1];

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_en_d     <= '{default:0};
        end
        else begin
            rd_en_d[0]  <=  ram.rd_en;
            for (int i = 1; i < READ_LATENCY; i++) begin
                rd_en_d[i]  <=  rd_en_d[i-1];
            end
        end
    end

   xpm_memory_sdpram #(
      .ADDR_WIDTH_A(ADDR_WIDTH),                // �������
      .ADDR_WIDTH_B(ADDR_WIDTH),                // DECIMAL
      .AUTO_SLEEP_TIME(0),                      // ��ֹ����˯��ģʽ
      .BYTE_WRITE_WIDTH_A(DATA_WIDTH),                   // 1�ı������Ϸ�
      .CASCADE_HEIGHT(0),                       // vivado�Զ�����������ʽ
      .CLOCKING_MODE("common_clock"),           // �˿�ʹ����ͬ��ʱ��
      .ECC_MODE("no_ecc"),                      // ��ʹ��ECC
      .MEMORY_INIT_FILE("none"),                // �޳�ʼ���ļ�
      .MEMORY_INIT_PARAM("0"),                  // �޳�ʼ��
      .MEMORY_OPTIMIZATION("true"),             // ������ڶ�δʹ�õĴ洢�����Ż�
      .MEMORY_PRIMITIVE("ultra"),               // ʹ��ultra RAM
      .MEMORY_SIZE(MEMORY_SIZE),                // 1MB
      .MESSAGE_CONTROL(0),                      // ������Ϣ����
      .READ_DATA_WIDTH_B(DATA_WIDTH),           // ����λ��
      .READ_LATENCY_B(READ_LATENCY),            // ���ӳ�ʱ��
      .READ_RESET_VALUE_B("0"),                 // String
      .RST_MODE_A("SYNC"),                      // String
      .RST_MODE_B("SYNC"),                      // String
      .SIM_ASSERT_CHK(0),                       // DECIMAL; 0=disable simulation messages, 1=enable simulation messages
      .USE_EMBEDDED_CONSTRAINT(0),              // DECIMAL
      .USE_MEM_INIT(1),                         // DECIMAL
      .USE_MEM_INIT_MMI(0),                     // DECIMAL
      .WAKEUP_TIME("disable_sleep"),            // String
      .WRITE_DATA_WIDTH_A(DATA_WIDTH),          // DECIMAL
      .WRITE_MODE_B("read_first"),               // String
      .WRITE_PROTECT(1)                         // DECIMAL
   )
    u_xpm_memory_sdpram (
        .dbiterrb           (),
        .doutb              (ram.rd_data),      //������
        .sbiterrb           (),     
        .addra              (ram.wr_addr),      //д��ַ
        .addrb              (ram.rd_addr),      //����ַ
        .clka               (clk),              //дʱ��
        .clkb               (clk),              //��ʱ��
        .dina               (ram.wr_data),      //д����
        .ena                (ram.wr_en),        //�ߵ�ƽ��������д
        .enb                (ram.rd_en),        //�ߵ�ƽ�������ݶ�
        .injectdbiterra     (), 
        .injectsbiterra     (),
        .regceb             (1'b1),     
        .rstb               (rst),              //���˿ڵĸ�λ�ź�
        .sleep              (1'b0),     
        .wea                (wea)               //д�����ź�
        
    );



endmodule
