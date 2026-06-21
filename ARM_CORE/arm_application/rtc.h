/*
 * rtc.h - real-time clock driven by the 1 Hz PL timer interrupt.
 *         Header-only: include from exactly one translation unit.
 */
#ifndef RTC_H
#define RTC_H

#include "xscugic.h"
#include <stdint.h>
#include "config.h"
#include "zybo_io.h"

static PTimer   rtc_tm  = (PTimer) TIMER_BASE;
static XScuGic *rtc_gic = 0;

static volatile uint8_t rtc_hh = 12, rtc_mm = 0, rtc_ss = 0;
static volatile uint8_t rtc_sec_event = 0;

static void rtc_isr(void *cb)
{
    (void)cb;
    /* clear the interrupt flag, keep the timer running */
    rtc_tm->tmCTRL = (1u << TM_INT) | (1u << TM_RUN);

    if (++rtc_ss >= 60) {
        rtc_ss = 0;
        if (++rtc_mm >= 60) {
            rtc_mm = 0;
            if (++rtc_hh >= 24)
                rtc_hh = 0;
        }
    }
    rtc_sec_event = 1;
}

/* Connect the timer ISR to the GIC and start the 1 Hz tick. */
static inline void rtc_init(XScuGic *g)
{
    rtc_gic = g;

    XScuGic_Connect(rtc_gic, TIMER_ISR_VECT, rtc_isr, 0);
    XScuGic_Enable(rtc_gic, TIMER_ISR_VECT);

    rtc_tm->tmQ   = 49999999;   /* 50 MHz / 50e6 = 1 Hz */
    rtc_tm->tmRUN = 1;
}

/* Current time (read with the timer IRQ masked, so it never tears). */
static inline void rtc_get(uint8_t *hh, uint8_t *mm)
{
    XScuGic_Disable(rtc_gic, TIMER_ISR_VECT);
    *hh = rtc_hh; *mm = rtc_mm;
    XScuGic_Enable(rtc_gic, TIMER_ISR_VECT);
}

static inline uint8_t rtc_seconds(void)
{
    return rtc_ss;
}

/* Force the clock; seconds are reset to 0. */
static inline void rtc_set(uint8_t hh, uint8_t mm)
{
    XScuGic_Disable(rtc_gic, TIMER_ISR_VECT);
    rtc_hh = hh; rtc_mm = mm; rtc_ss = 0;
    XScuGic_Enable(rtc_gic, TIMER_ISR_VECT);
}

/* Returns 1 exactly once per elapsed second, 0 otherwise. */
static inline int rtc_take_sec_event(void)
{
    if (rtc_sec_event) {
        rtc_sec_event = 0;
        return 1;
    }
    return 0;
}

#endif /* RTC_H */
