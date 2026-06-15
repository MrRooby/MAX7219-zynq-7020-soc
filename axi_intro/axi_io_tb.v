//-----------------------------------------------------------------------------
//
// Title       : AXI_IO_tb
// Design      : axi_intro
// Author      : Adam
// Company     : AME
//
//-----------------------------------------------------------------------------
//
// File        : AXI_IO_TB.v
// Generated   : Mon Apr 24 06:17:52 2023
// From        : D:\soc23_intel\axi_intro_ah\axi_intro\src\TestBench\AXI_IO_TB_settings.txt
// By          : tb_verilog.pl ver. ver 1.2s
//
//-----------------------------------------------------------------------------
//
// Description :
//
//-----------------------------------------------------------------------------

`timescale 1ns / 100ps
module AXI_IO_tb;

//Internal signals declarations:
reg CLK;
reg AXI_ARESETN;
wire [31:0] AXI_AWADDR;
wire [11:0] AXI_AWID;
wire [2:0] AXI_AWPROT;
wire AXI_AWVALID;
wire AXI_AWREADY;
wire [31:0] AXI_WDATA;
wire [11:0] AXI_WID;
wire [3:0] AXI_WSTRB;
wire AXI_WVALID;
wire AXI_WREADY;
wire AXI_WLAST;
wire [1:0] AXI_BRESP;
wire [11:0] AXI_BID;
wire AXI_BVALID;
wire AXI_BREADY;
wire [31:0] AXI_ARADDR;
wire [11:0] AXI_ARID;
wire [2:0] AXI_ARPROT;
wire [1:0] AXI_ARBURST;
wire [3:0] AXI_ARLEN;
wire [1:0] AXI_ARSIZE;
wire AXI_ARVALID;
wire AXI_ARREADY;
wire [31:0] AXI_RDATA;
wire [11:0] AXI_RID;
wire [1:0] AXI_RRESP;
wire AXI_RVALID;
wire AXI_RREADY;
wire AXI_RLAST;

reg [7:0] SW;
reg [4:0] PB;
wire [7:0] LED;



// Unit Under Test port map
	AXI_IO UUT (
		.CLK(CLK),
		.S_AXI_ARESETN(AXI_ARESETN),
		.S_AXI_AWADDR(AXI_AWADDR),
		.S_AXI_AWID(AXI_AWID),
		.S_AXI_AWPROT(AXI_AWPROT),
		.S_AXI_AWVALID(AXI_AWVALID),
		.S_AXI_AWREADY(AXI_AWREADY),
		.S_AXI_WDATA(AXI_WDATA),
		.S_AXI_WID(AXI_WID),
		.S_AXI_WSTRB(AXI_WSTRB),
		.S_AXI_WVALID(AXI_WVALID),
		.S_AXI_WREADY(AXI_WREADY),
		.S_AXI_BRESP(AXI_BRESP),
		.S_AXI_BID(AXI_BID),
		.S_AXI_BVALID(AXI_BVALID),
		.S_AXI_BREADY(AXI_BREADY),
		.S_AXI_ARADDR(AXI_ARADDR),
		.S_AXI_ARID(AXI_ARID),
		.S_AXI_ARPROT(AXI_ARPROT),
		.S_AXI_ARBURST(AXI_ARBURST),
		.S_AXI_ARLEN(AXI_ARLEN),
		.S_AXI_ARSIZE(AXI_ARSIZE),
		.S_AXI_ARVALID(AXI_ARVALID),
		.S_AXI_ARREADY(AXI_ARREADY),
		.S_AXI_RDATA(AXI_RDATA),
		.S_AXI_RID(AXI_RID),
		.S_AXI_RRESP(AXI_RRESP),
		.S_AXI_RVALID(AXI_RVALID),
		.S_AXI_RREADY(AXI_RREADY),
		.S_AXI_RLAST(AXI_RLAST),
		.SW(SW),
		.PB(PB),
		.LED(LED));

AXI_4_M_BFM BFM(
	.S_AXI_ACLK(CLK), 		// AXI Clock signal
	.S_AXI_ARESETN(AXI_ARESETN),	// Global Reset Signal. This Signal is Active LOW

	// Write address channel
	.S_AXI_AWADDR(AXI_AWADDR),	//Write address
	.S_AXI_AWID(AXI_AWID),		//Write address transaction ID
	.S_AXI_AWPROT(AXI_AWPROT),	//Write protection
	.S_AXI_AWVALID(AXI_AWVALID),		//Write address valid
	.S_AXI_AWREADY(AXI_AWREADY),		//Write ready -> ACK S->M

	/* Write data channel */
	.S_AXI_WDATA(AXI_WDATA),	//Write data (issued by master, acceped by Slave)
	.S_AXI_WID(AXI_WID),		//Write data transaction ID
	.S_AXI_WSTRB(AXI_WSTRB),	//Write strob - selection of bytes to be written to
	.S_AXI_WLAST(AXI_WLAST),	//Write last package - burst transfer
	.S_AXI_WVALID(AXI_WVALID),	//Walid write data
	.S_AXI_WREADY(AXI_WREADY),	//Slave ACK of write operation

	/* Response channel S -> M */
	.S_AXI_BRESP(AXI_BRESP),	//Response data
	.S_AXI_BID(AXI_BID),
	.S_AXI_BVALID(AXI_BVALID),	//Valid response
	.S_AXI_BREADY(AXI_BREADY),	//Master ACK

	// Read address (issued by master, acceped by Slave)
	/* Read address channel */
	.S_AXI_ARADDR(AXI_ARADDR),	//Read address
	.S_AXI_ARID(AXI_ARID),		//Read transaction request ID
	.S_AXI_ARPROT(AXI_ARPROT),	//Read protection
	.S_AXI_ARBURST(AXI_ARBURST),	//Burst type FIXED, INCR, WRAP
	.S_AXI_ARLEN(AXI_ARLEN),	//The burst length
	.S_AXI_ARSIZE(AXI_ARSIZE),	//Transaction size
	.S_AXI_ARVALID(AXI_ARVALID),	//Read address valid
	.S_AXI_ARREADY(AXI_ARREADY),	//Slave read address ACK

	// Read data channel: S -> M
	.S_AXI_RDATA(AXI_RDATA),	//Read data S -> M
	.S_AXI_RID(AXI_RID),		//Read data transaction ID
	.S_AXI_RRESP(AXI_RRESP),	//Read response M -> S
	.S_AXI_RVALID(AXI_RVALID),	//Read data valid S -> M
	.S_AXI_RREADY(AXI_RREADY),	//Read data ACK M -> S
	.S_AXI_RLAST(AXI_RLAST)		//Read data last burst cycle
	);

initial begin
    AXI_ARESETN	= 1'b0;
	repeat(3) @(negedge CLK);
	AXI_ARESETN = 1'b1;
	repeat(200) @(negedge CLK);
	//Here gose the test scenario...
	//Can be distributed in other blocks too...
    $display("%m[%6t]: End of test", $time);
	$finish;
end

initial begin
    CLK = 1'b0;
    forever #5 CLK = ~CLK;
end

initial begin
	$dumpfile("axi_io.vcd");
	$dumpvars;
	$dumpon;
end

endmodule
