//封装ultraRAM

module ultraRAM #(
    parameter ADDR_WIDTH    = 18,
    parameter DATA_WIDTH    = 32
)(
    input   logic                       clk,
    input   logic                       rst,

    ram_wrd_if.s_ram                    ram

);

    localparam READ_LATENCY  = 7;           //延迟输出的周期数
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
      .ADDR_WIDTH_A(ADDR_WIDTH),                // 数据深度
      .ADDR_WIDTH_B(ADDR_WIDTH),                // DECIMAL
      .AUTO_SLEEP_TIME(0),                      // 禁止进入睡眠模式
      .BYTE_WRITE_WIDTH_A(DATA_WIDTH),                   // 1的倍数均合法
      .CASCADE_HEIGHT(0),                       // vivado自动决定级联方式
      .CLOCKING_MODE("common_clock"),           // 端口使用相同的时钟
      .ECC_MODE("no_ecc"),                      // 不使用ECC
      .MEMORY_INIT_FILE("none"),                // 无初始化文件
      .MEMORY_INIT_PARAM("0"),                  // 无初始化
      .MEMORY_OPTIMIZATION("true"),             // 允许对于对未使用的存储进行优化
      .MEMORY_PRIMITIVE("ultra"),               // 使用ultra RAM
      .MEMORY_SIZE(MEMORY_SIZE),                // 1MB
      .MESSAGE_CONTROL(0),                      // 禁用消息报告
      .READ_DATA_WIDTH_B(DATA_WIDTH),           // 数据位宽
      .READ_LATENCY_B(READ_LATENCY),            // 读延迟时钟
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
        .doutb              (ram.rd_data),      //读数据
        .sbiterrb           (),     
        .addra              (ram.wr_addr),      //写地址
        .addrb              (ram.rd_addr),      //读地址
        .clka               (clk),              //写时钟
        .clkb               (clk),              //读时钟
        .dina               (ram.wr_data),      //写数据
        .ena                (ram.wr_en),        //高电平允许数据写
        .enb                (ram.rd_en),        //高电平允许数据读
        .injectdbiterra     (), 
        .injectsbiterra     (),
        .regceb             (1'b1),     
        .rstb               (rst),              //读端口的复位信号
        .sleep              (1'b0),     
        .wea                (wea)               //写掩码信号
        
    );



endmodule
