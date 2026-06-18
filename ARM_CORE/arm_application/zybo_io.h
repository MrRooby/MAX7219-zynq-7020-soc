#ifndef ZYBO_IO_H

typedef struct TLED {
	volatile unsigned int io;
	volatile unsigned int set;
	volatile unsigned int clr;
	volatile unsigned int toggle;
} TLED;

typedef TLED* PLED;

// Timer with interrupt line

typedef struct {
	volatile unsigned int tmQ;
	union {
		/*volatile*/ unsigned int tmCTRL;
		struct {
			//LSB
			volatile unsigned int tmRUN : 1;
            volatile unsigned int tmSTOP : 1;
			volatile unsigned int tmDUMMY : 28;
			volatile unsigned int tmOVF : 1;            
			volatile unsigned int tmINT : 1;
			//MSB
		};
	};
	volatile unsigned int tmCNT;
} TTimer;

typedef TTimer* PTimer;

#define TM_RUN 0
#define TM_INT 31

#endif
