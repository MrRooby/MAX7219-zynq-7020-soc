#!/bin/bash

rm -f axi_io_int
rm -f axi_io_int.vcd

iverilog -Wall -s AXI_IO_INT_tb -o axi_io_int axi_io_int.v axi_m_bfm.v axi_io_int_tb.v

if [ $? -eq 1 ]; then
    echo Source compilation failure
    exit 1
fi

vvp axi_io_int

if [ $? -ne 0 ]; then
    echo Running simulation failure
    exit 1
fi

gtkwave axi_io_int.gtkw

if [$? -ne 0]; then
    echo GTKWave failure
    exit 1
fi

