VERILOG_SRC=$(wildcard src/*.v)
VERILOG_SRC+=$(wildcard modules/*/src/*.v)
VERILATOR_FLAGS=-Wall -Mdir .build --trace --timing

lint: $(VERILOG_SRC)
	verilator --lint-only $(VERILOG_SRC) --top-module spi_rx
# TODO	verilator --lint-only $(VERILOG_SRC) --top-module spi_tx

.build/test_spi_rx: $(VERILOG_SRC) src/testbenches/spi_rx.cpp
	verilator --cc --exe --build $(VERILATOR_FLAGS) $^ -o test_spi_rx --trace --top-module spi_rx -CFLAGS "-DVCD_FILE=\\\"test_spi_rx.vcd\\\"" -j 0

# TODO .build/test_spi_tx: $(VERILOG_SRC)
# TODO	verilator --cc --exe --build -Wall $^ -Mdir .build -o test_spi_tx --trace -top-module spi_tx

all: lint test


.PHONY: all test

test: .build/test_spi_rx
	./.build/test_spi_rx






