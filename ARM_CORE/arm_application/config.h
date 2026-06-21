/*
 * config.h - hardware map and tunable constants for the alarm clock.
 *
 * Register map (AXI GP0, custom slave):
 *   ASCII_REG  0x40000000  RW  32b  4 glyphs * 7 bit, packed by PACK4()
 *   CTRL_REG   0x40000004  RW   8b  command, decoded by bits [7:6]
 *   SW_REG     0x40000020  R        slide switches
 *   BTN_REG    0x40000024  R    5b  5-way push-button cluster (L/R/D/U/C)
 *   LED_REG    0x4000000C  RW   8b  bit0 = alarm indicator LED (adjust)
 *   TIMER      0x40000040       RTC timer with IRQ line -> 1 Hz
 */
#ifndef CONFIG_H
#define CONFIG_H

/* ---- hardware addresses ------------------------------------------ */
#define ASCII_REG   0x40000000u
#define CTRL_REG    0x40000004u
#define SW_REG      0x40000020u
#define BTN_REG     0x40000024u
#define LED_REG     0x4000000Cu   /* alarm indicator LED         (adjust) */
#define TIMER_BASE  0x40000040u

/* Physical buttons (bit per button in BTN_REG, active-high, no HW debounce) */
#define BTN_L  (1u << 0)
#define BTN_R  (1u << 1)
#define BTN_D  (1u << 2)
#define BTN_U  (1u << 3)
#define BTN_C  (1u << 4)

#define TIMER_ISR_VECT 61

/* ---- CTRL_REG layout:  [7:6] op | [5] kick | [1:0] arg ------------
 * The PL re-triggers whenever bit 5 ("kick") toggles, so display_cmd()
 * flips it on every write -> the same command can be re-issued at will. */
#define CTRL_ENABLE     (0u << 6)
#define CTRL_BRIGHTNESS (1u << 6)
#define CTRL_ASCII      (2u << 6)
#define CTRL_BLINK      (3u << 6)

/* ---- buttons ----------------------------------------------------- */
#define BTN_MASK   (BTN_L | BTN_R | BTN_D | BTN_U | BTN_C)  /* 0x1F */
#define BTN_ACTIVE_HIGH 1         /* pressed reads as 1; set to 0 if inverted */
#define NUM_BTNS   5

/* Logical key roles -> physical buttons (remap here to taste). */
#define KEY_MODE   BTN_C          /* cycle TIME / SET_TIME / SET_ALARM       */
#define KEY_UP     BTN_U          /* increment field / brightness up         */
#define KEY_DOWN   BTN_D          /* decrement field / brightness down       */
#define KEY_LEFT   BTN_L          /* select HH (set) / alarm on-off (time)   */
#define KEY_RIGHT  BTN_R          /* select MM (set)                         */

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
