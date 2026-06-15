module AXI_IO(
	// Global Clock Signal - 100MHz
	CLK,
	//Slave GP0
	S_GP0_AXI_ARESETN,
	// Write address channel (M->S)
	S_GP0_AXI_AWADDR,	//Write address
	S_GP0_AXI_AWID,		//Write address transaction ID
	S_GP0_AXI_AWPROT,	//Protection
	S_GP0_AXI_AWVALID,	//Write address valid -> Master RQ
	S_GP0_AXI_AWREADY,	//Write address ready -> Slave ACK
	/* Write data channel */
	S_GP0_AXI_WDATA,	//Write data
	S_GP0_AXI_WID,		//Write data transaction ID
	S_GP0_AXI_WSTRB,	//Write strobe - byte selector
	S_GP0_AXI_WVALID,	//Write data valid -> Master RQ
	S_GP0_AXI_WREADY,	//Write data ready -> Slave ACK

	// Write transaction response channel
	S_GP0_AXI_BRESP,	//Write transaction status
	S_GP0_AXI_BID,		//Write transaction ID
	S_GP0_AXI_BVALID,	//Write transaction response valid -> Slave RQ
	S_GP0_AXI_BREADY,	//Write transaction response ready -> Master ACK

	// Read address (issued by master, acceped by Slave)
	S_GP0_AXI_ARADDR,	//Read address
	S_GP0_AXI_ARID,		//Read address transaction ID
	S_GP0_AXI_ARPROT,	//Read address protection
	S_GP0_AXI_ARBURST,  //Burst type FIXED, INCR, WRAP
	S_GP0_AXI_ARLEN, 	//Read data burst length
	S_GP0_AXI_ARSIZE,	//Transaction size
	S_GP0_AXI_ARVALID,	//Read address valid -> Master RQ
	S_GP0_AXI_ARREADY,	//Read address ready -> Slave ACK

	// Read data (issued by slave)
	S_GP0_AXI_RDATA,	//Read data S -> M
	S_GP0_AXI_RID,		//Read data transaction ID
	S_GP0_AXI_RRESP,	//Read data response
	S_GP0_AXI_RVALID,	//Read valid -> Slave RQ
	S_GP0_AXI_RREADY,	//Read ready -> Master ACK
	S_GP0_AXI_RLAST,	//Read data last cycle

	//Peripheral signals
	SW,
	PB_C, PB_U, PB_D, PB_R, PB_L,
	LED
	);

//Base adderess
parameter GP0_BASE = 32'h4000_0000;
parameter GP1_BASE = 32'h8000_0000;

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
parameter W_WAIT	= 3;

//AXI R
parameter R_CTRL_W		= 3;
parameter R_IDLE		= 0;
parameter R_DATA		= 1;
parameter R_DATA_ACK	= 2;
parameter R_WAIT		= 3;


//AXI4 Bus
input CLK; 				// AXI Global clock signal - 100MHz

input S_GP0_AXI_ARESETN;	// Global Reset Signal. This Signal is Active LOW
// Write address channel
input [31:0] S_GP0_AXI_AWADDR;	//Write address
input [11:0] S_GP0_AXI_AWID;	//Write address transaction ID
input [2:0] S_GP0_AXI_AWPROT;	//Write protection
input S_GP0_AXI_AWVALID;		//Write address valid
output S_GP0_AXI_AWREADY;		//Write ready -> ACK S->M

/* Write data channel */
input [31:0] S_GP0_AXI_WDATA;	//Write data (issued by master, acceped by Slave)
input [11:0] S_GP0_AXI_WID;		//Write data transaction ID
input [3:0] S_GP0_AXI_WSTRB;	//Write strob - selection of bytes to be written to
input S_GP0_AXI_WVALID;			//Walid write data
output S_GP0_AXI_WREADY;		//Slave ACK of write operation

/* Response channel S -> M */
output [1:0] S_GP0_AXI_BRESP;	//Response data
output [11:0] S_GP0_AXI_BID;
output S_GP0_AXI_BVALID;		//Valid response
input  S_GP0_AXI_BREADY;		//Master ACK

// Read address (issued by master, acceped by Slave)
/* Read address channel */
input [31:0] S_GP0_AXI_ARADDR;	//Read address
input [11:0] S_GP0_AXI_ARID;	//Read transaction request ID
input [2:0] S_GP0_AXI_ARPROT;	//Read protection
input [1:0] S_GP0_AXI_ARBURST; //Burst type FIXED, INCR, WRAP
input [3:0] S_GP0_AXI_ARLEN; //The burst length
input [1:0] S_GP0_AXI_ARSIZE; //Transaction size
input S_GP0_AXI_ARVALID;		//Read address valid
output S_GP0_AXI_ARREADY;		//Slave read address ACK

// Read data channel: S -> M
output [31:0] S_GP0_AXI_RDATA;	//Read data S -> M
output [11:0] S_GP0_AXI_RID;	//Read data transaction ID
output [1:0] S_GP0_AXI_RRESP;	//Read response M -> S
output S_GP0_AXI_RVALID;		//Read data valid S -> M
input S_GP0_AXI_RREADY;			//Read data ACK M -> S
output S_GP0_AXI_RLAST;

