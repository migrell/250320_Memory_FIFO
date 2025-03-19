`timescale 1ns / 1ps

// module FIFO (
//     input clk, reset,
//     input [7:0] wdata,
//     input wr, rd,
//     output [7:0] rdata,
//     output full, empty
// );

//     // 내부 신호 정의
//     wire [3:0] waddr, raddr;
    
//     // register_file 인스턴스
//     register_file reg_file (
//         .clk(clk),
//         .waddr(waddr),
//         .wdata(wdata),
//         .wr(wr && !full),  // 꽉 차있지 않을 때만 쓰기
//         .raddr(raddr),
//         .rdata(rdata),
//         .rd(rd && !empty)  // 비어있지 않을 때만 읽기
//     );

//     // FIFO_control_unit 인스턴스
//     FIFO_control_unit ctrl_unit (
//         .clk(clk),
//         .reset(reset),
//         .wr(wr),
//         .waddr(waddr),
//         .full(full),
//         .rd(rd),
//         .raddr(raddr),
//         .empty(empty)
//     );

// endmodule


// module register_file (
//     input clk,
//     // 쓰기
//     input [3:0] waddr,
//     input [7:0] wdata,
//     input wr,
//     // 읽기
//     input [3:0] raddr,
//     output [7:0] rdata,
//     input rd
// );
//     reg [7:0] mem [0:15];  // 16개의 8비트 레지스터

//     // 쓰기 동작
//     always @(posedge clk) begin
//         if (wr) begin
//             mem[waddr] <= wdata;
//         end
//     end

//     // 읽기 동작 - 조합 논리로 구현
//     assign rdata = (rd) ? mem[raddr] : 8'b0;

// endmodule

// module FIFO_control_unit (
//     input clk, reset,
//     // 쓰기 제어
//     input wr,
//     output [3:0] waddr,
//     output full,
//     // 읽기 제어
//     input rd,
//     output [3:0] raddr,
//     output empty
// );

//     // 상태 레지스터
//     reg full_reg, full_next, empty_reg, empty_next;
//     // 포인터 레지스터
//     reg [3:0] wptr_reg, wptr_next, rptr_reg, rptr_next;
//     // 포인터 차이를 계산하기 위한 신호
//     reg [4:0] ptr_diff;  // 5비트로 오버플로우 감지

//     // 출력 할당
//     assign waddr = wptr_reg;
//     assign raddr = rptr_reg;
//     assign full = full_reg;
//     assign empty = empty_reg;

//     // 순차 로직
//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             full_reg <= 0;
//             empty_reg <= 1;  // 초기 상태는 비어있음
//             wptr_reg <= 0;
//             rptr_reg <= 0;
//         end else begin
//             full_reg <= full_next;
//             empty_reg <= empty_next;
//             wptr_reg <= wptr_next;
//             rptr_reg <= rptr_next;
//         end
//     end

//     // 조합 로직 - 상태 및 포인터 업데이트
//     always @(*) begin
//         // 기본값: 현재 상태 유지
//         full_next = full_reg;
//         empty_next = empty_reg;
//         wptr_next = wptr_reg;
//         rptr_next = rptr_reg;
        
//         // 포인터 차이 계산 (5비트로 계산)
//         ptr_diff = {1'b0, wptr_reg} - {1'b0, rptr_reg};
        
//         case ({wr, rd})
//             2'b01: begin  // 읽기만 수행
//                 if (!empty_reg) begin  // 비어있지 않으면 읽기 가능
//                     rptr_next = rptr_reg + 1;  // 읽기 포인터 증가
//                     full_next = 0;  // 읽으면 항상 full 아님
                    
//                     // 읽은 후 빈 상태 체크
//                     if (rptr_next == wptr_reg) begin
//                         empty_next = 1;
//                     end
//                 end
//             end
            
//             2'b10: begin  // 쓰기만 수행
//                 if (!full_reg) begin  // 꽉 차있지 않으면 쓰기 가능
//                     wptr_next = wptr_reg + 1;  // 쓰기 포인터 증가
//                     empty_next = 0;  // 쓰면 항상 empty 아님
                    
//                     // 쓴 후 꽉 찬 상태 체크
//                     if (wptr_next == rptr_reg) begin
//                         full_next = 1;
//                     end
//                 end
//             end
            
//             2'b11: begin  // 읽기 및 쓰기 동시 수행
//                 if (empty_reg) begin  // 비어있는 경우
//                     wptr_next = wptr_reg + 1;
//                     empty_next = 0;  // 더 이상 비어있지 않음
//                 end else if (full_reg) begin  // 꽉 찬 경우
//                     rptr_next = rptr_reg + 1;
//                     full_next = 0;  // 더 이상 꽉 차있지 않음
//                 end else begin  // 일반적인 경우
//                     wptr_next = wptr_reg + 1;
//                     rptr_next = rptr_reg + 1;
//                     // 상태는 변경 없음
//                 end
//             end
            
//             default: begin  // 2'b00: 아무 동작 없음
//                 // 상태 유지
//             end
//         endcase
//     end

// endmodule


// `timescale 1ns / 1ps

