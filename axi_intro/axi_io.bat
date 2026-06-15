@echo off
del /F axi_io
del /F axi_io.vcd

iverilog -Wall -s AXI_IO_tb -o axi_io axi_io.v axi_m_bfm.v axi_io_tb.v
if ERRORLEVEL 1 goto ON_ERROR

vvp axi_io
if ERRORLEVEL 1 goto ON_ERROR

gtkwave axi_io.gtkw
if ERRORLEVEL 1 goto ON_ERROR

goto SIM_EXIT

:ON_ERROR
echo Terminating on error.

:SIM_EXIT

