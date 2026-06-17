#include <stdint.h>
#include <string>
#include "xparameters.h"

// Memory-mapped register access using volatile pointers
#define REG_ASCII_0      (*(volatile uint32_t *)(XPAR_XGPIO_0_BASEADDR + 0x00))
#define REG_CTRL         (*(volatile uint32_t *)(XPAR_XGPIO_1_BASEADDR + 0x00)) // Bit 0/1 controls

// Direction control
#define REG_ASCII_DIR_0  (*(volatile uint32_t *)(XPAR_XGPIO_0_BASEADDR + 0x04))
#define REG_CTRL_DIR     (*(volatile uint32_t *)(XPAR_XGPIO_0_BASEADDR + 0x04))

int main() {
    // Set direction to output
    REG_ASCII_DIR_0 = 0x00000000;
    REG_CTRL_DIR    = 0x00000000;

    std::string test = "chuj";
    uint32_t val = std::stoi(test);

    REG_ASCII_0 = val;
    
    // Trigger translation (Bit 0) and FIFO (Bit 1)
    REG_CTRL = 0b0011; 
    
    while(1) {
        // Keep application alive
    }

    return 0;
}