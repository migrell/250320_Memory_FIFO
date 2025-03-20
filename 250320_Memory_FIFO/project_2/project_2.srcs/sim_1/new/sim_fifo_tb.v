// 테스트벤치
module tb_FIFO();
    reg clk, reset, wr, rd;
    reg [7:0] wdata;
    wire empty, full;
    wire [7:0] rdata;
    
    // 디버깅용 포인터 신호
    wire [3:0] wptr, rptr;
    
    // 변수 i 선언
    integer i;
    
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
        #10 
        reset = 0;
        #10;
        
        // 쓰기 테스트
        wr = 1;
        
        for(i=0; i<17; i = i + 1) begin
            wdata = i;
            #10;
        end
        
        // 읽기 empty 테스트
        wr = 0;
        rd = 1;
        
        for(i=0; i<17; i = i + 1) begin
            #10;
        end
        
        // 초기화 과정
        wr = 0;
        rd = 0;
        #10;
        
        // 동시 읽고 쓰기
        wr = 1;
        rd = 1;
        
        for(i=0; i<17; i = i + 1) begin
            wdata = i*2+1;
            #10;
        end
    end
endmodule