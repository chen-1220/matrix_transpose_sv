interface ram_wrd_if#(
    parameter ADDR_WIDTH = 18,
    parameter DATA_WIDTH = 16
);

    logic   [ADDR_WIDTH-1:0]    wr_addr     ;
    logic   [ADDR_WIDTH-1:0]    rd_addr     ;
    logic   [DATA_WIDTH-1:0]    wr_data     ;
    logic   [DATA_WIDTH-1:0]    rd_data     ;
    logic                       rd_valid    ;
    logic                       wr_en       ;
    logic                       rd_en       ;

    modport m_ram (
        input   rd_data,rd_valid,
        output  wr_addr,rd_addr,wr_data,wr_en,rd_en
    );

    modport s_ram (
        input    wr_addr,rd_addr,wr_data,wr_en,rd_en,
        output   rd_data,rd_valid
    );

endinterface

interface ram_manage_if;

    logic       wr_finish_0     ;
    logic       wr_finish_1     ;
    logic       rd_finish_0     ;
    logic       rd_finish_1     ;
    logic       wr_command      ;
    logic       wr_ram_number   ;
    logic       rd_command      ;
    logic       rd_ram_number   ;

    modport     m_manage (
        input    wr_finish_0,wr_finish_1,rd_finish_0,rd_finish_1,
        output   wr_command,wr_ram_number,rd_command,rd_ram_number
    );
    modport     s_manage (
        input     wr_command,wr_ram_number,rd_command,rd_ram_number,
        output    wr_finish_0,wr_finish_1,rd_finish_0,rd_finish_1
    );

endinterface
