`timescale 1ns / 1ps

module tb_fifo_uart( );

    reg clk,rst,rx;
    wire tx;

     uart_fifo_top ddt(
        .clk(clk),
        .rst(rst),
        .rx(rx),
        .tx(tx)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst = 1;
        rx = 0;
        #20 rst = 0;
        #10

        #10 rx = 0;  // start
        #(10 * 10417)  rx = 1;  // data0
        #(10 * 10417)  rx = 0;  // data1
        #(10 * 10417)  rx = 0;  // data2
        #(10 * 10417)  rx = 0;  // data3
        #(10 * 10417)  rx = 1;  // data4
        #(10 * 10417)  rx = 1;  // data5
        #(10 * 10417)  rx = 0;  // data6
        #(10 * 10417)  rx = 0;  // data7
        #(10 * 10417)  rx = 1;  // stop
        #10000
        $finish;
    end




    // task send_data(input [7:0] data);
    // integer i;
    // begin
    //     $display("Sending data: %h", data);

    //     // start bit
    //     rx = 0;
    //     #(10 * 10417);

    //     // Data bits
    //     for (i=0; i<8; i=i+1) begin
    //         rx = data[i];
    //         #(10 * 10417);
    //     end

    //     // Stop bit
    //     rx = 1;
    //     #(10 * 10417);

    //     $display("Data sent: %h", data);
    // end
    // endtask


endmodule





















// `timescale 1ns / 1ps uart_fifo_top

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











