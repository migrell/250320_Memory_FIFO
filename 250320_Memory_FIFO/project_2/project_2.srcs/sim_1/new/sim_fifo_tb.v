// 테스트벤치
module tb_FIFO();
    reg clk, reset, wr, rd;
    reg [7:0] wdata;
    wire empty, full;
    wire [7:0] rdata;
    
    // 디버깅용 포인터 신호
    wire [3:0] wptr, rptr;
    
    // 변수 선언
    integer i;
    integer rand_rd;
    integer rand_wr;
    reg [7:0] compare_data [0:15];
    integer write_count;
    integer read_count;
    
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
        write_count = 0;
        read_count = 0;
        
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
        
        wr = 0;
        rd = 0;
        write_count = 0;
        read_count = 0;
        
        // 랜덤 쓰기/읽기 테스트
        for (i=0; i<50; i=i+1) begin
            @(negedge clk); // 쓰기 wdata를 negedge에서 시작하기 위함
            
            // 쓰기 로직
            rand_wr = $random%2; // wr 랜덤으로 1,0 만들기
            if(~full & rand_wr) begin // full 아니면서 wr 1일때만 새로운 wdata 생성
                wdata = $random%256; // wdata random 값 생성
                compare_data[write_count%16] = wdata; // 나중에 rdata와 비교하기 위해 저장
                write_count = write_count + 1;
                wr = 1;
            end else begin
                wr = 0;
            end
            
            // 읽기 로직
            rand_rd = $random%2; // rd random으로 생성 0,1
            if(~empty & rand_rd) begin // empty가 아니고 rand_rd가 1일 때
                rd = 1;
                if(rdata == compare_data[read_count%16]) begin // read한 횟수에 맞춰 비교
                    $display("pass");
                end else begin
                    $display("fail: rdata = %h, compare_data = %h", rdata, compare_data[read_count%16]); // fail시 값 출력
                end
                read_count = read_count + 1;
            end else begin
                rd = 0;
            end
        end
    end
endmodule