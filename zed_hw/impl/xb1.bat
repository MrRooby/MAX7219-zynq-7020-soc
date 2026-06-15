echo off
if not exist %1.edf goto EDF_ERR

ngdbuild %1
if ERRORLEVEL 1 goto NGD_ERR

map -w %1
if ERRORLEVEL 1 goto MAP_ERR

par -w %1 %1_r
if ERRORLEVEL 1 goto PAR_ERR

netgen -ofmt verilog -w -tb -vcd %1_r.ncd
if ERRORLEVEL 1 goto NETG_ERR

echo Implementation succesful
goto IMPL_EXIT

:EDF_ERR
echo Error: Specified file: '%1' does not exists.
goto IMPL_ERR

:NGD_ERR
echo NGDBUILD program has faild - Please examine log file.
goto IMPL_ERR

:MAP_ERR
echo Design mapping program has faild - Please examine log file.
goto IMPL_ERR

:PAR_ERR
echo Design Place and Route program has faild - Please examine log file.
goto IMPL_ERR

:NETG_ERR
echo Design backannotation - simulation netlist generation error.
goto IMPL_ERR

:BIT_ERR
echo Design Bit strem generation has faild - Please examine log file!
goto IMPL_ERR

:IMPL_ERR
echo Implementation terminated on error.

:IMPL_EXIT

