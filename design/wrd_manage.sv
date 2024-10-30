//这是乒乓读写的管理模块
//根据当前RAM块状态分配读写请求
module wrd_manage (
    input   logic           clk             ,
    input   logic           rst             ,
    input   logic           data_in_valid   ,
    input   logic           frame_start     ,       //脉冲信号，表示一帧数据的开始，高有效
    ram_manage_if.m_manage  ram_manage
);

    enum logic  [2:0] {
        WR_IDLE = 3'b001,
        WR_RAM0 = 3'b010,
        WR_RAM1 = 3'b100
    } wr_cur_state = WR_IDLE,wr_next_state = WR_IDLE;

    
    enum logic  [2:0] {
        RD_IDLE = 3'b001,
        RD_RAM0 = 3'b010,
        RD_RAM1 = 3'b100
    } rd_cur_state = RD_IDLE,rd_next_state = RD_IDLE;



    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_cur_state    <=  WR_IDLE;
        end
        else begin
            wr_cur_state    <=  wr_next_state;
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            rd_cur_state    <=  RD_IDLE;
        end
        else begin
            rd_cur_state    <=  rd_next_state;
        end
    end

    //写帧数据的状态机代码
    always_comb begin
        case(wr_cur_state)
            WR_IDLE: begin
                if (frame_start) begin
                    wr_next_state = (rd_cur_state == RD_RAM0)? WR_RAM1 : WR_RAM0;
                end
                else begin
                    wr_next_state = WR_IDLE;
                end
            end
            WR_RAM0: begin
                if (ram_manage.wr_finish_0) begin
                    wr_next_state = data_in_valid? WR_RAM1 : WR_IDLE;
                end
                else begin
                    wr_next_state = WR_RAM0;
                end
            end
            WR_RAM1: begin
                if (ram_manage.wr_finish_1) begin
                    wr_next_state = data_in_valid? WR_RAM0 : WR_IDLE;
                end
                else begin
                    wr_next_state = WR_RAM1;
                end
            end
            default:begin
                wr_next_state = WR_IDLE;
            end
        endcase
    end

    //读帧数据的状态机代码
    always_comb begin
        case(rd_cur_state)
            RD_IDLE: begin
                if (ram_manage.wr_finish_0) begin
                    rd_next_state = RD_RAM0;
                end
                else if (ram_manage.wr_finish_1) begin
                    rd_next_state = RD_RAM1;
                end
                else begin
                    rd_next_state = RD_IDLE;
                end
            end
            RD_RAM0: begin
                if (ram_manage.rd_finish_0) begin
                    rd_next_state = ram_manage.wr_finish_1? RD_RAM1 : RD_IDLE;
                end
                else begin
                    rd_next_state = RD_RAM0;
                end
            end
            RD_RAM1: begin
                if (ram_manage.rd_finish_1) begin
                    rd_next_state = ram_manage.wr_finish_0? RD_RAM0 : RD_IDLE;
                end
                else begin
                    rd_next_state = RD_RAM1;
                end
            end
            default: begin
                rd_next_state = RD_IDLE;
            end
        endcase
    end

    always_comb begin
//        ram_manage.wr_command = frame_start;
        ram_manage.wr_command = frame_start || ((ram_manage.wr_finish_0 || ram_manage.wr_finish_1) && data_in_valid);
        ram_manage.rd_command = ram_manage.wr_finish_0 || ram_manage.wr_finish_1;
        case(wr_cur_state)
            WR_IDLE: begin
                ram_manage.wr_ram_number = 0;
            end
            WR_RAM0: begin
                ram_manage.wr_ram_number = 0;
            end
            WR_RAM1: begin
                ram_manage.wr_ram_number = 1;
            end
            default: begin
                ram_manage.wr_ram_number = 0;
            end
        endcase
        case(rd_cur_state)
            RD_IDLE: begin
                ram_manage.rd_ram_number = 0;
            end
            RD_RAM0: begin
                ram_manage.rd_ram_number = 0;
            end
            RD_RAM1: begin
                ram_manage.rd_ram_number = 1;
            end
            default: begin
                ram_manage.rd_ram_number = 0;
            end
        endcase
    end


endmodule
