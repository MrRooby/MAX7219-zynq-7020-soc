/*
 * zybo_int.c - MINIMAL display test.
 *
 * Strips the whole alarm-clock stack down to one job: initialise the
 * MAX7219 chain and show "1234". No GIC, no RTC, no keyboard, no UI.
 *
 * The original alarm-clock top level is preserved unchanged at the bottom
 * of this file under `#if 0` so it can be switched back on later.
 */
// #include "sleep.h"
// #include <xil_printf.h>

// #include "config.h"
// #include "display.h"


// int main(void)
// {
//     display_init();             /* no-decode mode + default brightness   */
//     usleep(2000);               /* let the two init frames finish on SPI  */

//     display_send("    ");       /* render the four glyphs, then stop      */
//     usleep(2000);               /* let the two init frames finish on SPI  */
//     display_send("1234");       /* render the four glyphs, then stop      */

//     xil_printf("display test: 1234\n");

//     for (;;) {
//         /* idle - leave "1234" on the panel */
//     }
//     return 0;
// }

/* ===== ORIGINAL ALARM-CLOCK TOP LEVEL (disabled) ===================
 * zybo_int.c - LED dot-matrix alarm clock, top level.
 *
 * Sets up the GIC, brings up the sub-systems and runs the POLL loop.
 * The actual work lives in:
 *   rtc.[ch]        - 1 Hz real-time clock (timer interrupt)
 *   keyboard.[ch]   - debounce + auto-repeat for the 4 buttons
 *   display.[ch]    - MAX7219 dot-matrix front-end
 *   clock_app.[ch]  - UI state machine (modes, alarm, rendering)
 *   config.h        - register map and tunables
 */
#include "xscugic.h"
#include "xil_exception.h"
#include "sleep.h"
#include <xil_printf.h>

#include "config.h"
#include "rtc.h"
#include "keyboard.h"
#include "display.h"
#include "clock_app.h"

XScuGic InterruptController;
static XScuGic_Config *GicConfig;

static void gic_init(void)
{
    Xil_ExceptionInit();

    GicConfig = XScuGic_LookupConfig(0);
    XScuGic_CfgInitialize(&InterruptController, GicConfig,
                          GicConfig->CpuBaseAddress);

    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
            (Xil_ExceptionHandler) XScuGic_InterruptHandler,
            &InterruptController);
    Xil_ExceptionEnable();
}

int main(void)
{
    gic_init();
    rtc_init(&InterruptController);
    kb_init();
    display_init();
    app_init();

    xil_printf("LED matrix alarm clock started\n");

    for (;;) {
        app_handle_buttons(kb_scan());

        if (rtc_take_sec_event())
            app_second_tick();

        app_refresh();

        usleep(POLL_MS * 1000);
    }
    return 0;
}
