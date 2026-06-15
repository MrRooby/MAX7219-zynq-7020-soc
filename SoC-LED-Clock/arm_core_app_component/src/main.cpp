#include <stdint.h>
#include <string>
#include "xparameters.h"

// Memory-mapped register access using volatile pointers
#define REG_ASCII_0  (*(volatile uint32_t *)(XPAR_XGPIO_0_BASEADDR + 0x00))
#define REG_ASCII_1  (*(volatile uint32_t *)(XPAR_XGPIO_0_BASEADDR + 0x08)) 
#define REG_CTRL     (*(volatile uint32_t *)(XPAR_XGPIO_1_BASEADDR + 0x08)) // Bit 0/1 controls

int main() {
    // Test: Write a dummy value to ASCII regs and trigger the control register
    std::string test = "12";
    std::string test2 = "12";
    uint32_t val = std::stoi(test);
    uint32_t val2 = std::stoi(test);

    // Set dummy data
    REG_ASCII_0 = val;
    REG_ASCII_1 = val2;
    
    // Trigger translation (Bit 0) and FIFO (Bit 1)
    REG_CTRL = 0b0011; 
    
    while(1) {
        // Keep application alive
    }

    return 0;
}