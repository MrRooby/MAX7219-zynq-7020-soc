/*
 * clock_app.h - alarm-clock UI state machine. Header-only: include from
 *               exactly one translation unit.
 *
 * Controls (5-way pad: C=mode, L/R, U/D):
 * Modes cycled by C: TIME -> SET_TIME -> SET_ALARM -> TIME
 *   TIME      : show current time. U/D = brightness, L = alarm on/off.
 *   SET_TIME  : edit current time. L/R = pick HH/MM, U/D = adjust field.
 *   SET_ALARM : edit alarm time.   L/R = pick HH/MM, U/D = adjust field.
 * The field being edited flashes; a ringing alarm flashes the whole
 * display plus the LED and is silenced by any key.
 */
#ifndef CLOCK_APP_H
#define CLOCK_APP_H

#include <stdint.h>
#include "config.h"
#include "rtc.h"
#include "display.h"

typedef enum { MODE_TIME = 0, MODE_SET_TIME, MODE_SET_ALARM } Mode;

static Mode    app_mode  = MODE_TIME;
static uint8_t app_field = 0;        /* 0 = hours, 1 = minutes */

static uint8_t app_work_hh = 12, app_work_mm = 0;   /* scratch while setting time */
static uint8_t app_alarm_hh = 6,  app_alarm_mm = 30;
static uint8_t app_alarm_enabled = 0;
static uint8_t app_alarm_active  = 0;               /* alarm ringing right now */

static uint8_t  app_brightness = DEFAULT_BRIGHTNESS;
static uint8_t  app_blink_on   = 1;
static uint16_t app_blink_cnt  = 0;

static inline void app_init(void)
{
    app_mode = MODE_TIME;
    app_brightness = DEFAULT_BRIGHTNESS;
}

/* ---- helpers ----------------------------------------------------- */
static inline uint8_t app_wrap(int v, int mod)
{
    v %= mod;
    if (v < 0) v += mod;
    return (uint8_t)v;
}

static inline void app_adjust_field(int dir)        /* dir = +1 / -1, set modes */
{
    if (app_mode == MODE_SET_TIME) {
        if (app_field == 0) app_work_hh = app_wrap(app_work_hh + dir, 24);
        else                app_work_mm = app_wrap(app_work_mm + dir, 60);
    } else { /* MODE_SET_ALARM */
        if (app_field == 0) app_alarm_hh = app_wrap(app_alarm_hh + dir, 24);
        else                app_alarm_mm = app_wrap(app_alarm_mm + dir, 60);
    }
}

static inline void app_adjust_brightness(int dir)
{
    int b = (int)app_brightness + dir;
    if (b < 0) b = 0;
    if (b > 3) b = 3;
    app_brightness = (uint8_t)b;
    display_set_brightness(app_brightness);
}

static inline void app_on_mode(void)
{
    switch (app_mode) {
    case MODE_TIME:                      /* enter time-set */
        rtc_get(&app_work_hh, &app_work_mm);
        app_field = 0;
        app_mode = MODE_SET_TIME;
        break;
    case MODE_SET_TIME:                  /* commit time, go to alarm-set */
        rtc_set(app_work_hh, app_work_mm);
        app_field = 0;
        app_mode = MODE_SET_ALARM;
        break;
    case MODE_SET_ALARM:                 /* alarm edited in place -> clock */
        app_mode = MODE_TIME;
        break;
    }
}

/* ---- public API -------------------------------------------------- */
/* Apply a mask of KEY_* keyboard events. */
static inline void app_handle_buttons(uint8_t ev)
{
    if (ev == 0)
        return;

    /* Any key silences a ringing alarm and is then consumed. */
    if (app_alarm_active) {
        app_alarm_active = 0;
        display_led(0);
        return;
    }

    if (ev & KEY_MODE) app_on_mode();

    if (app_mode == MODE_TIME) {
        if (ev & KEY_UP)   app_adjust_brightness(+1);
        if (ev & KEY_DOWN) app_adjust_brightness(-1);
        if (ev & KEY_LEFT) app_alarm_enabled = !app_alarm_enabled;
    } else { /* SET_TIME / SET_ALARM */
        if (ev & KEY_LEFT)  app_field = 0;          /* select HH */
        if (ev & KEY_RIGHT) app_field = 1;          /* select MM */
        if (ev & KEY_UP)    app_adjust_field(+1);
        if (ev & KEY_DOWN)  app_adjust_field(-1);
    }
}

/* Call once per second (alarm matching). */
static inline void app_second_tick(void)
{
    uint8_t hh, mm;
    rtc_get(&hh, &mm);
    if (app_alarm_enabled && !app_alarm_active &&
        hh == app_alarm_hh && mm == app_alarm_mm && rtc_seconds() == 0) {
        app_alarm_active = 1;
    }
}

/* Call every POLL_MS: advances the blink phase and refreshes the display. */
static inline void app_refresh(void)
{
    char buf[4];
    uint8_t hh, mm;
    uint8_t flash_field = 0xFF;          /* 0xFF = nothing flashing */

    /* advance the software blink phase */
    if (++app_blink_cnt >= BLINK_TICKS) {
        app_blink_cnt = 0;
        app_blink_on ^= 1;
    }

    switch (app_mode) {
    case MODE_SET_TIME:
        hh = app_work_hh; mm = app_work_mm; flash_field = app_field;
        break;
    case MODE_SET_ALARM:
        hh = app_alarm_hh; mm = app_alarm_mm; flash_field = app_field;
        break;
    default: /* MODE_TIME */
        rtc_get(&hh, &mm);
        break;
    }

    buf[0] = (char)('0' + hh / 10);
    buf[1] = (char)('0' + hh % 10);
    buf[2] = (char)('0' + mm / 10);
    buf[3] = (char)('0' + mm % 10);

    if (app_alarm_active) {
        if (!app_blink_on)
            buf[0] = buf[1] = buf[2] = buf[3] = BLANK_CHAR;
        display_led(app_blink_on);       /* LED follows the blink phase */
    } else if (flash_field != 0xFF && !app_blink_on) {
        if (flash_field == 0) { buf[0] = buf[1] = BLANK_CHAR; }
        else                  { buf[2] = buf[3] = BLANK_CHAR; }
    }

    display_send(buf);
}

#endif /* CLOCK_APP_H */
