#!/bin/zsh
# Initialize flag
LAUNCH_GTKWAVE=false
# Check for --gtk flag
if [[ "$1" == "--gtk" ]]; then
    LAUNCH_GTKWAVE=true
fi
# 1. Create directory if missing
mkdir -p TESTBENCH/sims
echo "generating state machine simulation"
# 2. Use explicit paths
iverilog -o TESTBENCH/sims/state_sim \
 /media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/SoC-LED-Clock/SoC-LED-Clock.srcs/sources_1/new/translator.v \
 /media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/SoC-LED-Clock/SoC-LED-Clock.srcs/sources_1/new/state_machine.v \
 /media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/TANG/dot_matrix_fifo.v \
 /media/bartek/LEXAR/SUT/SoC/Projekt-LED-Matrix-Clock/SoC-LED-Clock/SoC-LED-Clock.srcs/sources_1/new/font_rom.v \
 TESTBENCH/benches/tb_state_machine.v
# 3. Only run simulation if compilation succeeded
if [ $? -eq 0 ]; then
    echo "simulation done"
    # run from the sims dir so state.vcd is written there
    (cd TESTBENCH/sims && vvp state_sim)

    if [ "$LAUNCH_GTKWAVE" = true ]; then
        echo "riding the wave"
        gtkwave TESTBENCH/sims/state.vcd &
    else
        echo "Simulation finished. Run with --gtk to open waveform."
    fi
    if [ "$LAUNCH_GTKWAVE" = true ]; then
        echo "riding the wave"
        if [ -f TESTBENCH/sims/state.gtkw ]; then
            gtkwave TESTBENCH/sims/state.vcd TESTBENCH/sims/state.gtkw &
        else
            gtkwave TESTBENCH/sims/state.vcd &
    fi
fi
else
    echo "Compilation failed, skipping simulation."
fi
