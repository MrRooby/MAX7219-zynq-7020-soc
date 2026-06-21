/*
 * keyboard.h - 4-button keypad with debounce and auto-repeat.
 *              Header-only: include from exactly one translation unit.
 */
#ifndef KEYBOARD_H
#define KEYBOARD_H

#include <stdint.h>
#include <string.h>
#include "config.h"
#include "xil_io.h"

typedef struct {
    uint8_t  stable;     /* debounced level (1 = pressed) */
    uint8_t  cand;       /* last raw sample               */
    uint8_t  dcount;     /* consecutive equal samples     */
    uint16_t hold;       /* ticks held                    */
} Btn;

static Btn kb_btns[NUM_BTNS];
static const uint8_t kb_btn_bit[NUM_BTNS] = { BTN_L, BTN_R, BTN_D, BTN_U, BTN_C };

static inline void kb_init(void)
{
    memset(kb_btns, 0, sizeof(kb_btns));
}

static inline uint8_t kb_read_raw(void)
{
    uint8_t v = (uint8_t)(Xil_In32(BTN_REG) & BTN_MASK);
#if !BTN_ACTIVE_HIGH
    v = (uint8_t)(~v) & BTN_MASK;
#endif
    return v;
}

/* Sample the buttons once (call every POLL_MS). Returns a mask of
 * BTN_* bits that produced an event this tick: an initial press, or an
 * auto-repeat while the key is held. */
static inline uint8_t kb_scan(void)
{
    uint8_t raw = kb_read_raw();
    uint8_t events = 0;

    for (int i = 0; i < NUM_BTNS; ++i) {
        uint8_t pressed = (raw & kb_btn_bit[i]) ? 1 : 0;

        /* debounce: require DEBOUNCE_TICKS identical samples */
        if (pressed == kb_btns[i].cand) {
            if (kb_btns[i].dcount < DEBOUNCE_TICKS)
                kb_btns[i].dcount++;
        } else {
            kb_btns[i].cand   = pressed;
            kb_btns[i].dcount = 0;
        }

        if (kb_btns[i].dcount >= DEBOUNCE_TICKS &&
            kb_btns[i].stable != kb_btns[i].cand) {
            kb_btns[i].stable = kb_btns[i].cand;
            if (kb_btns[i].stable) {          /* rising edge -> press */
                kb_btns[i].hold = 0;
                events |= kb_btn_bit[i];
            }
        }

        /* auto-repeat while held */
        if (kb_btns[i].stable) {
            kb_btns[i].hold++;
            if (kb_btns[i].hold == REPEAT_DELAY) {
                events |= kb_btn_bit[i];
            } else if (kb_btns[i].hold > REPEAT_DELAY &&
                       ((kb_btns[i].hold - REPEAT_DELAY) % REPEAT_PERIOD) == 0) {
                events |= kb_btn_bit[i];
            }
        }
    }
    return events;
}

#endif /* KEYBOARD_H */
