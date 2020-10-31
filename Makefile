FPGA_PROCESSING   = top.v devices/hex_display.v devices/random_bit_generator.v devices/uart_transmitter.v
PC_UART_RECIVER_C = pc-uart-reciever/uart_recv.c
PC_UART_RECIVER_PY = pc-uart-reciever/uart_recv.py

default : simulation.out pc-uart-reciever/uart_recv

simulation.out : testbench.v ${FPGA_PROCESSING}
	iverilog $^ -o $@

run_simulation : simulation.out
	./simulation
	gtkwave dump.vcd

pc-uart-reciever/uart_recv : ${PC_UART_RECIVER_C}
	gcc --std=c99 -Wall -Werror $^ -o $@

recv_uart_py : ${PC_UART_RECIVER_PY}
	python3 ${PC_UART_RECIVER_PY}

recv_uart_c : pc-uart-reciever/uart_recv
	./pc-uart-reciever/uart_recv /dev/ttyUSB0

clean:
	rm -f simulation.out dump.vcd

.PHONY: default clean run_simulation