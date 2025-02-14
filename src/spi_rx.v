`default_nettype none
`timescale 10ns/1ns

// verilator lint_off UNDRIVEN
// verilator lint_off UNUSEDSIGNAL
// CPOL=1
// CPHA=1
module spi_rx (
	input clock,
	input reset,

	input  SPI_clock,
	input  SPI_in,
	output SPI_out,
	input  SPI_not_chip_select,

	output reg   in_data_valid,
	output [7:0] in_data,
	input        in_data_ready,

	input        out_data_valid,
	input  [7:0] out_data,
	output reg   out_data_ready
);
	wire SPI_clock_sampled, SPI_clock_rising, SPI_clock_falling;
	sampler SPI_clock_sampler(
		.clock(clock),
		.reset(reset),
		.signal(SPI_clock),
		.sampled_signal(SPI_clock_sampled),
		.falling(SPI_clock_falling),
		.rising(SPI_clock_rising)
	);
	wire SPI_not_chip_select_sampled, SPI_not_chip_select_rising, SPI_not_chip_select_falling;
	sampler SPI_not_chip_select_sampler(
		.clock(clock),
		.reset(reset),
		.signal(SPI_not_chip_select),
		.sampled_signal(SPI_not_chip_select_sampled),
		.falling(SPI_not_chip_select_falling),
		.rising(SPI_not_chip_select_rising)
	);
	wire SPI_in_sampled, SPI_in_rising, SPI_in_falling;
	sampler SPI_in_sampler(
		.clock(clock),
		.reset(reset),
		.signal(SPI_in),
		.sampled_signal(SPI_in_sampled),
		.falling(SPI_in_falling),
		.rising(SPI_in_rising)
	);
	wire SPI_out_sampled, SPI_out_rising, SPI_out_falling;
	sampler SPI_out_sampler(
		.clock(clock),
		.reset(reset),
		.signal(SPI_out),
		.sampled_signal(SPI_out_sampled),
		.falling(SPI_out_falling),
		.rising(SPI_out_rising)
	);

	wire [7:0] SPI_in_shift_data;
	serial_in_parallel_out #(.DATA_WIDTH(8)) SPI_in_shifter (
		.clock(clock),
		.reset(reset),
		.shift_trigger(SPI_clock_rising),
		.signal(SPI_in_sampled),
		.data(SPI_in_shift_data)
	);

	localparam STATE_idle = 0;
	localparam STATE_io   = 1;

	reg [3:0] state = STATE_idle;
	reg [2:0] bit_counter;

	always @(posedge clock)
	if(reset)
		bit_counter <= 0;
	else case(state)
	STATE_io:
	begin
		if(SPI_clock_rising)
			bit_counter <= bit_counter + 1;
		else if(bit_counter == 7)
			bit_counter <= 0;

		if(bit_counter == 7)
			in_data_valid <= 1'b1;
		else
			in_data_valid <= 1'b0;
	end
	default: begin end
	endcase

	always @(posedge clock)
	if(reset)
	begin
		state <= STATE_idle;
	end else begin
		if(SPI_not_chip_select_falling)
			state <= STATE_io;
		if(SPI_not_chip_select_rising)
			state <= STATE_idle;
	end
	
endmodule
