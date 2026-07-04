module router_reg(
    input clock,
    input resetn,
    input pkt_valid,
    input [7:0] data_in,

    input fifo_full,
    input rst_int_reg,
    input detect_add,
    input ld_state,
    input laf_state,
    input full_state,
    input lfd_state,

    output reg parity_done,
    output reg low_pkt_valid,
    output reg err,
    output reg [7:0] dout
);

reg [7:0] header_byte;
reg [7:0] fifo_full_state_byte;
reg [7:0] internal_parity;
reg [7:0] packet_parity;


//=====================================================
// Output Logic
//=====================================================

always @(posedge clock)
begin
    if(!resetn)
        dout <= 8'b0;

    else if(lfd_state)
        dout <= header_byte;

    else if(ld_state && !fifo_full)
        dout <= data_in;

    else if(laf_state)
        dout <= fifo_full_state_byte;

    else
        dout <= dout;
end


//=====================================================
// Header Byte and FIFO Full State Byte Logic
//=====================================================

always @(posedge clock)
begin
    if(!resetn)
    begin
        header_byte <= 8'b0;
        fifo_full_state_byte <= 8'b0;
    end

    else
    begin

        if(detect_add && pkt_valid &&
           (data_in[1:0] != 2'b11))
            header_byte <= data_in;

        else if(ld_state && fifo_full)
            fifo_full_state_byte <= data_in;

    end
end


//=====================================================
// Parity Done Logic
//=====================================================

always @(posedge clock)
begin

    if(!resetn)
        parity_done <= 1'b0;

    else
    begin

        if(ld_state && !fifo_full && !pkt_valid)
            parity_done <= 1'b1;

        else if(laf_state &&
                low_pkt_valid &&
                !parity_done)
            parity_done <= 1'b1;

        else if(detect_add)
            parity_done <= 1'b0;

    end
end


//=====================================================
// Low Packet Valid Logic
//=====================================================

always @(posedge clock)
begin

    if(!resetn)
        low_pkt_valid <= 1'b0;

    else
    begin

        if(rst_int_reg)
            low_pkt_valid <= 1'b0;

        else if(!pkt_valid && ld_state)
            low_pkt_valid <= 1'b1;

    end
end


//=====================================================
// Packet Parity Logic
//=====================================================

always @(posedge clock)
begin

    if(!resetn)
        packet_parity <= 8'b0;

    else if(
            (ld_state && !pkt_valid && !fifo_full)
            ||
            (laf_state &&
             low_pkt_valid &&
             !parity_done)
           )
        packet_parity <= data_in;

    else if(!pkt_valid && rst_int_reg)
        packet_parity <= 8'b0;

    else if(detect_add)
        packet_parity <= 8'b0;

end


//=====================================================
// Internal Parity Calculation
//=====================================================

always @(posedge clock)
begin

    if(!resetn)
        internal_parity <= 8'b0;

    else if(detect_add)
        internal_parity <= 8'b0;

    else if(lfd_state)
        internal_parity <= header_byte;

    else if(ld_state &&
            pkt_valid &&
            !full_state)
        internal_parity <= internal_parity ^ data_in;

    else if(!pkt_valid && rst_int_reg)
        internal_parity <= 8'b0;

end


//=====================================================
// Error Logic
//=====================================================

always @(posedge clock)
begin

    if(!resetn)
        err <= 1'b0;

    else
    begin

        if(parity_done &&
           (internal_parity != packet_parity))
            err <= 1'b1;

        else
            err <= 1'b0;

    end
end

endmodule