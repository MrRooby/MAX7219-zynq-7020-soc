//-----------------------------------------------------------------------------
//
// Title       : AXI_IO_INT_tb
// Design      : axi_zed
// Author      : Adam
// Company     : AME
//
//-----------------------------------------------------------------------------
//
// File        : AXI_IO_INT_TB.v
// Generated   : Wed Mar 23 07:13:58 2022
// From        : D:\soc22_macro\axi_zed\axi_zed\src\TestBench\AXI_IO_INT_TB_settings.txt
// By          : tb_verilog.pl ver. ver 1.2s
//
//-----------------------------------------------------------------------------
//
// Description : 
//
//-----------------------------------------------------------------------------

`timescale 1ns / 100ps
module AXI_IO_INT_tb;

//Internal signals declarations:
reg CLK;
reg S_GP0_AXI_ARESETN;

wire [31:0]S_GP0_AXI_AWADDR;
wire [11:0]S_GP0_AXI_AWID;
wire [2:0]S_GP0_AXI_AWPROT;
wire S_GP0_AXI_AWVALID;
wire S_GP0_AXI_AWREADY;
wire [31:0]S_GP0_AXI_WDATA;
wire [11:0]S_GP0_AXI_WID;
wire [3:0]S_GP0_AXI_WSTRB;
wire S_GP0_AXI_WLAST;
wire S_GP0_AXI_WVALID;
wire S_GP0_AXI_WREADY;
wire [1:0]S_GP0_AXI_BRESP;
wire [11:0]S_GP0_AXI_BID;
wire S_GP0_AXI_BVALID;
wire S_GP0_AXI_BREADY;
wire [31:0]S_GP0_AXI_ARADDR;
wire [11:0]S_GP0_AXI_ARID;
wire [2:0]S_GP0_AXI_ARPROT;
wire [1:0]S_GP0_AXI_ARBURST;
wire [3:0]S_GP0_AXI_ARLEN;
wire [1:0]S_GP0_AXI_ARSIZE;
wire S_GP0_AXI_ARVALID;
wire S_GP0_AXI_ARREADY;
wire [31:0]S_GP0_AXI_RDATA;
wire [11:0]S_GP0_AXI_RID;
wire [1:0]S_GP0_AXI_RRESP;
wire S_GP0_AXI_RVALID;
wire S_GP0_AXI_RREADY;
wire S_GP0_AXI_RLAST;

wire INT;
reg [7:0]SW;
reg PB_C, PB_U, PB_D, PB_R, PB_L;
wire [7:0]LED;



// Unit Under Test port map
	AXI_IO_INT UUT (
		.CLK(CLK),
		.S_GP0_AXI_ARESETN(S_GP0_AXI_ARESETN),
		.S_GP0_AXI_AWADDR(S_GP0_AXI_AWADDR),
		.S_GP0_AXI_AWID(S_GP0_AXI_AWID),
		.S_GP0_AXI_AWPROT(S_GP0_AXI_AWPROT),
		.S_GP0_AXI_AWVALID(S_GP0_AXI_AWVALID),
		.S_GP0_AXI_AWREADY(S_GP0_AXI_AWREADY),
		.S_GP0_AXI_WDATA(S_GP0_AXI_WDATA),
		.S_GP0_AXI_WID(S_GP0_AXI_WID),
		.S_GP0_AXI_WSTRB(S_GP0_AXI_WSTRB),
		.S_GP0_AXI_WVALID(S_GP0_AXI_WVALID),
		.S_GP0_AXI_WREADY(S_GP0_AXI_WREADY),
		.S_GP0_AXI_BRESP(S_GP0_AXI_BRESP),
		.S_GP0_AXI_BID(S_GP0_AXI_BID),
		.S_GP0_AXI_BVALID(S_GP0_AXI_BVALID),
		.S_GP0_AXI_BREADY(S_GP0_AXI_BREADY),
		.S_GP0_AXI_ARADDR(S_GP0_AXI_ARADDR),
		.S_GP0_AXI_ARID(S_GP0_AXI_ARID),
		.S_GP0_AXI_ARPROT(S_GP0_AXI_ARPROT),
		.S_GP0_AXI_ARBURST(S_GP0_AXI_ARBURST),
		.S_GP0_AXI_ARLEN(S_GP0_AXI_ARLEN),
		.S_GP0_AXI_ARSIZE(S_GP0_AXI_ARSIZE),
		.S_GP0_AXI_ARVALID(S_GP0_AXI_ARVALID),
		.S_GP0_AXI_ARREADY(S_GP0_AXI_ARREADY),
		.S_GP0_AXI_RDATA(S_GP0_AXI_RDATA),
		.S_GP0_AXI_RID(S_GP0_AXI_RID),
		.S_GP0_AXI_RRESP(S_GP0_AXI_RRESP),
		.S_GP0_AXI_RVALID(S_GP0_AXI_RVALID),
		.S_GP0_AXI_RREADY(S_GP0_AXI_RREADY),
		.S_GP0_AXI_RLAST(S_GP0_AXI_RLAST),
		.INT(INT),
		.SW(SW),
		.PB_C(PB_C), .PB_U(PB_U), .PB_D(PB_D), .PB_R(PB_R), .PB_L(PB_L),
		.LED(LED));

AXI_4_M_BFM AXI_GP0 (
	.S_AXI_ACLK(CLK),
	.S_AXI_ARESETN(S_GP0_AXI_ARESETN),
	.S_AXI_AWADDR(S_GP0_AXI_AWADDR),
	.S_AXI_AWID(S_GP0_AXI_AWID),
	.S_AXI_AWPROT(S_GP0_AXI_AWPROT),
	.S_AXI_AWVALID(S_GP0_AXI_AWVALID),
	.S_AXI_AWREADY(S_GP0_AXI_AWREADY),
	.S_AXI_WDATA(S_GP0_AXI_WDATA),
	.S_AXI_WID(S_GP0_AXI_WID),
	.S_AXI_WSTRB(S_GP0_AXI_WSTRB),
	.S_AXI_WLAST(S_GP0_AXI_WLAST),
	.S_AXI_WVALID(S_GP0_AXI_WVALID),
	.S_AXI_WREADY(S_GP0_AXI_WREADY),
	.S_AXI_BRESP(S_GP0_AXI_BRESP),
	.S_AXI_BID(S_GP0_AXI_BID),
	.S_AXI_BVALID(S_GP0_AXI_BVALID),
	.S_AXI_BREADY(S_GP0_AXI_BREADY),
	.S_AXI_ARADDR(S_GP0_AXI_ARADDR),
	.S_AXI_ARID(S_GP0_AXI_ARID),
	.S_AXI_ARPROT(S_GP0_AXI_ARPROT),
	.S_AXI_ARBURST(S_GP0_AXI_ARBURST),
	.S_AXI_ARLEN(S_GP0_AXI_ARLEN),
	.S_AXI_ARSIZE(S_GP0_AXI_ARSIZE),
	.S_AXI_ARVALID(S_GP0_AXI_ARVALID),
	.S_AXI_ARREADY(S_GP0_AXI_ARREADY),
	.S_AXI_RDATA(S_GP0_AXI_RDATA),
	.S_AXI_RID(S_GP0_AXI_RID),
	.S_AXI_RRESP(S_GP0_AXI_RRESP),
	.S_AXI_RVALID(S_GP0_AXI_RVALID),
	.S_AXI_RREADY(S_GP0_AXI_RREADY),
	.S_AXI_RLAST(S_GP0_AXI_RLAST));
	
initial begin
	CLK = 1'b0;
	forever #5 CLK = ~CLK;	
end

reg [1:0] BR;
reg [31:0] DATA;
		
initial begin
	SW = 8'h00;
	S_GP0_AXI_ARESETN = 1'b0;	
	WAIT(3);
	S_GP0_AXI_ARESETN = 1'b1;	
	WAIT(10);	
	//Write LED
	AXI_GP0.WR(32'h4000_0000, 32'd400, 4'b1111, BR);
	//Write TMR_Q
	$display("Timer write");
	AXI_GP0.WR(32'h4000_0040, 32'd400, 4'b1111, BR);
	//Run timer
	AXI_GP0.WR(32'h4000_0044, 32'h0000_0001, 4'b1111, BR);
	AXI_GP0.RD(32'h4000_0044, DATA, BR);
	if(DATA[0] !== 1'b1) begin
		$display("Timer CTRL register RUN flag not set after request.");
		$stop;
	end
	WAIT(5);
	DATA = 32'd0;
	while(!DATA[31]) begin
		WAIT(5);
		AXI_GP0.RD(32'h4000_0044, DATA, BR);
		if(BR !== 2'b00) begin
			$display("%m: Fatal - Timer CTRL register not implemented.");
			$finish;
		end
		if(DATA[31] === 1'b1) begin
			if(INT !== 1'b1) begin
				$display("Fatal Error - INT line not set.");
				$finish;
			end
		end
	end	
	WAIT(20);
	AXI_GP0.WR(32'h4000_0044, 32'h8000_0001, 4'b1111, BR);
	if(INT === 1'b1) begin
		$display("Fatal Error- INT line not cleared.");
		$finish;
	end
	WAIT(100);
	$display("All tests for %m completed succesfully");
	$finish;
end

initial begin
	$dumpfile("axi_int.vcd");
	$dumpvars(0, AXI_IO_INT_tb);
	$dumpon;
end

task WAIT;
input [31:0] DY;
begin
	repeat(DY) @(negedge CLK);	
end
endtask

endmodule
