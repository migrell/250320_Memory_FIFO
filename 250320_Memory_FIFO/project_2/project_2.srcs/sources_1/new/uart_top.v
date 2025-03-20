`timescale 1ns / 1ps

module uart_fifo_top (
    input  wire       clk,       // 시스템 클록
    input  wire       reset,     // 리셋 신호
    
    // 시스템 인터페이스 
    input  wire [7:0] tx_wdata,  // TX FIFO 쓰기 데이터
    input  wire       tx_wr,     // TX FIFO 쓰기 신호
    output wire       tx_full,   // TX FIFO 풀 신호
    
    input  wire       rx_rd,     // RX FIFO 읽기 신호
    output wire [7:0] rx_rdata,  // RX FIFO 읽기 데이터
    output wire       rx_empty,  // RX FIFO 엠티 신호
    
    // UART 인터페이스
    output wire       uart_tx,   // UART TX 핀
    input  wire       uart_rx    // UART RX 핀
);

    // 내부 연결 신호
    wire [7:0] tx_fifo_rdata;   // TX FIFO 출력 데이터
    wire       tx_fifo_empty;   // TX FIFO 엠티 신호
    wire       tx_rd;           // TX FIFO 읽기 신호
    
    wire [7:0] rx_fifo_wdata;   // RX FIFO 입력 데이터
    wire       rx_fifo_full;    // RX FIFO 풀 신호
    wire       rx_wr;           // RX FIFO 쓰기 신호
    
    wire       tx_start;        // TX 시작 신호
    wire       tx_done;         // TX 완료 신호
    wire       rx_done;         // RX 완료 신호
    wire       baud_tick;       // 보드레이트 틱 신호

    // FIFO TX 인스턴스
    FIFO u_fifo_tx (
        .clk(clk),
        .reset(reset),
        .wdata(tx_wdata),
        .wr(tx_wr),
        .rd(tx_rd),
        .rdata(tx_fifo_rdata),
        .full(tx_full),
        .empty(tx_fifo_empty)
    );

    // UART TX 모듈 인스턴스
    uart_tx u_uart_tx (
        .clk(clk),
        .rst(reset),
        .tick(baud_tick),
        .start_trigger(tx_start),
        .data_in(tx_fifo_rdata),
        .o_tx_done(tx_done),
        .o_tx(uart_tx)
    );
    
    // 보드레이트 생성기 인스턴스 - 시뮬레이션용 빠른 속도
    baud_tick_gen #(.BAUD_RATE(500000)) u_baud_tick_gen (
        .clk(clk),
        .rst(reset),
        .baud_tick(baud_tick)
    );
    
    // UART RX 모듈 인스턴스
    uart_rx u_uart_rx (
        .clk(clk),
        .rst(reset),
        .tick(baud_tick),
        .rx(uart_rx),
        .rx_done(rx_done),
        .rx_data(rx_fifo_wdata)
    );

    // FIFO RX 인스턴스
    FIFO u_fifo_rx (
        .clk(clk),
        .reset(reset),
        .wdata(rx_fifo_wdata),
        .wr(rx_wr),
        .rd(rx_rd),
        .rdata(rx_rdata),
        .full(rx_fifo_full),
        .empty(rx_empty)
    );
        // TX -> RX 신호 연결 개선
// 1. TX 시작 조건 수정
assign tx_start = ~tx_fifo_empty & tx_done;  // FIFO에 데이터가 있고 이전 전송이 완료된 경우에만 시작

// 2. TX FIFO 읽기 조건 수정 
assign tx_rd = tx_done & ~tx_fifo_empty;  // 전송 완료 시에만 FIFO에서 다음 데이터 읽기

// 3. RX FIFO 쓰기 조건은 유지
assign rx_wr = rx_done & ~rx_fifo_full;


endmodule

module uart_tx (
    input clk,
    input rst,
    input tick,
    input start_trigger,
    input [7:0] data_in,
    output reg o_tx_done,
    output reg o_tx
);
    // 상태 정의 - 단순화된 상태 머신 사용
    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3;
    
    reg [1:0] state;
    reg [2:0] bit_index;
    reg [3:0] tick_count;
    reg [7:0] data_reg;
    
    // 상태 머신 구현
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            o_tx <= 1'b1;
            o_tx_done <= 1'b1;
            bit_index <= 0;
            tick_count <= 0;
            data_reg <= 0;
        end else begin
            case (state)
                IDLE: begin
                    o_tx <= 1'b1;
                    o_tx_done <= 1'b1;
                    bit_index <= 0;
                    tick_count <= 0;
                    
                    if (start_trigger) begin
                        data_reg <= data_in;
                        state <= START;
                        o_tx_done <= 1'b0;
                    end
                end
                
                START: begin
                    o_tx <= 1'b0;  // 시작 비트는 0
                    
                    if (tick) begin
                        if (tick_count == 15) begin
                            state <= DATA;
                            tick_count <= 0;
                        end else begin
                            tick_count <= tick_count + 1;
                        end
                    end
                end
                
                DATA: begin
                    o_tx <= data_reg[bit_index];
                    
                    if (tick) begin
                        if (tick_count == 15) begin
                            tick_count <= 0;
                            
                            if (bit_index == 7) begin
                                state <= STOP;
                            end else begin
                                bit_index <= bit_index + 1;
                            end
                        end else begin
                            tick_count <= tick_count + 1;
                        end
                    end
                end
                
                STOP: begin
                    o_tx <= 1'b1;  // 정지 비트는 1
                    
                    if (tick) begin
                        if (tick_count == 15) begin
                            state <= IDLE;
                            o_tx_done <= 1'b1;  // 전송 완료 시 활성화
                        end else begin
                            tick_count <= tick_count + 1;
                        end
                    end
                end
            endcase
        end
    end
endmodule

module uart_rx (
    input clk,rst,tick,rx,
    output rx_done,
    output [7:0] rx_data
);

    localparam IDLE = 0, START = 1, DATA = 2, STOP = 3 ;
    reg [1:0] state,next;
    reg rx_reg, rx_next;
    reg rx_done_reg, rx_done_next;
    reg [2:0] bit_count_reg, bit_count_next;
    reg [4:0] tick_count_reg, tick_count_next;
    reg [7:0] rx_data_reg, rx_data_next;

    //output
    assign rx_done = rx_done_reg;
    assign rx_data = rx_data_reg;

    //state
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 0;
            rx_done_reg <=0;
            rx_data_reg <=0;
            bit_count_reg <=0;
            tick_count_reg <=0;
        end else begin
            state <= next;
            rx_done_reg <= rx_done_next;
            rx_data_reg <= rx_data_next;
            bit_count_reg <=bit_count_next;
            tick_count_reg <= tick_count_next;
        end
    end

    //next
    always @(*) begin
        next = state;
        tick_count_next = tick_count_reg;
        bit_count_next = bit_count_reg;
        rx_data_next = rx_data_reg;
        rx_done_next  = 0;
        case (state)
            IDLE:  begin
                rx_done_next = 1'b0;
                tick_count_next = 0;
                bit_count_next = 0;
                if (rx==0) begin
                    next = START;
                end
            end

            START : begin
                if (tick) begin
                     if (tick_count_reg==7) begin
                    next = DATA;
                    tick_count_next = 0;
                end else begin
                    tick_count_next = tick_count_reg+1;
                end
                end
            end

            DATA : begin
                if (tick) begin
                    if (tick_count_reg==15) begin
                    //read data
                    rx_data_next [bit_count_reg] = rx;
                    tick_count_next = 0;
                    if (bit_count_reg==7) begin
                        next = STOP;
                    end else begin
                        next = DATA;
                        bit_count_next = bit_count_reg+1;
                    end
                end else begin
                    tick_count_next = tick_count_reg+1;
                end 
                end
            end

            STOP : begin
                if (tick) begin
                    if (tick_count_reg==23) begin
                    next = IDLE;
                    rx_done_next = 1'b1;
                end else begin
                    tick_count_next = tick_count_reg+1;
                end
                end
            end 
        endcase
    end


    
endmodule


module baud_tick_gen (
    input clk,
    input rst,
    output baud_tick
);
    // 시뮬레이션을 위한 보드레이트 - 시뮬레이션 속도 향상
    parameter BAUD_RATE = 115200;  // 시뮬레이션에서는 더 빠른 보드레이트 사용
    localparam BAUD_COUNT = 100_000_000 / BAUD_RATE / 16;
    localparam COUNTER_WIDTH = $clog2(BAUD_COUNT);
    
    reg [COUNTER_WIDTH-1:0] count;
    reg tick_reg;
    
    assign baud_tick = tick_reg;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= 0;
            tick_reg <= 0;
        end else begin
            if (count == BAUD_COUNT - 1) begin
                count <= 0;
                tick_reg <= 1'b1;
            end else begin
                count <= count + 1;
                tick_reg <= 1'b0;
            end
        end
    end
endmodule


// module baud_tick_gen (
//     input clk,
//     input rst,
//     output baud_tick
// );
//     //parameter BAUD_RATE = 115200;
//     parameter BAUD_RATE = 9600;
//     localparam BAUD_COUNT = 100_000_000 / BAUD_RATE / 16; // 반올림 처리
//     localparam COUNTER_WIDTH = $clog2(BAUD_COUNT);  // 정확한 비트 수 설정

//     reg [COUNTER_WIDTH-1:0] count_reg, count_next;
//     reg tick_reg, tick_next;

//     assign baud_tick = tick_reg;

//     always @(posedge clk or posedge rst) begin
//         if (rst) begin
//             count_reg <= 0;
//             tick_reg <= 0;
//         end else begin
//             count_reg <= count_next;
//             tick_reg <= tick_next;
//         end
//     end

//     always @(*) begin
//         count_next = count_reg + 1;
//         tick_next = 1'b0;  // tick_next 초기화

//         if (count_reg >= BAUD_COUNT-1) begin
//             count_next = 0;
//             tick_next = 1'b1;
//         end
//     end

// endmodule


