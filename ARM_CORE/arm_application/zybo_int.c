#include "xscugic.h"
#include "xil_exception.h"
#include "zybo_io.h"
#include <stdint.h>
#include <string.h>
#include <xil_printf.h>
#include "sleep.h"

#define TIMER_ISR_VECT 61
#define TIMER_BASE 0x40000040

#define PACK4(c0,c1,c2,c3) \
    (((c0)&0x7F) | (((c1)&0x7F)<<7) | (((c2)&0x7F)<<14) | (((c3)&0x7F)<<21))

static XScuGic_Config *GicConfig; /* The configuration parameters of the controller */
XScuGic InterruptController; /* Instance of the Interrupt Controller */

PTimer tm	= (PTimer) 0x40000040;
PLED led	= (PLED) 0x40000000;

void tmInit()
{
    tm->tmQ = 49999999;
    tm->tmRUN = 1;
}

void tmStop()
{
    tm->tmRUN = 0;
}

void tmOnTick(void *cb)
{
    tm->tmCTRL = (1 << TM_INT) | (1 << TM_RUN);
	//tmC = tm->tmCTRL;
	++led->io;
}

void initDevices()
{
	Xil_ExceptionInit();
	
	GicConfig = XScuGic_LookupConfig(0);
	
	XScuGic_CfgInitialize(
		&InterruptController,
		GicConfig,
		GicConfig->CpuBaseAddress);
	
	XScuGic_Connect(&InterruptController, TIMER_ISR_VECT, tmOnTick, NULL);
	
	XScuGic_Enable(&InterruptController, TIMER_ISR_VECT);
    Xil_ExceptionRegisterHandler(XIL_EXCEPTION_ID_INT,
			(Xil_ExceptionHandler) XScuGic_InterruptHandler,
			&InterruptController);
	Xil_ExceptionEnable();

    tmInit();
}

void tmPooling()
{
    TTimer tt;
    static unsigned long t_min = 10000000;
    static unsigned long t_max = 0;
	tm->tmQ = 50000000;
	memcpy(&tt, tm, sizeof(TTimer));	
	for(;;)
	{
		if(tm->tmINT)
		{
            memcpy(&tt, tm, sizeof(TTimer));	
            if(t_max < tt.tmCNT)
                t_max = tt.tmCNT;
            if(t_min > tt.tmCNT)
                t_min = tt.tmCNT;            
			tm->tmCTRL = (1 << TM_INT);			
			++led->io;
		}
	}
}


int main( void )
{
	uint32_t counter = 0;
	        
    Xil_Out32(0x40000004, 0x01);
	usleep(200);
	
	Xil_Out32(0x40000004, 0x41);
	usleep(200);

	Xil_Out32(0x40000000, PACK4('1', '2', '3', '4'));
	Xil_Out32(0x40000004, 0x80);
	usleep(2000);
	 
    for(;;)
    {
		xil_printf("ping\n");
        //tmPooling();
		Xil_Out32(0x40000000, PACK4('1', '2', '3', '4'));
		Xil_Out32(0x40000004, 0x80);
		usleep(2000);
    }
	return 0;
}

