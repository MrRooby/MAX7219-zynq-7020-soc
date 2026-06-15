del /F axi_int
del /F axi_int.vcd

iverilog -Wall -s AXI_IO_INT_tb -o axi_int  axi_io_int.v axi_m_bfm.v axi_io_int_tb.v
if ERRORLEVEL 1 goto ON_ERROR

vvp axi_int
if ERRORLEVEL 1 goto ON_ERROR

goto SIM_EXIT

:ON_ERROR
echo Terminating on error.

:SIM_EXIT

