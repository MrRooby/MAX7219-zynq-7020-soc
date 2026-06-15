// Task 1 - 3. Import the basic IO from previous task
// Task 4.
// Implement a (24-bit) timer based on the down counter. When timer reach 0 value
// it should be reloaded and apropriate flag should be set
// Registers:
// - contgrol register 0x4000_0100
//   Write
//   CTRL[0] -  START (wr) - writing 1 makes the counter running
//   CTRL[1] -  STOP (wr) - writing 1 stops the counter
//   CTRL[0] -  RUN (rd) - counter run flag
//   CTRL[31] - ZD (r/c) - zero crossing flag - set when counter crosses the 0 value
//   CTRL[30] - OV (r/c) - overrun flag - set when ZD flags remains uncleared and counter corosses the 0 value
//   Flags ZD and OV are cleared by writing a value 1 to its positions (selective vlear) or stopping the counter
// - count range register - 0x4000_0104
//   this register can be updated only when sounter is stopped
// - counter register - 0x4000_0108
//   current count value - available for curriosity than for requirements
// - interrupt flag driven from ZD flag

`timescale 1ns/100ps

module AXI_IO_INT(
	// Global Clock Signal - 100MHz
	CLK,
	//Slave LW
	S_AXI_ARESETN,
	// Write address channel (M->S)
	S_AXI_AWADDR,	//Write address
	S_AXI_AWID,		//Write address transaction ID
	S_AXI_AWPROT,	//Protection
	S_AXI_AWVALID,	//Write address valid -> Master RQ
	S_AXI_AWREADY,	//Write address ready -> Slave ACK
	/* Write data channel */
	S_AXI_WDATA,	//Write data
	S_AXI_WID,		//Write data transaction ID
	S_AXI_WSTRB,	//Write strobe - byte selector
	S_AXI_WVALID,	//Write data valid -> Master RQ
	S_AXI_WREADY,	//Write data ready -> Slave ACK

	// Write transaction response channel
	S_AXI_BRESP,	//Write transaction status
	S_AXI_BID,		//Write transaction ID
	S_AXI_BVALID,	//Write transaction response valid -> Slave RQ
	S_AXI_BREADY,	//Write transaction response ready -> Master ACK

	// Read address (issued by master, acceped by Slave)
	S_AXI_ARADDR,	//Read address
	S_AXI_ARID,		//Read address transaction ID
	S_AXI_ARPROT,	//Read address protection
	S_AXI_ARBURST,  //Burst type FIXED, INCR, WRAP
	S_AXI_ARLEN, 	//Read data burst length
	S_AXI_ARSIZE,	//Transaction size
	S_AXI_ARVALID,	//Read address valid -> Master RQ
	S_AXI_ARREADY,	//Read address ready -> Slave ACK

	// Read data (issued by slave)
	S_AXI_RDATA,	//Read data S -> M
	S_AXI_RID,		//Read data transaction ID
	S_AXI_RRESP,	//Read data response
	S_AXI_RVALID,	//Read valid -> Slave RQ
	S_AXI_RREADY,	//Read ready -> Master ACK
	S_AXI_RLAST,	//Read data last cycle

	//Interrupt signal
	IRQ,

	//Peripheral signals
	SW,
	PB,
	LED
	);


//Base adderess
parameter GP0_BASE = 32'h4000_0000;
parameter GP1_BASE = 32'h8000_0000;

parameter LED_ADDR = 32'h4000_0000;
parameter SW_ADDR = 32'h4000_0004;
parameter PB_ADDR = 32'h4000_0008;

parameter CNT_Q = 32'h4000_0040;
parameter CNT_CTRL = 32'h4000_0044;

//AXI Slave Controller Response
parameter RESP_OK 		= 2'b00; //Transaction OK
parameter RESP_SLVERR	= 2'b10; //Slave device not ready
parameter RESP_DECERR	= 2'b11; //No slave device at this address

parameter BURST_FIXED	= 2'b00;
parameter BURST_INCR	= 2'b01;
parameter BURST_WRAP	= 2'b10;

//AXI W
parameter W_CTRL_W 	= 3;
parameter W_IDLE	= 0;
parameter W_WR 		= 1;
parameter W_RESP	= 2;

//AXI R
parameter R_CTRL_W		= 3;
parameter R_IDLE		= 0;
parameter R_DATA		= 1;
parameter R_DATA_ACK	= 2;


//AXI4 Bus
input CLK; 				// AXI Global clock signal - 100MHz

input S_AXI_ARESETN;	// Global Reset Signal. This Signal is Active LOW
// Write address channel
input [31:0] S_AXI_AWADDR;	//Write address
input [11:0] S_AXI_AWID;	//Write address transaction ID
input [2:0] S_AXI_AWPROT;	//Write protection
input S_AXI_AWVALID;		//Write address valid
output S_AXI_AWREADY;		//Write ready -> ACK S->M

/* Write data channel */
input [31:0] S_AXI_WDATA;	//Write data (issued by master, acceped by Slave)
input [11:0] S_AXI_WID;		//Write data transaction ID
input [3:0] S_AXI_WSTRB;	//Write strob - selection of bytes to be written to
input S_AXI_WVALID;			//Walid write data
output S_AXI_WREADY;		//Slave ACK of write operation

/* Response channel S -> M */
output [1:0] S_AXI_BRESP;	//Response data
output [11:0] S_AXI_BID;
output S_AXI_BVALID;		//Valid response
input  S_AXI_BREADY;		//Master ACK

// Read address (issued by master, acceped by Slave)
/* Read address channel */
input [31:0] S_AXI_ARADDR;	//Read address
input [11:0] S_AXI_ARID;	//Read transaction request ID
input [2:0] S_AXI_ARPROT;	//Read protection
input [1:0] S_AXI_ARBURST; //Burst type FIXED, INCR, WRAP
input [3:0] S_AXI_ARLEN; //The burst length
input [1:0] S_AXI_ARSIZE; //Transaction size
input S_AXI_ARVALID;		//Read address valid
output S_AXI_ARREADY;		//Slave read address ACK

// Read data channel: S -> M
output [31:0] S_AXI_RDATA;	//Read data S -> M
output [11:0] S_AXI_RID;	//Read data transaction ID
output [1:0] S_AXI_RRESP;	//Read response M -> S
output S_AXI_RVALID;		//Read data valid S -> M
input S_AXI_RREADY;			//Read data ACK M -> S
output S_AXI_RLAST;

output IRQ;                 //Interrupt request signal

input [7:0] SW;
input [4:0] PB;
output reg [7:0] LED;

// Internal signals
// AXI IO controller
reg [R_CTRL_W - 1:0] R0_CTRL;
reg [31:2] R0_ADDR;
reg [11:0] S_AXI_RID;
reg [31:0] S_AXI_RDATA;
reg [1:0] S_AXI_RRESP;

reg [W_CTRL_W - 1:0] W0_CTRL;
reg S_AXI_AWREADY;
reg S_AXI_WREADY;
reg [1:0] S_AXI_BRESP;
reg [11:0] S_AXI_BID;
reg [31:2] W0_ADDR;
reg [3:0] W0_STRB;
reg [31:0] W0_DATA;

reg [31:0] LED_REG;
reg [7:0] SW_REG;
reg [4:0] PB_REG;

reg [31:0] TMR_Q;
reg [31:0] TMR_CNT;
reg TMR_RUN, TMR_ZD, TMR_OV;
wire ZD;

reg IRQ_FF;

//---------------------------------------------------------
// Implementation of AXI peripheral unit
//---------------------------------------------------------

assign S_AXI_BVALID = W0_CTRL[W_RESP];

assign S_AXI_RLAST = 1'b1;
assign S_AXI_ARREADY = R0_CTRL[R_IDLE];
assign S_AXI_RVALID = R0_CTRL[R_DATA_ACK];

assign IRQ = IRQ_FF;

always @(posedge CLK) begin
    //GP0
    if(S_AXI_ARESETN) begin
        //Read channel #0 - AXI-Lite (single transaction process)
        case(1'b1) /* synthesis parallel_case */
        R0_CTRL[R_IDLE]: begin
			if(S_AXI_ARVALID) begin
				R0_CTRL <= 1 << R_DATA;
				//S_AXI_ARREADY <= 1'b1;
			end
			R0_ADDR <= S_AXI_ARADDR[31:2];
			S_AXI_RID <= S_AXI_ARID;
		end
		R0_CTRL[R_DATA]: begin
			S_AXI_RRESP <= RESP_OK;
			R0_CTRL <= 1 << R_DATA_ACK;
			case({R0_ADDR[31:2],2'b00})
			//AXI Data Read Section
			// Here goes the peripherals - read part
			default: begin
				S_AXI_RDATA <= 32'hDEAD_BEEF;
				S_AXI_RRESP <= RESP_DECERR;
			end
			endcase
		end
		R0_CTRL[R_DATA_ACK]: begin
			if(S_AXI_RREADY)
				R0_CTRL <= 1 << R_IDLE;
		end
		endcase

		//Write channel #0 - AXI-Lite (single transaction process)
		case(1'b1) /* synthesis parallel_case */
		W0_CTRL[W_IDLE]: begin
			if(S_AXI_AWVALID & S_AXI_WVALID) begin
				W0_CTRL <= 1 << W_WR;
			end
			W0_ADDR <= S_AXI_AWADDR[31:2];
			W0_STRB <= S_AXI_WSTRB;
			W0_DATA <= S_AXI_WDATA;
			S_AXI_BID <= S_AXI_WID;
		end
		W0_CTRL[W_WR]: begin
			W0_CTRL <= 1 << W_RESP;
			S_AXI_BRESP <= RESP_OK;
			case({W0_ADDR[31:2], 2'b00})
			// Here gos the written registers
			default:
				S_AXI_BRESP <= RESP_DECERR;
			endcase
		end
		W0_CTRL[W_RESP]:
			if(S_AXI_BREADY)
				W0_CTRL <= 1 << W_IDLE;
		/*W0_CTRL[W_WAIT]:
			W0_CTRL <= 1 << W_RESP;*/
		endcase
	end
	else begin
		W0_CTRL <= 1 << W_IDLE;
		R0_CTRL <= 1 << R_IDLE;
		TMR_RUN <= 1'b0;
	end

	S_AXI_AWREADY <= W0_CTRL[W_IDLE] & S_AXI_AWVALID & S_AXI_WVALID;
	S_AXI_WREADY <= W0_CTRL[W_IDLE] & S_AXI_AWVALID & S_AXI_WVALID;

	// ------------------------------------------
	// Timer
	// ------------------------------------------

	TMR_Q <= 1'b0;
	TMR_ZD <= 1'b0;
	IRQ_FF <= TMR_ZD;

end /* always */

/* synthesis translate_off */
initial begin
	TMR_CNT = 32'h0;
end
/* synthesis translate_on */


assign ZD = ~|TMR_Q;  //(TMR_Q == 32'd0)

// Diagnostic display
always @(*) begin
	LED = 8'b0000_0000;
	case(SW[7:5])
		3'b000: LED = LED_REG[7:0];
		3'b001: LED = LED_REG[15:8];
		3'b010: LED = LED_REG[23:16];
		3'b011: LED = LED_REG[31:24];
		3'b100: LED = {TMR_ZD, 6'd0, TMR_RUN};
		3'b101: LED = TMR_Q[15:8];
		3'b110: LED = TMR_Q[23:16];
		3'b111: LED = TMR_Q[31:24];
	endcase
end

endmodule

