#!/bin/bash
rm -f axi_int
rm -f axi_int.vcd

iverilog -Wall -s AXI_IO_INT_tb -o axi_int -f axi_int_src.cmd

if [ $? -ne 0 ]
then
    echo Terminating on compilation failure
    exit 1
fi

vvp axi_int

if [ $? -ne 0 ]; then
    echo "Simulation failure - no results to display in GTKWAVE"
    exit 1
fi

if [ -ne axi_int.vcd ]; then
    echo "Simulation completed without writing VCD file. Check if the \$dumpvars task is used and executed"
    exit 1
fi

gtkwave axi_int.gtkw

