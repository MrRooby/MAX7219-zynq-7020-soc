## LED Dot matrix alarm clock using MAX7219 based modules

### Required Hardware
LED Dot matrix with MAX7219

### Hardware requirements
- Controller of 4 dot matrix displays (8x8 points) dot matrix display with serial data
input
- Transposition from column-based entry to row-based display
- Direct RW access to display memory
- The RTC minimal support (e.g. timer with interrupts from the laboratory example)

### Register set accessible by CPU in AXIO GP0 memory space:
- RW – display memory ASCII based encoding
- digit position to blink

### Software requirements
- Keyboard service routine with bounce suppression and auto repetition
- Displaying information depends on the operation mode, current time, alarm time
- During the set operation, the digits that are set are flashing
- Real-time clock