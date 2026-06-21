/*
 * display.h - 4-module MAX7219 dot-matrix front-end over the AXI registers.
 *             Header-only: include from exactly one translation unit.
 */
#ifndef DISPLAY_H
#define DISPLAY_H

#include <stdint.h>
#include "config.h"
#include "xil_io.h"
#include "sleep.h"

static inline void display_ctrl_write(uint32_t v) { Xil_Out32(CTRL_REG, v); }

/* Set intensity, level 0..3. */
static inline void display_set_brightness(uint8_t level)
{
    if (level > 3) level = 3;
    display_ctrl_write(CTRL_BRIGHTNESS | level);
}

/* Initialise the display (no-decode mode + default brightness). */
static inline void display_init(void)
{
    display_ctrl_write(CTRL_ENABLE | 0x01);   /* init / no-decode mode */
    usleep(2000);
    display_set_brightness(DEFAULT_BRIGHTNESS);
}

/* Push 4 glyphs to the matrix. Only re-sent when the content changed. */
static inline void display_send(const char buf[4])
{
    static uint32_t last = 0xFFFFFFFFu;
    uint32_t packed = PACK4((uint8_t)buf[0], (uint8_t)buf[1],
                            (uint8_t)buf[2], (uint8_t)buf[3]);
    if (packed == last)
        return;                         /* nothing changed -> no bus traffic */
    last = packed;
    Xil_Out32(ASCII_REG, packed);
    display_ctrl_write(CTRL_ASCII);     /* latch + show */
}

/* Drive the alarm indicator LED. */
static inline void display_led(int on)
{
    Xil_Out32(LED_REG, on ? 0x01u : 0x00u);
}

#endif /* DISPLAY_H */
