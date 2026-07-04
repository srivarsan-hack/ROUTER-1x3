/*

Router 1x3 Project

Sub Block : FSM TB

*/

module router_fsm_tb();

reg clock;
reg resetn;
reg pkt_valid;
reg parity_done;
reg [1:0] data_in;

reg soft_reset_0;
reg soft_reset_1;
reg soft_reset_2;

reg fifo_full;
reg low_pkt_valid;

reg fifo_empty_0;
reg fifo_empty_1;
reg fifo_empty_2;

wire busy;
wire detect_add;
wire ld_state;
wire full_state;
wire laf_state;
wire write_enb_reg;
wire rst_int_reg;
wire lfd_state;


// DUT

router_fsm DUT(
.clock(clock),
.resetn(resetn),
.pkt_valid(pkt_valid),
.busy(busy),
.parity_done(parity_done),
.data_in(data_in),
.soft_reset_0(soft_reset_0),
.soft_reset_1(soft_reset_1),
.soft_reset_2(soft_reset_2),
.fifo_full(fifo_full),
.low_pkt_valid(low_pkt_valid),
.fifo_empty_0(fifo_empty_0),
.fifo_empty_1(fifo_empty_1),
.fifo_empty_2(fifo_empty_2),
.detect_add(detect_add),
.ld_state(ld_state),
.full_state(full_state),
.laf_state(laf_state),
.write_enb_reg(write_enb_reg),
.rst_int_reg(rst_int_reg),
.lfd_state(lfd_state)
);


// Clock Generation

initial
clock = 0;

always #5 clock = ~clock;


// Initialize

task initialize;
begin
    pkt_valid      = 1'b0;
    parity_done    = 1'b0;
    data_in        = 2'b00;

    soft_reset_0   = 1'b0;
    soft_reset_1   = 1'b0;
    soft_reset_2   = 1'b0;

    fifo_full      = 1'b0;
    low_pkt_valid  = 1'b0;

    fifo_empty_0   = 1'b1;
    fifo_empty_1   = 1'b1;
    fifo_empty_2   = 1'b1;

    resetn         = 1'b1;
end
endtask


// Reset

task resetf;
begin
    @(negedge clock);
    resetn = 1'b0;

    @(negedge clock);
    resetn = 1'b1;
end
endtask


//--------------------------------------------------
// TASK 1
// DA -> LFD -> LD -> LP -> CPE -> DA
//--------------------------------------------------

task t1();
begin
    @(negedge clock)
    pkt_valid = 1'b1;

    data_in = 2'b01;
    fifo_empty_1 = 1'b1;

    @(negedge clock)
    @(negedge clock)

    fifo_full = 1'b0;
    pkt_valid = 1'b0;

    @(negedge clock)
    @(negedge clock)

    fifo_full = 1'b0;
end
endtask


//--------------------------------------------------
// TASK 2
// DA -> LFD -> LD -> FFS -> LAF -> LP -> CPE -> DA
//--------------------------------------------------

task t2();
begin
    @(negedge clock)

    pkt_valid = 1'b1;
    data_in = 2'b01;
    fifo_empty_1 = 1'b1;

    @(negedge clock)
    @(negedge clock)

    fifo_full = 1'b1;

    @(negedge clock)

    fifo_full = 1'b0;

    @(negedge clock)

    parity_done = 1'b0;
    low_pkt_valid = 1'b1;

    @(negedge clock)
    @(negedge clock)

    fifo_full = 1'b0;
end
endtask


//--------------------------------------------------
// TASK 3
// DA -> LFD -> LD -> FFS -> LAF -> LD -> LP -> CPE -> DA
//--------------------------------------------------

task t3();
begin
    @(negedge clock)

    pkt_valid = 1'b1;
    data_in = 2'b01;
    fifo_empty_1 = 1'b1;

    @(negedge clock)
    @(negedge clock)

    fifo_full = 1'b1;

    @(negedge clock)

    fifo_full = 1'b0;

    @(negedge clock)

    parity_done = 1'b0;
    low_pkt_valid = 1'b0;

    @(negedge clock)

    fifo_full = 1'b0;
    pkt_valid = 1'b0;

    @(negedge clock)
    @(negedge clock)

    fifo_full = 1'b0;
end
endtask


//--------------------------------------------------
// TASK 4
// DA -> LFD -> LD -> LP -> CPE -> FFS -> LAF -> DA
//--------------------------------------------------

task t4();
begin
    @(negedge clock)

    pkt_valid = 1'b1;
    data_in = 2'b01;
    fifo_empty_1 = 1'b1;

    @(negedge clock)
    @(negedge clock)

    fifo_full = 1'b0;
    pkt_valid = 1'b0;

    @(negedge clock)
    @(negedge clock)

    fifo_full = 1'b1;

    @(negedge clock)

    fifo_full = 1'b0;

    @(negedge clock)

    parity_done = 1'b1;
end
endtask


//--------------------------------------------------
// Stimulus
//--------------------------------------------------

initial
begin

    initialize;
    resetf;

    t1;

    #50;

    initialize;
    resetf;

    t2;

    #50;

    initialize;
    resetf;

    t3;

    #50;

    initialize;
    resetf;

    t4;

    #100;

    $finish;

end


//--------------------------------------------------
// Monitor
//--------------------------------------------------

initial
begin
    $monitor(
    "T=%0t PS=%b busy=%b detect_add=%b lfd=%b ld=%b full=%b laf=%b wr_en=%b rst=%b",
    $time,
    DUT.present_state,
    busy,
    detect_add,
    lfd_state,
    ld_state,
    full_state,
    laf_state,
    write_enb_reg,
    rst_int_reg);
end

endmodule
