/* 

Router 1x3  Project 

Sub Block : SYNCHRONIZER TB

*/

module router_sync_tb;

	reg detect_add, write_enb_reg, clock, resetn, read_enb_0, read_enb_1, read_enb_2, empty_0, empty_1, empty_2, full_0, full_1, full_2;
	reg [1:0] data_in;
	
	wire vld_out_0, vld_out_1, vld_out_2, soft_reset_0, soft_reset_1, soft_reset_2;
	wire  fifo_full;
	wire  [2:0] write_enb;

	router_sync DUT (detect_add, data_in, write_enb_reg, clock, resetn, vld_out_0, vld_out_1, vld_out_2,
						read_enb_0, read_enb_1, read_enb_2, write_enb, fifo_full, empty_0, empty_1, empty_2, soft_reset_0, 
						soft_reset_1, soft_reset_2, full_0, full_1, full_2);
						
	
	task initialize;
		begin 
			{detect_add, write_enb_reg, clock, resetn, read_enb_0, read_enb_1, read_enb_2, full_0, full_1, full_2} = 0;
			{ empty_0, empty_1, empty_2} = 3'b111;
			data_in = 2'b00;
			repeat(5) 
			@(negedge clock)resetn = 0;
			@(negedge clock)resetn = 1;
			#20;
		end
	endtask
	
	initial forever #5 clock = ~clock;
	
	
	// detect add and data_in
	task address_capture;
		input det_add;
		input [1:0] d_in;
		begin
			@(negedge clock)
				begin 
					detect_add = det_add;
					data_in = d_in;
				end
			@(negedge clock) detect_add = 0;
		end
	endtask
	
	// Write Enable Reg 
	task write_enable_reg;
		input w_en;
		begin
			@(negedge clock) write_enb_reg = w_en;
		end
	endtask
	
	// Read and soft Reset Check
	task read_valid_check;
		input r_enb_0, r_enb_1, r_enb_2;
			@(negedge clock)
				begin
					read_enb_0 = r_enb_0;
					read_enb_1 = r_enb_1;
					read_enb_2 = r_enb_2;
				end
	endtask
	
	task empty;
		input em0, em1, em2;
		@(negedge clock)
		begin 
			empty_0 = em0;
			empty_1 = em1;
			empty_2 = em2;
		end
	endtask 
	
	task full;
		input f0, f1, f2;
		@(negedge clock)
		begin 
			full_0 = f0;
			full_1 = f1;
			full_2 = f2;
		end
	endtask 
	
	initial 
		begin 
			initialize;
			address_capture(1'b0, 2'b11);
			address_capture(1'b1, 2'b10);
			empty(0, 0, 0);
			full(1, 1, 1);
			write_enable_reg(1);
			read_valid_check(0, 0, 0);
			#500;
			empty(0, 0, 1);
			read_valid_check(1, 0, 1);
			$finish;
			
		end

endmodule 

