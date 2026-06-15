#!/bin/bash

rm -f axi_io
rm -f axi_io.vcd

iverilog -Wall -s AXI_IO_tb -o axi_io axi_io.v axi_m_bfm.v axi_io_tb.v

if [ $? -eq 1 ]; then
    echo Source compilation failure
    exit 1
fi

vvp axi_io

if [ $? -ne 0 ]; then
    echo Running simulation failure
    exit 1
fi

gtkwave axi_io.gtkw

if [$? -ne 0]; then
    echo GTKWave failure
    exit 1
fi

