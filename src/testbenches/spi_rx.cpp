#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include "verilated.h"
#include "Vspi_rx.h"
#include "verilated_vcd_c.h"
#include <assert.h>

#ifndef VCD_FILE
#error no VCD_FILE define
#endif

void tick(VerilatedContext *context, VerilatedVcdC *trace, Vspi_rx *dut)
{
	context->timeInc(1);
	dut->clock = 0;
	dut->eval();
	trace->dump(context->time());
	context->timeInc(1);
	dut->clock = 1;
	dut->eval();
	trace->dump(context->time());
}

void spi_transaction(VerilatedContext *context, VerilatedVcdC *trace, Vspi_rx *dut,
	uint8_t data[], int64_t data_count,
	int64_t ticks_per_spi_clock
)
{
	dut->SPI_not_chip_select = 1;
	dut->SPI_clock = 1;
	dut->out_data_valid = 1;
	for(int64_t j = 0; j < ticks_per_spi_clock; j += 1) tick(context,trace,dut);
	dut->SPI_not_chip_select = 0;
	for(int64_t i = 0; i < data_count; i += 1)
	{
		for(int bit = 0; bit < 8; bit += 1)
		{
			dut->out_data = data[i];
			dut->SPI_clock = 1;
			for(int64_t j = 0; j < ticks_per_spi_clock; j += 1) tick(context,trace,dut);
			dut->SPI_clock = 0;
			dut->SPI_in = (data[i] >> (7 - bit)) & 1;

			for(int64_t j = 0; j < ticks_per_spi_clock; j += 1) tick(context,trace,dut);
		}
	}
	dut->SPI_clock = 1;
	for(int64_t j = 0; j < ticks_per_spi_clock; j += 1) tick(context,trace,dut);
	dut->SPI_not_chip_select = 1;
	for(int64_t j = 0; j < ticks_per_spi_clock; j += 1) tick(context,trace,dut);
}

int main(int argc, char **argv)
{
	VerilatedContext *context = new VerilatedContext();
	Verilated::traceEverOn(true);
	VerilatedVcdC *trace = new VerilatedVcdC();

	Vspi_rx *dut = new Vspi_rx(context);
	dut->trace(trace, 0);
	trace->open(".build/" VCD_FILE);

	uint8_t t1[] = {
		0x11,
		0x22,
		0x33,
		0x44,
		0x55
	};
	dut->SPI_not_chip_select = 1;
	dut->reset = 0;
	tick(context,trace,dut);
	tick(context,trace,dut);
	dut->reset = 1;
	tick(context,trace,dut);
	tick(context,trace,dut);
	dut->reset = 0;
	spi_transaction(context,trace, dut, t1, sizeof(t1), 12);
	
	tick(context,trace,dut);
	trace->close();
}



