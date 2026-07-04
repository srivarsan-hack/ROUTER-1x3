module router_top_tb;

reg clock, resetn;
reg read_enb_0, read_enb_1, read_enb_2;
reg [7:0] data_in;
reg pkt_valid;

wire [7:0] data_out_0, data_out_1, data_out_2;
wire valid_out_0, valid_out_1, valid_out_2;
wire error, busy;

integer i;

router_top DUT(
    clock,
    resetn,
    read_enb_0,
    read_enb_1,
    read_enb_2,
    data_in,
    pkt_valid,
    data_out_0,
    data_out_1,
    data_out_2,
    valid_out_0,
    valid_out_1,
    valid_out_2,
    error,
    busy
);

//--------------------------------------------------
// CLOCK
//--------------------------------------------------
always #10 clock = ~clock;

//--------------------------------------------------
// INITIALIZE
//--------------------------------------------------
task initialize;
begin
    {clock,
     read_enb_0,
     read_enb_1,
     read_enb_2,
     data_in,
     pkt_valid} = 0;

    resetn = 1'b1;
end
endtask

//--------------------------------------------------
// RESET
//--------------------------------------------------
task reset;
begin
    @(negedge clock)
    resetn = 1'b0;

    @(negedge clock)
    resetn = 1'b1;
end
endtask

//--------------------------------------------------
// PACKET GEN : DA = 00 , PL = 10
//--------------------------------------------------
task packet_gen_10;

reg [5:0] payload_len;
reg [1:0] address;
reg [7:0] header;
reg [7:0] payload_data;
reg [7:0] parity_byte;

begin

    payload_len = 6'd10;
    address     = 2'b00;

    @(negedge clock);
    wait(~busy);

    parity_byte = 8'b0;
    header      = {payload_len,address};

    @(negedge clock);
    data_in   = header;
    pkt_valid = 1'b1;

    parity_byte = parity_byte ^ header;

    @(negedge clock);
    wait(~busy);

    for(i=0;i<payload_len;i=i+1)
    begin
        @(negedge clock);
        wait(~busy);

        payload_data = {$random}%256;
        data_in      = payload_data;

        parity_byte = parity_byte ^ payload_data;
    end

    @(negedge clock);
    wait(~busy);

    pkt_valid = 1'b0;
    data_in   = parity_byte;

end
endtask

//--------------------------------------------------
// PACKET GEN : DA = 01 , PL = 14
//--------------------------------------------------
task packet_gen_14;

reg [5:0] payload_len;
reg [1:0] address;
reg [7:0] header;
reg [7:0] payload_data;
reg [7:0] parity_byte;

begin

    payload_len = 6'd14;
    address     = 2'b01;

    @(negedge clock);
    wait(~busy);

    parity_byte = 8'b0;
    header      = {payload_len,address};

    @(negedge clock);
    data_in   = header;
    pkt_valid = 1'b1;

    parity_byte = parity_byte ^ header;

    @(negedge clock);
    wait(~busy);

    for(i=0;i<payload_len;i=i+1)
    begin
        @(negedge clock);
        wait(~busy);

        payload_data = {$random}%256;
        data_in      = payload_data;

        parity_byte = parity_byte ^ payload_data;
    end

    @(negedge clock);
    wait(~busy);

    pkt_valid = 1'b0;
    data_in   = parity_byte;

end
endtask

//--------------------------------------------------
// PACKET GEN : DA = 10 , PL = 16
//--------------------------------------------------
task packet_gen_16;

reg [5:0] payload_len;
reg [1:0] address;
reg [7:0] header;
reg [7:0] payload_data;
reg [7:0] parity_byte;

begin

    payload_len = 6'd16;
    address     = 2'b10;

    @(negedge clock);
    wait(~busy);

    parity_byte = 8'b0;
    header      = {payload_len,address};

    @(negedge clock);
    data_in   = header;
    pkt_valid = 1'b1;

    parity_byte = parity_byte ^ header;

    @(negedge clock);
    wait(~busy);

    for(i=0;i<payload_len;i=i+1)
    begin
        @(negedge clock);
        wait(~busy);

        payload_data = {$random}%256;
        data_in      = payload_data;

        parity_byte = parity_byte ^ payload_data;
    end

    @(negedge clock);
    wait(~busy);

    pkt_valid = 1'b0;
    data_in   = parity_byte;

end
endtask

//--------------------------------------------------
// STIMULUS
//--------------------------------------------------
initial
begin

    initialize;
    reset;

    //------------------------------------
    // FIFO 0
    //------------------------------------
    packet_gen_10;

    @(negedge clock);
    wait(valid_out_0);

    read_enb_0 = 1'b1;

    wait(~valid_out_0);

    read_enb_0 = 1'b0;

    //------------------------------------
    // FIFO 1
    //------------------------------------
    packet_gen_14;

    @(negedge clock);
    wait(valid_out_1);

    read_enb_1 = 1'b1;

    wait(~valid_out_1);

    read_enb_1 = 1'b0;

    //------------------------------------
    // FIFO 2
    //------------------------------------
    packet_gen_16;

    @(negedge clock);
    wait(valid_out_2);

    read_enb_2 = 1'b1;

    wait(~valid_out_2);

    read_enb_2 = 1'b0;

    #200;
    $finish;

end

//--------------------------------------------------
// MONITOR
//--------------------------------------------------
initial
begin
    $monitor(
    "T=%0t busy=%b error=%b vld0=%b vld1=%b vld2=%b dout0=%h dout1=%h dout2=%h",
    $time,
    busy,
    error,
    valid_out_0,
    valid_out_1,
    valid_out_2,
    data_out_0,
    data_out_1,
    data_out_2);
end

endmodule