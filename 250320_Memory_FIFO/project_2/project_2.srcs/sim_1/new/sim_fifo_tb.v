// `timescale 1ns / 1ps

// module tb_FIFO();

//     reg clk, reset, wr, rd;
//     reg [7:0] wdata;
//     wire empty, full;
//     wire [7:0] rdata;
//     integer i; // Loop variable

//     FIFO u_FIFO (
//         .clk(clk),
//         .reset(reset),
//         .wdata(wdata),
//         .wr(wr),
//         .rd(rd),
//         .rdata(rdata),
//         .full(full),
//         .empty(empty)
//     );

//     always #5 clk = ~clk; // 10ns clock period

//     reg rand_rd;
//     reg rand_wr;
//     integer write_count;
//     integer read_count;
//     reg [7:0] compare_data [15:0]; // FIFO size 16

//     initial begin
//         clk = 0;
//         reset = 1;
//         wr = 0;
//         rd = 0;
//         write_count = 0;
//         read_count = 0;
//         rand_rd = 0;
//         rand_wr = 0;

//         #10; reset = 0;
//         #50;
        
//         for (i = 0; i < 50; i = i + 1) begin
//             @(negedge clk); // Write on negedge
//             rand_wr = ($random % 2) & 1; // Ensure 0 or 1
            
//             if (~full & rand_wr) begin
//                 wdata = $random % 256; // Random 8-bit data
//                 compare_data[write_count % 16] = wdata; // Store for checking
//                 write_count = (write_count + 1) % 16;
//                 wr = 1;
//             end else begin
//                 wr = 0;
//             end

//             rand_rd = ($random % 2) & 1; // Ensure 0 or 1
            
//             if (~empty & rand_rd) begin
//                 rd = 1;
//                 @(posedge clk);
//                 if (rdata == compare_data[read_count % 16]) begin
//                     $display("PASS: rdata=%h, expected=%h, read_count=%d", rdata, compare_data[read_count % 16], read_count);
//                 end else begin
//                     $display("FAIL: rdata=%h, expected=%h, read_count=%d", rdata, compare_data[read_count % 16], read_count);
//                 end
//                 read_count = (read_count + 1) % 16;
//             end else begin
//                 rd = 0;
//             end
//         end

//         $stop;
//     end

// endmodule

`timescale 1ns / 1ps

module tb_uart_fifo_top();
    // 테스트벤치 신호 선언부
    reg         clk;        // 시스템 클럭
    reg         reset;      // 리셋 신호
    
    // TX 테스트 신호
    reg  [7:0]  tx_wdata;   // TX FIFO 쓰기 데이터
    reg         tx_wr;      // TX FIFO 쓰기 활성화 신호
    wire        tx_full;    // TX FIFO 가득 참 표시
    
    // RX 테스트 신호
    reg         rx_rd;      // RX FIFO 읽기 활성화 신호
    wire [7:0]  rx_rdata;   // RX FIFO 읽기 데이터
    wire        rx_empty;   // RX FIFO 비어있음 표시
    
    // UART 루프백 연결 (TX를 RX에 직접 연결)
    wire        uart_tx;    // UART TX 핀
    wire        uart_rx;    // UART RX 핀
    
    // 루프백 설정 (TX 출력을 RX 입력으로)
    assign uart_rx = uart_tx;
    
    // 테스트 데이터 저장용 배열
    reg [7:0] test_data [0:15];    // 16바이트 테스트 데이터 배열
    integer i, tx_count, rx_count; // 루프 변수 및 카운터
    
    // DUT(Design Under Test) 인스턴스화
    uart_fifo_top dut (
        .clk(clk),
        .reset(reset),
        .tx_wdata(tx_wdata),
        .tx_wr(tx_wr),
        .tx_full(tx_full),
        .rx_rd(rx_rd),
        .rx_rdata(rx_rdata),
        .rx_empty(rx_empty),
        .uart_tx(uart_tx),
        .uart_rx(uart_rx)
    );
    
    // 클럭 생성 (10ns 주기, 100MHz)
    always #5 clk = ~clk;
    
    // 테스트 시나리오
    initial begin
        // 초기화 단계
        clk = 0;
        reset = 1;
        tx_wr = 0;
        rx_rd = 0;
        tx_wdata = 0;
        tx_count = 0;
        rx_count = 0;
        
        // 랜덤 테스트 데이터 생성
        for (i = 0; i < 16; i = i + 1) begin
            test_data[i] = $random % 256;
        end
        
        // 리셋 해제 및 대기
        #20 reset = 0;
        #30;
        
        // TX FIFO에 데이터 쓰기 단계
        $display("Time %t: Starting to write data to TX FIFO", $time);
        for (i = 0; i < 10; i = i + 1) begin
            @(negedge clk);  // 네거티브 엣지에서 쓰기 동작
            if (!tx_full) begin
                tx_wdata = test_data[i];
                tx_wr = 1;
                $display("Time %t: Writing data to TX FIFO: %h", $time, tx_wdata);
                tx_count = tx_count + 1;
            end else begin
                $display("Time %t: TX FIFO is full", $time);
                tx_wr = 0;
            end
        end
        
        @(negedge clk);
        tx_wr = 0;  // 쓰기 동작 비활성화
        
        // UART 전송 완료 대기
        // UART 보드레이트에 따라 충분한 시간 설정 필요
        #100000;
        
        // RX FIFO에서 데이터 읽기 단계
        $display("Time %t: Starting to read data from RX FIFO", $time);
        for (i = 0; i < tx_count; i = i + 1) begin
            @(negedge clk);  // 네거티브 엣지에서 읽기 시작
            if (!rx_empty) begin
                rx_rd = 1;  // 읽기 활성화
                @(posedge clk);  // 포지티브 엣지에서 데이터 확인
                $display("Time %t: Reading data from RX FIFO: %h, Expected data: %h", 
                         $time, rx_rdata, test_data[rx_count]);
                
                // 데이터 검증
                if (rx_rdata == test_data[rx_count]) begin
                    $display("PASS: Data match");
                end else begin
                    $display("FAIL: Data mismatch");
                end
                
                rx_count = rx_count + 1;
            end else begin
                $display("Time %t: RX FIFO is empty", $time);
                rx_rd = 0;
            end
        end
        
        @(negedge clk);
        rx_rd = 0;  // 읽기 동작 비활성화
        
        // 테스트 완료 및 결과 확인
        #1000;
        if (rx_count == tx_count) begin
            $display("Test completed: All data transmitted successfully.");
        end else begin
            $display("Test failed: Transmitted data count (%0d) and received data count (%0d) don't match.", tx_count, rx_count);
        end
        
        $stop;  // 시뮬레이션 종료
    end
    
    // 시뮬레이션 모니터링
    initial begin
        $monitor("Time=%t, TX FIFO status: full=%b, RX FIFO status: empty=%b", 
                 $time, tx_full, rx_empty);
    end
    
endmodule