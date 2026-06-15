//-----------------------------------------------------------------------------
//
// Title       : AXI_IO_tb
// Design      : axi_zed
// Author      : Adam
// Company     : AME
//
//-----------------------------------------------------------------------------
//
// File        : AXI_IO_TB.v
// Generated   : Wed Mar 16 08:18:03 2022
// From        : D:\soc22_macro\axi_zed\axi_zed\src\TestBench\AXI_IO_TB_settings.txt
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
reg S_GP0_AXI_ARESETN;
wire [31:0]S_GP0_AXI_AWADDR;
wire [11:0]S_GP0_AXI_AWID;
wire [2:0]S_GP0_AXI_AWPROT;
wire S_GP0_AXI_AWVALID;
wire S_GP0_AXI_AWREADY;
wire [31:0]S_GP0_AXI_WDATA;
wire [11:0]S_GP0_AXI_WID;
wire [3:0]S_GP0_AXI_WSTRB;
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

reg [7:0]SW;
reg [4:0]PB;
wire [7:0]LED;

// Unit Under Test port map
AXI_IO UUT (
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
	.SW(SW),
	.PB_C(PB[4]), .PB_U(PB[3]), .PB_D(PB[2]), .PB_R(PB[1]), .PB_L(PB[0]),
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
	SW = 8'h00; PB = 5'd0;
	S_GP0_AXI_ARESETN = 1'b0;
	WAIT(3);
	S_GP0_AXI_ARESETN = 1'b1;
	WAIT(10);
	AXI_GP0.WR(32'h4000_0000, 32'h0000_0000, 4'b1111, BR);
	AXI_GP0.WR(32'h4000_0000, 32'h0000_000F, 4'b1111, BR);
	AXI_GP0.WR(32'h4000_0100, 32'h0000_0003, 4'b0001, BR);
	WAIT(5);
	AXI_GP0.RD(32'h4000_0000, DATA, BR);
	AXI_GP0.RD(32'h4000_0004, DATA, BR);
	SW = 8'h05;
	AXI_GP0.RD(32'h4000_0004, DATA, BR);
	SW = 8'h50;
	AXI_GP0.RD(32'h4000_0004, DATA, BR);
	AXI_GP0.RD(32'h4001_0004, DATA, BR);
	WAIT(100);
	$finish;
end

initial begin
	$dumpfile("axi_io.vcd");
	$dumpvars(0, AXI_IO_tb);
	$dumpon;
end

task WAIT;
input [31:0] DY;
begin
	repeat(DY) @(negedge CLK);
end
endtask

endmodule
