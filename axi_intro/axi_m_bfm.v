`timescale 1ns/100ps

module AXI_4_M_BFM(
	S_AXI_ACLK, 		// AXI Clock signal
	S_AXI_ARESETN,	// Global Reset Signal. This Signal is Active LOW

	// Write address channel
	S_AXI_AWADDR,	//Write address
	S_AXI_AWID,		//Write address transaction ID
	S_AXI_AWPROT,	//Write protection
	S_AXI_AWVALID,		//Write address valid
	S_AXI_AWREADY,		//Write ready -> ACK S->M

	/* Write data channel */
	S_AXI_WDATA,	//Write data (issued by master, acceped by Slave)
	S_AXI_WID,		//Write data transaction ID
	S_AXI_WSTRB,	//Write strob - selection of bytes to be written to
	S_AXI_WLAST,	//Write last package - burst transfer
	S_AXI_WVALID,	//Walid write data
	S_AXI_WREADY,	//Slave ACK of write operation

	/* Response channel S -> M */
	S_AXI_BRESP,	//Response data
	S_AXI_BID,
	S_AXI_BVALID,	//Valid response
	S_AXI_BREADY,	//Master ACK

	// Read address (issued by master, acceped by Slave)
	/* Read address channel */
	S_AXI_ARADDR,	//Read address
	S_AXI_ARID,		//Read transaction request ID
	S_AXI_ARPROT,	//Read protection
	S_AXI_ARBURST,	//Burst type FIXED, INCR, WRAP
	S_AXI_ARLEN,	//The burst length
	S_AXI_ARSIZE,	//Transaction size
	S_AXI_ARVALID,	//Read address valid
	S_AXI_ARREADY,	//Slave read address ACK

	// Read data channel: S -> M
	S_AXI_RDATA,	//Read data S -> M
	S_AXI_RID,		//Read data transaction ID
	S_AXI_RRESP,	//Read response M -> S
	S_AXI_RVALID,	//Read data valid S -> M
	S_AXI_RREADY,	//Read data ACK M -> S
	S_AXI_RLAST		//Read data last burst cycle
	);

//AXI Slave Controller Response
parameter RESP_OK 		= 2'b00; //Transaction OK
parameter RESP_SLVERR	= 2'b10; //Slave device not ready
parameter RESP_DECERR	= 2'b11; //No slave device at this address

//AXI4 Bus
input S_AXI_ACLK; 		// AXI Clock signal
input S_AXI_ARESETN;	// Global Reset Signal. This Signal is Active LOW
// Write address channel
output reg [31:0] S_AXI_AWADDR;	//Write address
output reg [11:0] S_AXI_AWID;	//Write address transaction ID
output reg [2:0] S_AXI_AWPROT;	//Write protection
output reg S_AXI_AWVALID;		//Write address valid
input S_AXI_AWREADY;		//Write ready -> ACK S->M

/* Write data channel */
output reg [31:0] S_AXI_WDATA;	//Write data (issued by master, acceped by Slave)
output reg [11:0] S_AXI_WID;		//Write data transaction ID
output reg [3:0] S_AXI_WSTRB;	//Write strob - selection of bytes to be written to
output reg S_AXI_WLAST;
output reg S_AXI_WVALID;			//Walid write data
input S_AXI_WREADY;		//Slave ACK of write operation

/* Response channel S -> M */
input [1:0] S_AXI_BRESP;	//Response data
input [11:0] S_AXI_BID;
input S_AXI_BVALID;			//Valid response
output  reg S_AXI_BREADY;		//Master ACK

// Read address (issued by master, acceped by Slave)
/* Read address channel */
output reg [31:0] S_AXI_ARADDR;	//Read address
output reg [11:0] S_AXI_ARID;	//Read transaction request ID
output reg [2:0] S_AXI_ARPROT;	//Read protection
output reg [1:0] S_AXI_ARBURST; //Burst type FIXED, INCR, WRAP
output reg [3:0] S_AXI_ARLEN; //The burst length
output reg [1:0] S_AXI_ARSIZE; //Transaction size
output reg S_AXI_ARVALID;		//Read address valid
input S_AXI_ARREADY;		//Slave read address ACK

// Read data channel: S -> M
input [31:0] S_AXI_RDATA;	//Read data S -> M
input [11:0] S_AXI_RID;	//Read data transaction ID
input [1:0] S_AXI_RRESP;	//Read response M -> S
input S_AXI_RVALID;		//Read data valid S -> M
output reg S_AXI_RREADY;			//Read data ACK M -> S
input S_AXI_RLAST;


// Write channel model
parameter BFM_W_IDLE = 0;
parameter BFM_W_ADDR = 1;
parameter BFM_W_DATA = 2;
parameter BFM_W_VALID = 3;
reg W_RQ;
reg [2:0] W_STATE;
reg [31:0] W_ADDR;
reg [31:0] W_DATA;
reg [3:0] W_STRB;
reg [1:0] W_BRESP;
integer W_CNT;

parameter BFM_R_IDLE = 0;
parameter BFM_R_ADDR = 1;
parameter BFM_R_DATA = 2;
reg R_RQ;
reg [2:0] R_STATE;
reg [31:0] R_ADDR;
reg [31:0] R_DATA;
reg [1:0] R_RESP;
integer R_CNT;

initial begin
	W_RQ = 1'b0;
	/*S_AXI_AWADDR = 32'hxxxx_xxxx;
	S_AXI_AWVALID = 1'b0;
	S_AXI_WDATA = 32'hxxxx_xxxx;
	S_AXI_WSTRB = 4'hx;
	S_AXI_WVALID = 1'b0;*/
end

always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
	if(S_AXI_ARESETN) begin
		case(W_STATE)
		BFM_W_IDLE: begin
			S_AXI_BREADY = 1'b0;
			if(W_RQ) begin
				$display("%m: %6t - WRITE transaction start @0x%0h.", $time, W_ADDR);
				W_STATE = BFM_W_ADDR;
				S_AXI_AWADDR = W_ADDR;
				S_AXI_AWVALID = 1'b1;
				S_AXI_WDATA = W_DATA;
				S_AXI_WSTRB = W_STRB;
				S_AXI_WVALID = 1'b1;
				W_CNT = 0;
			end
		end
		BFM_W_ADDR: begin
			if(S_AXI_AWREADY == 1'b1) begin
				$display("%m:%6t : WRITE transaction - address ACK (%d).", $time, W_CNT);
				S_AXI_AWADDR = 32'hxxxx_xxxx;
				S_AXI_AWVALID = 1'b0;
				//Fast path - data
				if(S_AXI_WREADY == 1'b1) begin
					$display("%m:%6t - WRITE transaction - data ACK (%d),", $time, W_CNT);
					W_STATE = BFM_W_VALID;
					S_AXI_WDATA = 32'hxxxx_xxxx;
					S_AXI_WSTRB = 4'hx;
					S_AXI_WVALID = 1'b0;
					S_AXI_BREADY = 1'b1;					
				end
				else begin
					W_STATE = BFM_W_DATA;
				end
			end
			else begin
				W_CNT = W_CNT + 1;
			end
		end
		BFM_W_DATA: begin
			if(S_AXI_WREADY == 1'b1) begin
				$display("%m:%6t : WRITE transaction - data ACK (%d),", $time, W_CNT);
				W_STATE = BFM_W_VALID;
				S_AXI_WDATA = 32'hxxxx_xxxx;
				S_AXI_WSTRB = 4'hx;
				S_AXI_WVALID = 1'b0;
				S_AXI_BREADY = 1'b1;				
			end
			else begin
			   W_CNT = W_CNT + 1;
			end
		end
		BFM_W_VALID: begin
			if(S_AXI_BVALID) begin
				RESP_INFO(S_AXI_BRESP);
				W_STATE = BFM_W_IDLE;
				S_AXI_BREADY = 1'b0;
			end
		end
		endcase
	end
	else begin
		W_STATE = BFM_W_IDLE;
		S_AXI_AWADDR = 32'hxxxx_xxxx;
		S_AXI_AWVALID = 1'b0;
		S_AXI_WDATA = 32'hxxxx_xxxx;
		S_AXI_WSTRB = 4'hx;
		S_AXI_WVALID = 1'b0;
		S_AXI_BREADY = 1'b0;
	end
end

always @(posedge S_AXI_ACLK or negedge S_AXI_ARESETN) begin
	if(S_AXI_ARESETN) begin
		case(R_STATE)
		BFM_R_IDLE: begin
			if(R_RQ) begin
				$display("%m:%6t - READ transaction start @0x%0h.", $time, R_ADDR);
				R_STATE = BFM_R_ADDR;
				R_CNT = 0;
				S_AXI_ARADDR = R_ADDR;
				S_AXI_ARVALID = 1'b1;
				S_AXI_RREADY = 1'b1;
			end
		end
		BFM_R_ADDR: begin
			if(S_AXI_ARREADY == 1'b1) begin
				$display("%m:%6t : READ transaction - address ACK (%d).", $time, R_CNT);
				S_AXI_ARVALID = 1'b0;
				S_AXI_ARADDR = 32'hxxxx_xxxx;
				if(S_AXI_RVALID) begin
					R_STATE = BFM_R_IDLE;
					R_DATA = S_AXI_RDATA;
					R_RESP = S_AXI_RRESP;
					S_AXI_RREADY = 1'b0;
					$display("%m:%6t : READ transaction - data ACK (%d).", $time, R_CNT);
					RESP_INFO(S_AXI_RRESP);
				end
				else
					R_STATE = BFM_R_DATA;
			end
			R_CNT = R_CNT + 1;
		end
		BFM_R_DATA: begin
			if(S_AXI_RVALID) begin
				R_STATE = BFM_R_IDLE;
				R_DATA = S_AXI_RDATA;
				R_RESP = S_AXI_RRESP;
				S_AXI_RREADY = 1'b0;
				$display("%m:%6t : READ transaction - data ACK (%d).", $time, R_CNT);
				RESP_INFO(S_AXI_RRESP);
			end
			R_CNT = R_CNT + 1;
		end
		endcase
	end
	else begin
		R_STATE = BFM_R_IDLE;
		S_AXI_ARADDR = 32'hxxxx_xxxx;
		S_AXI_ARVALID = 1'b0;
		S_AXI_RREADY = 1'b0;
	end
end

task RESP_INFO;
input [1:0] RESP;
begin
	case(RESP)
	RESP_OK:
		$display("%m%6t : Response - Ok", $time);
	RESP_SLVERR:
		$display("%m%6t : Response - Slave Error.", $time);
	RESP_DECERR:
		$display("%m%6t : Response - Decode Error (Unsupportede address).", $time);
	endcase
end
endtask

task WR;
input [31:0] ADDR;
input [31:0] DATA;
input [3:0] STRB;
output [1:0] BRESP;
begin
	wait(W_STATE == BFM_W_IDLE);
	W_ADDR = ADDR;
	W_DATA = DATA;
	W_STRB = STRB;
	W_RQ = 1'b1;
	wait(W_STATE == BFM_W_ADDR);
	W_RQ = 1'b0;
	wait(W_STATE == BFM_W_IDLE);
	BRESP = W_BRESP;
end
endtask

task RD;
input [31:0] ADDR;
output [31:0] DATA;
output [1:0] RESP;
begin
	wait(R_STATE == BFM_R_IDLE);
	R_ADDR = ADDR;
	R_RQ = 1'b1;
	wait(R_STATE == BFM_R_ADDR);
	R_RQ = 1'b0;
	wait(R_STATE == BFM_R_IDLE);
	DATA = R_DATA;
	RESP = R_RESP;
end
endtask

endmodule
