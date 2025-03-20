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

`timescale 1ns / 1ps

module tb_uart_fifo_top();
    // 테스트벤치 신호 선언부
    reg         clk;        // 시스템 클럭
    reg         reset;      // 리셋 신호
    reg         rx;         // 외부 UART RX 입력 (테스트용)
    wire        tx;         // 외부 UART TX 출력
    
    // 내부 신호 모니터링용 (실제 연결은 TOP 모듈 내부)
    wire [7:0]  rx_data;    // RX FIFO 데이터
    wire        rx_empty;   // RX FIFO 비어있음 표시
    wire [7:0]  tx_data;    // TX FIFO 데이터
    wire        tx_full;    // TX FIFO 가득 참 표시
    
    // 테스트 데이터 저장용 배열
    reg [7:0] test_data [0:15];    // 테스트 데이터 배열
    integer i, tx_count, rx_count; // 루프 변수 및 카운터
    
    // DUT(Design Under Test) 인스턴스화 - 회로도에 맞게 수정
    uart_fifo_top u_uart_fifo_top (
        .clk(clk),
        .rst(reset),
        .rx(rx),
        .tx(tx)
    );
    
    // 클럭 생성 (10ns 주기, 100MHz)
    always #5 clk = ~clk;
    
    // 루프백 모드 테스트를 위한 시리얼 데이터 생성 함수
    task send_serial_byte;
        input [7:0] data;
        integer i;
        begin
            // 시작 비트 (0)
            rx = 1'b0;
            #8680; // 115200 보드레이트에서 1비트 시간
            
            // 8개 데이터 비트 (LSB 먼저)
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #8680;
            end
            
            // 정지 비트 (1)
            rx = 1'b1;
            #8680;
        end
    endtask
    
    // 테스트 시나리오
    initial begin
        // 초기화 단계
        clk = 0;
        reset = 1;
        rx = 1;  // 아이들 상태는 HIGH
        tx_count = 0;
        rx_count = 0;
        
        // 테스트 데이터 정의
        for (i = 0; i < 16; i = i + 1) begin
            test_data[i] = 8'h41 + i; // 'A'부터 시작하는 문자 (41h = 'A', 42h = 'B', ...)
        end
        
        // 리셋 해제 및 안정화 시간
        #100 reset = 0;
        #100;
        
        // 시리얼 데이터 전송 테스트
        $display("Time %t: Starting serial data transmission test", $time);
        for (i = 0; i < 5; i = i + 1) begin
            // 시리얼 데이터 전송 (RX 핀으로)
            $display("Time %t: Sending serial data: %h ('%c')", 
                     $time, test_data[i], test_data[i]);
            send_serial_byte(test_data[i]);
            tx_count = tx_count + 1;
            
            // 전송 간 간격
            #10000;
        end
        
        // 루프백 동작 완료 대기
        $display("Time %t: Waiting for loopback operation to complete", $time);
        #150000;
        
        // RX 데이터 검증은 파형에서 확인 (테스트벤치에서는 외부 출력만 가능)
        $display("Test completed: Serial data transmission test finished.");
        $display("Verify results in waveform viewer.");
        
        $stop;
    end
    
    // 시뮬레이션 모니터링
    initial begin
        $monitor("Time=%t, Reset=%b, TX=%b, RX=%b", 
                 $time, reset, tx, rx);
    end
    
endmodule
//주파수 정상

// `timescale 1ns / 1ps

// module tb_uart_fifo_top();
//     // 테스트벤치 신호 선언부
//     reg         clk;        // 시스템 클럭
//     reg         reset;      // 리셋 신호
    
//     // TX 테스트 신호
//     reg  [7:0]  tx_wdata;   // TX FIFO 쓰기 데이터
//     reg         tx_wr;      // TX FIFO 쓰기 활성화 신호
//     wire        tx_full;    // TX FIFO 가득 참 표시
    
//     // RX 테스트 신호
//     reg         rx_rd;      // RX FIFO 읽기 활성화 신호
//     wire [7:0]  rx_rdata;   // RX FIFO 읽기 데이터
//     wire        rx_empty;   // RX FIFO 비어있음 표시
    
