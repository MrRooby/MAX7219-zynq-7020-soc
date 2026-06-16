#!/bin/zsh

# 1. Create directory if missing
mkdir -p TESTBENCH/sims

echo "generating translator simulation"

# 2. Use explicit paths
iverilog -o TESTBENCH/sims/trans_sim \
 /media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/SoC-LED-Clock/SoC-LED-Clock.srcs/sources_1/new/translator.v \
 /media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/SoC-LED-Clock/SoC-LED-Clock.srcs/sources_1/new/font_rom.v \
 TESTBENCH/benches/tb_translator.v

# 3. Only run simulation if compilation succeeded
if [ $? -eq 0 ]; then
    echo "simulation done"
    ./TESTBENCH/sims/trans_sim
    echo "riding the wave"
    gtkwave TESTBENCH/sims/trans.vcd waves.gtkw
else
    echo "Compilation failed, skipping simulation."
fi