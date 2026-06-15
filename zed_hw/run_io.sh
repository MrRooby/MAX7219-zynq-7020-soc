#!/bin/bash
rm -f axi_io
rm -f axi_io.vcd

iverilog -Wall -s AXI_IO_tb -o axi_io -f axi_io_src.cmd

if [ $? -ne 0 ]; then
    echo "Terminating on compilation failure"
    exit 1
fi

vvp axi_io

if [ $? -ne 0 ]; then
    echo "Simulation failure - no results to display in GTKWAVE"
    exit 1
fi

if [ -ne axi_io.vcd ]; then
    echo "Simulation completed without writing VCD file. Check if the \$dumpvars task is used and executed"
    exit 1
fi

gtkwave axi_io.gtkw