// module FIFO_control_unit (
//     input clk, reset,
//     //wr
//     input wr,
//     output [3:0] waddr,
//     output full,
//     //read
//     input rd,
//     output [3:0] raddr,
//     output empty
// );

//     // 상태 레지스터 및 포인터
//     reg full_reg, empty_reg;
//     reg [3:0] wptr_reg, rptr_reg;
    
//     // 다음 상태 신호
//     reg full_next, empty_next;
//     reg [3:0] wptr_next, rptr_next;
    
//     // 출력 할당
//     assign waddr = wptr_reg;
//     assign raddr = rptr_reg;
//     assign full = full_reg;
//     assign empty = empty_reg;

//     // 순차 로직 - 레지스터 업데이트
//     always @(posedge clk or posedge reset) begin
//         if (reset) begin
//             // 리셋 상태: 비어있고, 쓰기/읽기 포인터는 0
//             full_reg <= 0;
//             empty_reg <= 1;
//             wptr_reg <= 0;
//             rptr_reg <= 0;
//         end else begin
//             // 다음 상태로 업데이트
//             full_reg <= full_next;
//             empty_reg <= empty_next;
//             wptr_reg <= wptr_next;
//             rptr_reg <= rptr_next;
//         end
//     end

//     // 조합 로직 - 다음 상태 계산
//     always @(*) begin
//         // 기본값: 현재 상태 유지
//         full_next = full_reg;
//         empty_next = empty_reg;
//         wptr_next = wptr_reg;
//         rptr_next = rptr_reg;
        
//         case ({wr, rd})
//             2'b01: begin // 읽기만 수행
//                 if (!empty_reg) begin // 비어있지 않을 때만 읽기 가능
//                     rptr_next = rptr_reg + 1; // 읽기 포인터 증가
//                     full_next = 0; // 읽으면 꽉 차있지 않음
                    
//                     // 읽은 후 쓰기/읽기 포인터가 같으면 비어있는 상태
//                     if ((rptr_reg + 1) == wptr_reg) begin
//                         empty_next = 1;
//                     end
//                 end
//             end
            
//             2'b10: begin // 쓰기만 수행
//                 if (!full_reg) begin // 꽉 차있지 않을 때만 쓰기 가능
//                     wptr_next = wptr_reg + 1; // 쓰기 포인터 증가
//                     empty_next = 0; // 쓰면 비어있지 않음
                    
//                     // 쓴 후 쓰기 포인터가 읽기 포인터와 같으면 꽉 찬 상태
//                     // 단, 직전에 empty=1이었던 경우는 예외 (이 경우 단순히 empty=0이 됨)
//                     if ((wptr_reg + 1) == rptr_reg && !empty_reg) begin
//                         full_next = 1;
//                     end
//                 end
//             end
            
