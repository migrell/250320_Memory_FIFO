// 테스트벤치
module tb_FIFO();
    reg clk, reset, wr, rd;
    reg [7:0] wdata;
    wire empty, full;
    wire [7:0] rdata;
    
    // 디버깅용 포인터 신호
    wire [3:0] wptr, rptr;
    
    // FIFO 인스턴스
    FIFO u_FIFO (
        .clk(clk), 
        .reset(reset),
        .wdata(wdata),
        .wr(wr), 
        .rd(rd),
        .rdata(rdata),
        .full(full), 
        .empty(empty)
    );
    
    // 디버깅을 위한 포인터 참조
    assign wptr = u_FIFO.ctrl_unit.wptr[3:0];
    assign rptr = u_FIFO.ctrl_unit.rptr[3:0];
    
    // 클럭 생성
    always #5 clk = ~clk;
    
    initial begin
        // 초기화
        clk = 0;
        reset = 1;
        wdata = 0;
        wr = 0;
        rd = 0;
        
        // 리셋 해제
        #20 reset = 0;
        #10;
        
        // 16개 데이터 쓰기 (0x10~0x1F)
        wr = 1;
        wdata = 8'h10;
        #10 wdata = 8'h11;
        #10 wdata = 8'h12;
        #10 wdata = 8'h13;
        #10 wdata = 8'h14;
        #10 wdata = 8'h15;
        #10 wdata = 8'h16;
        #10 wdata = 8'h17;
        #10 wdata = 8'h18;
        #10 wdata = 8'h19;
        #10 wdata = 8'h1A;
        #10 wdata = 8'h1B;
        #10 wdata = 8'h1C;
        #10 wdata = 8'h1D;
        #10 wdata = 8'h1E;
        #10 wdata = 8'h1F;
        #10;
        wr = 0;
        
        // full 신호 확인
        #20;
        
        // 데이터 읽기
        rd = 1;
        #160; // 16개 데이터를 읽기 위한 정확한 시간 (16 * 10ns)
        rd = 0;
        
        // empty 신호 확인
        #20;
        
        $finish;
    end
endmodule