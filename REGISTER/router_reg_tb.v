module router_reg_tb;

reg clock;
reg resetn;
reg pkt_valid;
reg fifo_full;
reg rst_int_reg;
reg detect_add;
reg ld_state;
reg laf_state;
reg full_state;
reg lfd_state;

reg [7:0] data_in;

wire parity_done;
wire low_pkt_valid;
wire err;
wire [7:0] dout;

integer i;

// DUT

router_reg DUT (
    .clock(clock),
    .resetn(resetn),
    .pkt_valid(pkt_valid),
    .data_in(data_in),
    .fifo_full(fifo_full),
    .rst_int_reg(rst_int_reg),
    .detect_add(detect_add),
    .ld_state(ld_state),
    .laf_state(laf_state),
    .full_state(full_state),
    .lfd_state(lfd_state),
    .parity_done(parity_done),
    .low_pkt_valid(low_pkt_valid),
    .err(err),
    .dout(dout)
);

//====================================================
// INITIALIZE
//====================================================

task initialize;
begin
    {clock,
     resetn,
     pkt_valid,
     fifo_full,
     rst_int_reg,
     detect_add,
     ld_state,
     laf_state,
     full_state,
     lfd_state} = 0;

    data_in = 8'h00;
end
endtask

//====================================================
// RESET
//====================================================

task reset;
begin
    @(negedge clock)
    resetn = 1'b0;

    @(negedge clock)
    resetn = 1'b1;
end
endtask

//====================================================
// PACKET 1
// Normal Packet
//====================================================

task packet1;

reg [7:0] header;
reg [7:0] payload_data;
reg [7:0] parity;

reg [5:0] payloadlen;

begin

    @(negedge clock);

    payloadlen = 6'd8;
    parity     = 8'h00;

    detect_add = 1'b1;
    pkt_valid  = 1'b1;

    header = {payloadlen,2'b10};

    data_in = header;

    parity = parity ^ data_in;

    @(negedge clock);

    detect_add = 1'b0;
    lfd_state  = 1'b1;

    for(i=0;i<payloadlen;i=i+1)
    begin

        @(negedge clock);

        lfd_state = 1'b0;
        ld_state  = 1'b1;
        fifo_full = 1'b0;

        payload_data = $random % 256;

        data_in = payload_data;

        parity = parity ^ data_in;

    end

    @(negedge clock);

    pkt_valid = 1'b0;
    ld_state  = 1'b1;

    data_in = parity;

    @(negedge clock);

end

endtask

//====================================================
// PACKET 2
// Error Packet
//====================================================

task packet2;

reg [7:0] header;
reg [7:0] payload_data;
reg [7:0] parity;

reg [5:0] payloadlen;

begin

    @(negedge clock);

    payloadlen = 6'd16;
    parity     = 8'h00;

    detect_add = 1'b1;
    pkt_valid  = 1'b1;

    header = {payloadlen,2'b10};

    data_in = header;

    parity = parity ^ data_in;

    @(negedge clock);

    detect_add = 1'b0;
    lfd_state  = 1'b1;

    for(i=0;i<payloadlen;i=i+1)
    begin

        @(negedge clock);

        lfd_state = 1'b0;
        ld_state  = 1'b1;
        fifo_full = 1'b0;

        payload_data = $random % 256;

        data_in = payload_data;

        parity = parity ^ data_in;

    end

    @(negedge clock);

    pkt_valid = 1'b0;
    ld_state  = 1'b1;

    data_in = $random % 256;     // wrong parity

    @(negedge clock);

end

endtask

//====================================================
// CLOCK
//====================================================

always
    #10 clock = ~clock;

//====================================================
// MONITOR
//====================================================

initial
begin

$monitor(
"T=%0t data=%h dout=%h pkt_valid=%b lfd=%b ld=%b parity_done=%b low_pkt_valid=%b err=%b",
$time,
data_in,
dout,
pkt_valid,
lfd_state,
ld_state,
parity_done,
low_pkt_valid,
err);

end

//====================================================
// STIMULUS
//====================================================

initial
begin

    initialize;

    reset;

    //------------------------------------------------
    // TESTCASE 1 : NORMAL PACKET
    //------------------------------------------------

    packet1;

    repeat(5)
    @(negedge clock);

    rst_int_reg = 1'b1;

    @(negedge clock);

    rst_int_reg = 1'b0;

    //------------------------------------------------
    // TESTCASE 2 : WRONG PARITY
    //------------------------------------------------

    packet2;

    repeat(10)
    @(negedge clock);

    $finish;

end

endmodule