echo off
if not exist %1.edf goto EDF_ERR
if not exist %1.ucf goto UCF_ERR
if not exist bit.ut goto UT_ERR

ngdbuild %1
if ERRORLEVEL 1 goto NGD_ERR

map -w %1
if ERRORLEVEL 1 goto MAP_ERR

par -w %1 %1_r
if ERRORLEVEL 1 goto PAR_ERR

bitgen -f bit.ut %1_r.ncd
if ERRORLEVEL 1 goto BIT_ERR

echo Implementation successful
goto IMPL_EXIT

:EDF_ERR
echo Error: Specified file: '%1' does not exists.
goto IMPL_ERR

:UCF_ERR
echo Error: Specified  UCF file: '%1.ucf' does not exists.
goto IMPL_ERR

:UT_ERR
echo Error: Missing bit.ut configuration file for bitgen
goto IMPL_ERR

:NGD_ERR
echo NGDBUILD program has faild - Please examine log file!
goto IMPL_ERR

:MAP_ERR
echo Design mapping program has faild - Please examine log file!
goto IMPL_ERR

:PAR_ERR
echo Design Place and Route program has faild - Please examine log file!
goto IMPL_ERR

:BIT_ERR
echo Design Bit strem generation has faild - Please examine log file!
goto IMPL_ERR

:IMPL_ERR
echo Implementation terminated on error.

:IMPL_EXIT

