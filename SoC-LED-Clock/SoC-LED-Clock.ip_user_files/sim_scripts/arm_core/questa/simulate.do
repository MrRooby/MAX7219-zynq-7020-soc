onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib arm_core_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {arm_core.udo}

run 1000ns

quit -force
