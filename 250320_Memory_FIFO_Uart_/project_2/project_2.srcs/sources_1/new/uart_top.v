module uart_tx (
    input clk,
    input rst,
    input tick,
    input start_trigger,
    input [7:0] data_in,
    output o_tx_done,
    output o_tx
);

    localparam IDLE = 3'h0, SEND = 3'h1, START = 3'h2, DATA = 3'h3, STOP = 3'h4;
    reg [3:0] state, next;
    reg tx_reg, tx_next;
    assign o_tx = tx_reg;
    reg [2:0] bit_count, bit_count_next;
    reg [3:0] tick_count_reg, tick_count_next;
    reg [7:0] temp_data_reg, temp_data_next;

    reg tx_done_reg, tx_done_next;
    assign o_tx_done = tx_done_reg;

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state <= IDLE;
            tx_reg <= 1'b1;
            tx_done_reg <= 0;
            bit_count <= 0;  
            tick_count_reg <= 0;
            temp_data_reg <= 0;  // 추가: temp_data_reg 초기화
        end else begin
            state <= next;
            tx_reg <= tx_next;
            tx_done_reg <= tx_done_next;
            tick_count_reg <= tick_count_next;
            bit_count <= bit_count_next;
            temp_data_reg <= temp_data_next;  // 추가: temp_data_reg 업데이트
        end
    end

    always @(*) begin
        next = state;
        tx_next = tx_reg;
        tx_done_next = tx_done_reg;
        tick_count_next = tick_count_reg;
        bit_count_next = bit_count;
        temp_data_next = temp_data_reg;  // 추가: temp_data_next 기본값 설정

        case (state)
            IDLE: begin
                tx_done_next = 1'b0;
                tx_next = 1'b1;
                tick_count_next = 0;
                bit_count_next = 0;
                if (start_trigger) begin
                    next = SEND;
                    temp_data_next = data_in;  // 수정: begin-end 블록으로 수정
                end
            end

            SEND: begin
                if (tick) begin
                    tick_count_next = 0;
                    next = START;
                end
            end

            START: begin
                tx_next = 1'b0;  // Start bit is 0
                tx_done_next = 1'b1;

                if (tick) begin
                    if (tick_count_reg == 15) begin
                        next = DATA;
                        tick_count_next = 0;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end

            DATA: begin
                tx_next = temp_data_reg[bit_count];  // 수정: temp_data_next -> temp_data_reg

                if (tick) begin
                    if (tick_count_reg == 15) begin
                        tick_count_next = 0;
                        
                        if (bit_count == 3'h7) begin
                            next = STOP;
                        end else begin
                            bit_count_next = bit_count + 1;
                        end
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end

            STOP: begin
                tx_next = 1'b1;  // Stop bit is 1
                
                if (tick) begin
                    if (tick_count_reg == 15) begin
                        next = IDLE;
                        tx_done_next = 1'b1;
                    end else begin
                        tick_count_next = tick_count_reg + 1;
                    end
                end
            end

        endcase
    end
endmodule