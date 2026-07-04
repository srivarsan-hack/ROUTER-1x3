/* RTL
Router 1x3  Project 
Sub Block 1 : FIFO 
*/
module router_fifo(clock, resetn, write_enb, soft_reset, read_enb, data_in, lfd_state, empty, data_out, full);
    parameter depth = 16 ,width = 8;

    input clock, resetn, write_enb, soft_reset, read_enb, lfd_state;
    input [7:0] data_in;

    output empty, full;
    output reg [7:0] data_out;

    integer i;

    reg [4:0] wr_pointer, rd_pointer;
    reg [width:0] mem [0:depth-1];
    reg [6:0] count;
    reg temp;

    wire count_zero;

    assign count_zero = (count == 0);

    /* Delay lfd_state by one clock cycle and clear it during resetn and soft_reset */
    always @(posedge clock)
    begin
        if(!resetn || soft_reset)
            temp <= 1'b0;
        else
            temp <= lfd_state;
    end

    // Write Logic
    always @(posedge clock)
    begin
        if(!resetn || soft_reset)
        begin
            for(i=0; i<depth; i=i+1)
                mem[i] <= 9'b0;

            wr_pointer <= 5'd0;
        end

        else if(write_enb && !full)
        begin

            // Store header flag and data byte
            mem[wr_pointer[3:0]] <= {temp,data_in};

            // Increment write pointer
            wr_pointer <= wr_pointer + 1'b1;

        end
    end

    /*READ LOGIC
    Read data from FIFO when read_enb is asserted and FIFO is not empty.
    */

    always @(posedge clock)
    begin

        if(!resetn)
        begin
            data_out   <= 8'd0;
            rd_pointer <= 5'd0;
        end

        else if(soft_reset)
        begin
            data_out   <= 8'bz;
            rd_pointer <= 5'd0;
        end
		
        else if(read_enb && !empty)
        begin

            // Read data from FIFO
            data_out <= mem[rd_pointer[3:0]][7:0];

            // Increment read pointer
            rd_pointer <= rd_pointer + 1'b1;

        end
		else if(count_zero && empty)
        begin
            data_out <= 8'bz;
        end

    end

    /* Internal Counter
        count = payload_length + 1(parity)
        Payload/Parity byte: decrement count
    */

    always @(posedge clock)
    begin

        if(!resetn || soft_reset)
            count <= 7'd0;

        else if(read_enb && !empty)
        begin

            // Header detected
            if(mem[rd_pointer[3:0]][8])
                count <= mem[rd_pointer[3:0]][7:2] + 1'b1;

            // Payload/Parity bytes
            else if(count != 0)
                count <= count - 1'b1;

        end

    end

    // FULL AND EMPTY Logic

    assign full  = (wr_pointer[4] != rd_pointer[4]) &&
                   (wr_pointer[3:0] == rd_pointer[3:0]);

    assign empty = (wr_pointer == rd_pointer);

endmodule