/*
 * config.h - hardware map and tunable constants for the alarm clock.
 *
 * Register map (AXI GP0, custom slave):
 *   ASCII_REG  0x40000000  RW  32b  4 glyphs * 7 bit, packed by PACK4()
 *   CTRL_REG   0x40000004  RW   8b  command, decoded by bits [7:6]
 *   BTN_REG    0x40000008  R    8b  one bit per push-button   (assumed)
 *   LED_REG    0x4000000C  RW   8b  bit0 = alarm indicator LED (assumed)
 *   TIMER      0x40000040       RTC timer with IRQ line -> 1 Hz
 */
#ifndef CONFIG_H
#define CONFIG_H

/* ---- hardware addresses ------------------------------------------ */
#define ASCII_REG   0x40000000u
#define CTRL_REG    0x40000004u
#define BTN_REG     0x40000008u   /* read-only button register   (adjust) */
#define LED_REG     0x4000000Cu   /* alarm indicator LED         (adjust) */
#define TIMER_BASE  0x40000040u

#define TIMER_ISR_VECT 61

/* ---- CTRL_REG command opcodes (bits [7:6]) ----------------------- */
#define CTRL_ENABLE     (0u << 6)
#define CTRL_BRIGHTNESS (1u << 6)
#define CTRL_ASCII      (2u << 6)
#define CTRL_BLINK      (3u << 6)

/* ---- buttons ----------------------------------------------------- */
#define BTN_MODE   0x01u
#define BTN_UP     0x02u
#define BTN_DOWN   0x04u
#define BTN_SET    0x08u
#define BTN_MASK   (BTN_MODE | BTN_UP | BTN_DOWN | BTN_SET)
#define BTN_ACTIVE_HIGH 1         /* set to 0 if "pressed" reads as 0 */
#define NUM_BTNS   4

/* ---- display ----------------------------------------------------- */
/* Pack 4 ASCII chars (7 bits each) into the 28-bit display word.
 * c0 -> module 0 (left-most). Swap the order if the cascade is reversed. */
#define PACK4(c0,c1,c2,c3) \
    (((c0)&0x7F) | (((c1)&0x7F)<<7) | (((c2)&0x7F)<<14) | (((c3)&0x7F)<<21))

#define BLANK_CHAR ' '            /* font_rom must map this to an empty glyph */
#define DEFAULT_BRIGHTNESS 1      /* 0..3 */

/* ---- timing (all driven from the POLL loop) ---------------------- */
#define POLL_MS         10        /* keyboard sampling period            */
#define DEBOUNCE_TICKS   3        /* 30 ms stable before a state change  */
#define REPEAT_DELAY    50        /* 500 ms held before auto-repeat      */
#define REPEAT_PERIOD   12        /* 120 ms between auto-repeats          */
#define BLINK_TICKS     25        /* 250 ms blink half-period             */

#endif /* CONFIG_H */