//             2'b11: begin // 읽기 및 쓰기 동시 수행
//                 if (empty_reg) begin
//                     // 비어있는 경우: 쓰기만 유효
//                     wptr_next = wptr_reg + 1;
//                     empty_next = 0;
//                 end else if (full_reg) begin
//                     // 꽉 찬 경우: 읽기만 유효
//                     rptr_next = rptr_reg + 1;
//                     full_next = 0;
//                 end else begin
//                     // 일반적인 경우: 둘 다 유효
//                     wptr_next = wptr_reg + 1;
//                     rptr_next = rptr_reg + 1;
//                     // full 및 empty 상태는 변경 없음
//                 end
//             end
            
//             // 2'b00: 아무 동작 없음, 상태 유지
//         endcase
//     end

// endmodule


`timescale 1ns / 1ps

module FIFO (
    input clk, reset,
    input [7:0] wdata,
    input wr, rd,
    output [7:0] rdata,
    output full, empty
);
    // 내부 신호 정의
    wire [3:0] waddr, raddr;
    wire fifo_wr, fifo_rd;
    
    // 쓰기/읽기 활성화 조건
    assign fifo_wr = wr && !full;
    assign fifo_rd = rd && !empty;
    
    // register_file 인스턴스
    register_file reg_file (
        .clk(clk),
        .waddr(waddr),
        .wdata(wdata),
        .wr(fifo_wr),  // 꽉 차있지 않을 때만 쓰기
        .raddr(raddr),
        .rdata(rdata),
        .rd(fifo_rd)   // 비어있지 않을 때만 읽기
    );

    // FIFO_control_unit 인스턴스
    FIFO_control_unit ctrl_unit (
        .clk(clk),
        .reset(reset),
        .wr(wr),
        .rd(rd),
        .waddr(waddr),
        .raddr(raddr),
        .full(full),
        .empty(empty)
    );
endmodule

module register_file (
    input clk,
    // 쓰기
    input [3:0] waddr,
    input [7:0] wdata,
    input wr,
    // 읽기
    input [3:0] raddr,
    output [7:0] rdata,
    input rd
);
    reg [7:0] mem [0:15];  // 16개의 8비트 레지스터

    // 쓰기 동작
    always @(posedge clk) begin
        if (wr) begin
            mem[waddr] <= wdata;
        end
    end

    // 읽기 동작 - 조합 논리로 구현
    assign rdata = (rd) ? mem[raddr] : 8'b0;
endmodule

module FIFO_control_unit (
    input clk, reset,
    // 제어 입력
    input wr, rd,
    // 주소 출력
    output [3:0] waddr, raddr,
    // 상태 출력
    output full, empty
);
    // 레지스터
    reg [4:0] wptr, rptr;  // 5비트 포인터 - 4비트 주소 + 1비트 순환 감지
    
    // 출력 할당
    assign waddr = wptr[3:0];  // 하위 4비트만 주소로 사용
    assign raddr = rptr[3:0];
    
    // full 및 empty 상태 계산
    // full: 하위 4비트는 같고, 상위 비트는 다른 경우
    // empty: 두 포인터가 정확히 같은 경우
    assign full = (wptr[3:0] == rptr[3:0]) && (wptr[4] != rptr[4]);
    assign empty = (wptr == rptr);
    
    // 순차 로직
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wptr <= 0;
            rptr <= 0;
        end
        else begin
            // 쓰기 동작 - 꽉 차있지 않을 때만 수행
            if (wr && !full) begin
                wptr <= wptr + 1;  // 쓰기 포인터 증가
            end
            
            // 읽기 동작 - 비어있지 않을 때만 수행
            if (rd && !empty) begin
                rptr <= rptr + 1;  // 읽기 포인터 증가
            end
        end
    end
endmodule
