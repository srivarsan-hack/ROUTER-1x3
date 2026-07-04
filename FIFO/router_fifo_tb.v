/* TB
Router 1x3  Project 
Sub Block 1 : FIFO 
*/

module router_fifo_tb();

reg lfd_state;
reg [7:0] data_in;
reg clock, resetn, read_enb, write_enb, soft_reset;
wire [7:0] data_out;
wire full, empty;
integer i;
parameter cycle = 10;

router_fifo dut(
    .clock(clock),
    .resetn(resetn),
    .write_enb(write_enb),
    .soft_reset(soft_reset),
    .read_enb(read_enb),
    .data_in(data_in),
    .lfd_state(lfd_state),
    .empty(empty),
    .data_out(data_out),
    .full(full)
);

always
begin
    #(cycle/2) clock = 1'b0;
    #(cycle/2) clock = 1'b1;
end
// SOFT RESET
task soft_resetf;
begin
    @(negedge clock);
    soft_reset = 1'b1;

    @(negedge clock);
    soft_reset = 1'b0;
end
endtask
// INITIALIZE
task initialize;
begin
    clock      = 1'b0;
    resetn     = 1'b1;
    read_enb   = 1'b0;
    write_enb  = 1'b0;
    soft_reset = 1'b0;
    lfd_state  = 1'b0;
    data_in    = 8'b0;
end
endtask

// RESET
task resetf;
begin
    @(negedge clock);
    resetn = 1'b0;

    @(negedge clock);
    resetn = 1'b1;
end
endtask
// PACKET GENERATION
task pkt_gen;

reg [7:0] payload_data, parity, header;
reg [5:0] payload_len;
reg [1:0] addr;

begin

    @(negedge clock);

    payload_len = 6'd10;
    addr        = 2'b01;

    header = {payload_len, addr};  // header = 41

    data_in   = header;
    lfd_state = 1'b1;
    write_enb = 1'b1;

    for(i=0; i<payload_len; i=i+1)
    begin
        @(negedge clock);

        lfd_state   = 1'b0;
        payload_data = {$random}%256;
        data_in      = payload_data;
    end

    @(negedge clock);

    parity  = {$random}%256;
    data_in = parity;

    @(negedge clock);
    write_enb = 1'b0;

end

endtask
// READ ENABLE
task read_enable;
begin
    @(negedge clock);
    read_enb  = 1'b1;
    write_enb = 1'b0;
end
endtask
// STIMULUS
initial
begin
    initialize;
    resetf;
    pkt_gen;

    repeat(5)
        @(negedge clock);

    read_enable;

    repeat(30)
        @(negedge clock);

    $finish;
end
// MONITOR
initial
begin

$monitor("time=%0t soft_reset=%b lfd_state=%b full=%b empty=%b data_in=%h data_out=%h resetn=%b read_enb=%b write_enb=%b rd_ptr=%d wr_ptr=%d count=%d",
          $time,
          soft_reset,
          lfd_state,
          full,
          empty,
          data_in,
          data_out,
          resetn,
          read_enb,
          write_enb,
          dut.rd_pointer,
          dut.wr_pointer,
          dut.count);

end

endmodule