//     // UART 루프백 연결 (TX를 RX에 직접 연결)
//     wire        uart_tx;    // UART TX 핀
//     wire        uart_rx;    // UART RX 핀
    
//     // 루프백 설정 (TX 출력을 RX 입력으로)
//     assign uart_rx = uart_tx;
    
//     // 테스트 데이터 저장용 배열
//     reg [7:0] test_data [0:15];    // 16바이트 테스트 데이터 배열
//     integer i, tx_count, rx_count; // 루프 변수 및 카운터
    
//     // DUT(Design Under Test) 인스턴스화
//     uart_fifo_top u_uart_fifo_top (
//         .clk(clk),
//         .reset(reset),
//         .tx_wdata(tx_wdata),
//         .tx_wr(tx_wr),
//         .tx_full(tx_full),
//         .rx_rd(rx_rd),
//         .rx_rdata(rx_rdata),
//         .rx_empty(rx_empty),
//         .uart_tx(uart_tx),
//         .uart_rx(uart_rx)
//     );
    
//     // 클럭 생성 (10ns 주기, 100MHz)
//     always #5 clk = ~clk;
    
//     // 테스트 시나리오
//     initial begin
//         // 초기화 단계
//         clk = 0;
//         reset = 1;
//         tx_wr = 0;
//         rx_rd = 0;
//         tx_wdata = 0;
//         tx_count = 0;
//         rx_count = 0;
        
//         // 테스트 데이터 정의 (랜덤 대신 고정 값 사용)
//         for (i = 0; i < 16; i = i + 1) begin
//             test_data[i] = i + 1; // 예측 가능한 패턴 사용
//         end
        
//         // 리셋 해제 및 대기
//         #20 reset = 0;
//         #30;
        
//         // TX FIFO에 데이터 쓰기 단계
//         $display("Time %t: Starting to write data to TX FIFO", $time);
//         for (i = 0; i < 5; i = i + 1) begin // 5개 데이터만 테스트
//             @(negedge clk);
//             tx_wdata = test_data[i];
//             tx_wr = 1;
//             $display("Time %t: Writing data to TX FIFO: %h", $time, tx_wdata);
//             tx_count = tx_count + 1;
//             @(negedge clk); // 데이터 안정화를 위한 추가 클럭 사이클
//             tx_wr = 0;
//             #10; // 데이터 간 간격 유지
//         end
        
//         // UART 전송 완료 대기
//         $display("Time %t: Waiting for UART transmission to complete", $time);
//         #100000; // 원래 보드레이트(9600)에 맞게 대기 시간 복원
        
//         // RX FIFO에서 데이터 읽기 단계
//         $display("Time %t: Starting to read data from RX FIFO", $time);
//         for (i = 0; i < tx_count; i = i + 1) begin
//             // FIFO가 비어 있지 않은지 확인하고 대기
//             wait(!rx_empty);
            
//             @(negedge clk);
//             rx_rd = 1;
//             @(posedge clk); // 데이터 읽기를 위한 클럭 에지
//             $display("Time %t: Reading data from RX FIFO: %h, Expected data: %h",
//                      $time, rx_rdata, test_data[i]);
            
//             // 데이터 검증
//             if (rx_rdata == test_data[i]) begin
//                 $display("PASS: Data match");
//             end else begin
//                 $display("FAIL: Data mismatch");
//             end
            
//             rx_count = rx_count + 1;
//             @(negedge clk);
//             rx_rd = 0;
//             #10; // 읽기 작업 간 간격 유지
//         end
        
//         // 테스트 완료 및 결과 확인
//         #1000;
//         if (rx_count == tx_count) begin
//             $display("Test completed: All data transmitted successfully.");
//         end else begin
//             $display("Test failed: Transmitted data count (%0d) and received data count (%0d) don't match.", tx_count, rx_count);
//         end
        
//         $stop;
//     end
    
//     // 시뮬레이션 모니터링
//     initial begin
//         $monitor("Time=%t, TX FIFO status: full=%b, RX FIFO status: empty=%b",
//                  $time, tx_full, rx_empty);
//     end
    
// endmodule