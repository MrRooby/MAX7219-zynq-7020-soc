/*
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
