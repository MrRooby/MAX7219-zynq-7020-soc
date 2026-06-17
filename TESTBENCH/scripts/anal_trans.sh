#!/bin/zsh

# Initialize flag
LAUNCH_GTKWAVE=false

# Check for --gtk flag
if [[ "$1" == "--gtk" ]]; then
    LAUNCH_GTKWAVE=true
fi

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
    
    if [ "$LAUNCH_GTKWAVE" = true ]; then
        echo "riding the wave"
        gtkwave TESTBENCH/sims/trans.vcd
    else
        echo "Simulation finished. Run with --gtk to open waveform."
    fi
else
    echo "Compilation failed, skipping simulation."
fi