input [7:0] SW;
input PB_C, PB_U, PB_D, PB_R, PB_L;
output reg [7:0] LED;

// Internal signals
// AXI IO controller
reg [R_CTRL_W - 1:0] R0_CTRL;
reg [31:2] R0_ADDR;
reg [11:0] S_GP0_AXI_RID;
reg [31:0] S_GP0_AXI_RDATA;
reg [1:0] S_GP0_AXI_RRESP;

reg [W_CTRL_W - 1:0] W0_CTRL;
reg S_GP0_AXI_AWREADY;
reg S_GP0_AXI_WREADY;
reg [1:0] S_GP0_AXI_BRESP;
reg [11:0] S_GP0_AXI_BID;
reg [31:2] W0_ADDR;
reg [3:0] W0_STRB;
reg [31:0] W0_DATA;

reg [31:0] LED_REG = 32'h55AA0100;
wire [4:0] PB;

assign S_GP0_AXI_BVALID = W0_CTRL[W_RESP];

assign S_GP0_AXI_RLAST = 1'b1;
assign S_GP0_AXI_ARREADY = R0_CTRL[R_IDLE];
assign S_GP0_AXI_RVALID = R0_CTRL[R_DATA_ACK];

always @(posedge CLK) begin
	//GP0
	if(S_GP0_AXI_ARESETN) begin
		//Read channel #0 - AXI-Lite (single transaction process)
		case(1'b1) /* synthesis parallel_case */
		R0_CTRL[R_IDLE]: begin
			if(S_GP0_AXI_ARVALID) begin
				R0_CTRL <= 1 << R_DATA;
				//S_AXI_ARREADY <= 1'b1;
			end
			R0_ADDR <= S_GP0_AXI_ARADDR[31:2];
			S_GP0_AXI_RID <= S_GP0_AXI_ARID;
		end
		R0_CTRL[R_DATA]: begin
			S_GP0_AXI_RRESP <= RESP_OK;
			R0_CTRL <= 1 << R_DATA_ACK;
			case({R0_ADDR[31:2],2'b00})
				32'h4000_0000: S_GP0_AXI_RDATA <= LED_REG;
				32'h4000_0004: S_GP0_AXI_RDATA <= {24'd0, SW};
				32'h4000_0008: S_GP0_AXI_RDATA <= {27'd0, PB};
			default: begin
				S_GP0_AXI_RDATA <= 32'hDEAD_BEEF;
				S_GP0_AXI_RRESP <= RESP_DECERR;
			end
			endcase

		end
		R0_CTRL[R_DATA_ACK]: begin
			if(S_GP0_AXI_RREADY)
				R0_CTRL <= 1 << R_IDLE;
		end
		endcase

		//Write channel #0 - AXI-Lite (single transaction process)
		case(1'b1) /* synthesis parallel_case */
		W0_CTRL[W_IDLE]: begin
			if(S_GP0_AXI_AWVALID & S_GP0_AXI_WVALID) begin
				W0_CTRL <= 1 << W_WR;
			end
			W0_ADDR <= S_GP0_AXI_AWADDR[31:2];
			W0_STRB <= S_GP0_AXI_WSTRB;
			W0_DATA <= S_GP0_AXI_WDATA;
			S_GP0_AXI_BID <= S_GP0_AXI_WID;
		end
		W0_CTRL[W_WR]: begin
			W0_CTRL <= 1 << W_RESP;
			S_GP0_AXI_BRESP <= RESP_OK;
			case({W0_ADDR[31:2], 2'b00})
				32'h4000_0000: begin
					if(W0_STRB[0]) LED_REG[7:0] <= W0_DATA[7:0];
					if(W0_STRB[1]) LED_REG[15:8] <= W0_DATA[15:8];
					if(W0_STRB[2]) LED_REG[23:16] <= W0_DATA[23:16];
					if(W0_STRB[3]) LED_REG[31:24] <= W0_DATA[31:24];
				end

				32'h4000_0010: begin
					//TIC-TOC register
				end
				default:
					S_GP0_AXI_BRESP <= RESP_DECERR;
			endcase
		end
		W0_CTRL[W_RESP]:
			if(S_GP0_AXI_BREADY)
				W0_CTRL <= 1 << W_IDLE;
		/*W0_CTRL[W_WAIT]:
			W0_CTRL <= 1 << W_RESP;*/
		endcase
	end
	else begin
		W0_CTRL <= 1 << W_IDLE;
		R0_CTRL <= 1 << R_IDLE;
	end
	S_GP0_AXI_AWREADY <= W0_CTRL[W_IDLE] & S_GP0_AXI_AWVALID & S_GP0_AXI_WVALID;
	S_GP0_AXI_WREADY <= W0_CTRL[W_IDLE] & S_GP0_AXI_AWVALID & S_GP0_AXI_WVALID;
end /* always */

// Diagnostic display
always @(*) begin
	LED = 8'b0000_0000;
	case(SW[1:0])
		2'b00: LED = LED_REG[7:0];
		2'b01: LED = LED_REG[15:8];
		2'b10: LED = LED_REG[23:16];
		2'b11: LED = LED_REG[31:24];
	endcase
end

assign PB = {PB_C, PB_U, PB_D, PB_R, PB_L};

endmodule


