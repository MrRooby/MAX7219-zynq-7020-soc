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

module AXI_IO_INT(
	// Global Clock Signal - 100MHz
	S_AXI_ACLK,
	//Slave GP0
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
	LED,
	
	// Moje
	ASCII_DATA,
	CTRL_REG
);


//Base adderess
localparam GP0_BASE = 32'h4000_0000;
localparam GP1_BASE = 32'h8000_0000;

//Timer registers
parameter R_TMR_Q    = 32'h0000_0040;
parameter R_TMR_CTRL = 32'h0000_0044;
parameter R_TMR_CNT  = 32'h0000_0044;

localparam AT_Q    = GP0_BASE + R_TMR_Q;
localparam AT_CTRL = GP0_BASE + R_TMR_CTRL;
localparam AT_CNT  = GP0_BASE + R_TMR_CNT;

//AXI Slave Controller Response
localparam RESP_OK 		= 2'b00; //Transaction OK
localparam RESP_SLVERR	= 2'b10; //Slave device not ready
localparam RESP_DECERR	= 2'b11; //No slave device at this address

localparam BURST_FIXED	= 2'b00;
localparam BURST_INCR	= 2'b01;
localparam BURST_WRAP	= 2'b10;

//AXI W
localparam W_CTRL_W 	= 3;
localparam W_IDLE	= 0;
localparam W_WR 		= 1;
localparam W_RESP	= 2;


//AXI R
localparam R_CTRL_W		= 3;
localparam R_IDLE		= 0;
localparam R_DATA		= 1;
localparam R_DATA_ACK	= 2;
localparam R_WAIT		= 3;


//AXI4 Bus
input S_AXI_ACLK;           // AXI Global clock signal - 100MHz

input S_AXI_ARESETN;        // Global Reset Signal. This Signal is Active LOW
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

output IRQ;						//Interrupt request signal

input [7:0] SW;
input [4:0] PB;
output reg [7:0] LED;

output reg [31:0] ASCII_DATA;
output reg [7:0]  CTRL_REG;

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

reg [31:0] TMR_Q;
reg [31:0] TMR_CNT;
reg RUN;
reg IRQ_FF;

//---------------------------------------------------------
// Implementation of AXI peripheral unit
//---------------------------------------------------------

assign S_AXI_BVALID = W0_CTRL[W_RESP];

assign S_AXI_RLAST = 1'b1;
assign S_AXI_ARREADY = R0_CTRL[R_IDLE];
assign S_AXI_RVALID = R0_CTRL[R_DATA_ACK];
assign IRQ = IRQ_FF;

always @(posedge S_AXI_ACLK) begin
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
				32'h4000_0000: S_AXI_RDATA <= ASCII_DATA;
                32'h4000_0004: S_AXI_RDATA <= {24'd0, CTRL_REG};
                32'h4000_0008: S_AXI_RDATA <= LED_REG;
                32'h4000_000C: S_AXI_RDATA <= LED_REG;
				32'h4000_0020: S_AXI_RDATA <= {24'd0, SW};
				32'h4000_0024: S_AXI_RDATA <= {28'd0, PB};
				32'h4000_0040: S_AXI_RDATA <= TMR_Q;
				32'h4000_0044: S_AXI_RDATA <= {IRQ_FF, 30'd0, RUN};
				32'h4000_0048:  S_AXI_RDATA <= TMR_CNT;
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
		/*R0_CTRL[R_WAIT]: begin
			R0_CTRL <= 1 << R_DATA_ACK;
		end*/
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
				32'h4000_0000: begin
					if(W0_STRB[0]) ASCII_DATA[7:0]   <= W0_DATA[7:0];
					if(W0_STRB[1]) ASCII_DATA[15:8]  <= W0_DATA[15:8];
					if(W0_STRB[2]) ASCII_DATA[23:16] <= W0_DATA[23:16];
					if(W0_STRB[3]) ASCII_DATA[31:24] <= W0_DATA[31:24];
				end
                32'h4000_0004: begin
					if(W0_STRB[0]) CTRL_REG <= W0_DATA[7:0];
				end
                32'h4000_0008: begin
					if(W0_STRB[0]) LED_REG[7:0] <= LED_REG[7:0] & ~W0_DATA[7:0];
					if(W0_STRB[1]) LED_REG[15:8] <= LED_REG[15:8] & ~W0_DATA[15:8];
					if(W0_STRB[2]) LED_REG[23:16] <= LED_REG[23:16] & ~W0_DATA[23:16];
					if(W0_STRB[3]) LED_REG[31:24] <= LED_REG[31:24] & ~W0_DATA[31:24];
				end
                32'h4000_000C: begin
					if(W0_STRB[0]) LED_REG[7:0] <= LED_REG[7:0] ^ W0_DATA[7:0];
					if(W0_STRB[1]) LED_REG[15:8] <= LED_REG[15:8] ^ W0_DATA[15:8];
					if(W0_STRB[2]) LED_REG[23:16] <= LED_REG[23:16] ^ W0_DATA[23:16];
					if(W0_STRB[3]) LED_REG[31:24] <= LED_REG[31:24] ^ W0_DATA[31:24];
				end
				AT_Q: begin
					if(!RUN & (&W0_STRB)) TMR_Q <= W0_DATA[31:0];
				end
				AT_CTRL: begin
					if((|TMR_Q[31:8]) & (&W0_STRB)) //Run is allowed when -> TMR_Q >= 256
						RUN <= ~W0_DATA[1] & (W0_DATA[0] | RUN);
				end
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
		RUN <= 1'b0;
	end

	S_AXI_AWREADY <= W0_CTRL[W_IDLE] & S_AXI_AWVALID & S_AXI_WVALID;
	S_AXI_WREADY <= W0_CTRL[W_IDLE] & S_AXI_AWVALID & S_AXI_WVALID;

	// ------------------------------------------
	// Timer
	// ------------------------------------------
	if(!RUN) begin
		TMR_CNT <= 32'd0;
		IRQ_FF <= 1'b0;
	end
	else begin
		if(TMR_CNT == TMR_Q)
			TMR_CNT <= 32'd0;
		else
			TMR_CNT <= TMR_CNT + 1;
		if(IRQ_FF) begin
			//IRQ clear condition
			if (W0_CTRL[W_WR] && ({W0_ADDR,2'b00} == AT_CTRL) && (W0_DATA[31] == 1'b1))
				IRQ_FF <= 1'b0;
		end
		else begin
			//IRQ set condition
			if(TMR_CNT == TMR_Q) IRQ_FF <= 1'b1;
		end
	end
end /* always */

reg [26:0] DIAG_CNT;

always @(posedge S_AXI_ACLK) begin
    if(S_AXI_ARESETN) begin
        DIAG_CNT <= DIAG_CNT + 1;
    end
    else begin
        DIAG_CNT <= {27{1'b0}};
    end
end

// Diagnostic display
always @(*) begin
	LED = 4'b0000;
    if(PB[0]) begin
        LED = {S_AXI_ARESETN, DIAG_CNT[26:24]};
    end
    else begin
        case(SW[1:0])
            2'b00: LED = LED_REG[ 7: 0];
            2'b01: LED = LED_REG[15: 8];
            2'b10: LED = LED_REG[23:16];
            2'b11: LED = {S_AXI_ARESETN, DIAG_CNT[26:20]};
        endcase
    end
end

endmodule
