`timescale 1ns / 1ps

module tb_mem_ip();
    parameter ADDR_WIDTH = 4, DATA_WIDTH = 8;
    
    reg clk;
    reg [ADDR_WIDTH-1:0] waddr;
    reg [DATA_WIDTH-1:0] wdata;
    reg wr;
    wire [DATA_WIDTH-1:0] rdata;
    
    ram_ip DUT(
        .clk(clk),
        .waddr(waddr),
        .wdata(wdata),
        .wr(wr),
        .rdata(rdata)
    );
    
    always #5 clk = ~clk;
    
    integer i;
    reg [DATA_WIDTH-1:0] radn_data;
    reg [ADDR_WIDTH-1:0] rand_addr;
    
    initial begin
        clk = 0;
        waddr = 0;
        wdata = 0;
        wr = 0;
        #10;
        
        #10;//용량 푸쉬 오류 테스트 
        for(i = 0; i < 50; i = i + 1) begin
            @(posedge clk);
            rand_addr = $random % 16;
            radn_data = $random % 256;
        end
        
        // 쓰기
        wr = 1;
        waddr = rand_addr;
        wdata = radn_data;
        @(posedge clk);    // 이 줄 주석 해제 - 쓰기 동작 완료를 위해 필요
        
        // 읽기
        wr = 0;
        waddr = rand_addr;
        #10
        if(rdata === wdata) begin
            $display("pass");
        end else begin
            $display("fail, addr = %d, data=%h", waddr, rdata);
        end
        
        #100;
        $stop;
    end
endmodule