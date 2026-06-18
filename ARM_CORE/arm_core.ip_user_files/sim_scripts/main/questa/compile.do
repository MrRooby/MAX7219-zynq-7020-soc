vlib questa_lib/work
vlib questa_lib/msim

vlib questa_lib/msim/xilinx_vip
vlib questa_lib/msim/axi_infrastructure_v1_1_0
vlib questa_lib/msim/axi_vip_v1_1_22
vlib questa_lib/msim/processing_system7_vip_v1_0_24
vlib questa_lib/msim/xil_defaultlib

vmap xilinx_vip questa_lib/msim/xilinx_vip
vmap axi_infrastructure_v1_1_0 questa_lib/msim/axi_infrastructure_v1_1_0
vmap axi_vip_v1_1_22 questa_lib/msim/axi_vip_v1_1_22
vmap processing_system7_vip_v1_0_24 questa_lib/msim/processing_system7_vip_v1_0_24
vmap xil_defaultlib questa_lib/msim/xil_defaultlib

vlog -work xilinx_vip -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+/media/bartek/LEXAR/DEV/FPGA/Xylinx/2025.2/data/xilinx_vip/include" \
"/media/bartek/LEXAR/DEV/FPGA/Xylinx/2025.2/data/xilinx_vip/hdl/axi4stream_vip_axi4streampc.sv" \
"/media/bartek/LEXAR/DEV/FPGA/Xylinx/2025.2/data/xilinx_vip/hdl/axi_vip_axi4pc.sv" \
"/media/bartek/LEXAR/DEV/FPGA/Xylinx/2025.2/data/xilinx_vip/hdl/xil_common_vip_pkg.sv" \
"/media/bartek/LEXAR/DEV/FPGA/Xylinx/2025.2/data/xilinx_vip/hdl/axi4stream_vip_pkg.sv" \
"/media/bartek/LEXAR/DEV/FPGA/Xylinx/2025.2/data/xilinx_vip/hdl/axi_vip_pkg.sv" \
"/media/bartek/LEXAR/DEV/FPGA/Xylinx/2025.2/data/xilinx_vip/hdl/axi4stream_vip_if.sv" \
"/media/bartek/LEXAR/DEV/FPGA/Xylinx/2025.2/data/xilinx_vip/hdl/axi_vip_if.sv" \
"/media/bartek/LEXAR/DEV/FPGA/Xylinx/2025.2/data/xilinx_vip/hdl/clk_vip_if.sv" \
"/media/bartek/LEXAR/DEV/FPGA/Xylinx/2025.2/data/xilinx_vip/hdl/rst_vip_if.sv" \

vlog -work axi_infrastructure_v1_1_0 -64 -incr -mfcu  "+incdir+../../../../arm_core.gen/sources_1/bd/main/ipshared/ec67/hdl" "+incdir+../../../../arm_core.gen/sources_1/bd/main/ipshared/9a25/hdl" "+incdir+../../../../../../../../DEV/FPGA/Xylinx/2025.2/data/rsb/busdef" "+incdir+/media/bartek/LEXAR/DEV/FPGA/Xylinx/2025.2/data/xilinx_vip/include" \
"../../../../arm_core.gen/sources_1/bd/main/ipshared/ec67/hdl/axi_infrastructure_v1_1_vl_rfs.v" \

vlog -work axi_vip_v1_1_22 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../arm_core.gen/sources_1/bd/main/ipshared/ec67/hdl" "+incdir+../../../../arm_core.gen/sources_1/bd/main/ipshared/9a25/hdl" "+incdir+../../../../../../../../DEV/FPGA/Xylinx/2025.2/data/rsb/busdef" "+incdir+/media/bartek/LEXAR/DEV/FPGA/Xylinx/2025.2/data/xilinx_vip/include" \
"../../../../arm_core.gen/sources_1/bd/main/ipshared/b16a/hdl/axi_vip_v1_1_vl_rfs.sv" \

vlog -work processing_system7_vip_v1_0_24 -64 -incr -mfcu  -sv -L axi_vip_v1_1_22 -L processing_system7_vip_v1_0_24 -L xilinx_vip "+incdir+../../../../arm_core.gen/sources_1/bd/main/ipshared/ec67/hdl" "+incdir+../../../../arm_core.gen/sources_1/bd/main/ipshared/9a25/hdl" "+incdir+../../../../../../../../DEV/FPGA/Xylinx/2025.2/data/rsb/busdef" "+incdir+/media/bartek/LEXAR/DEV/FPGA/Xylinx/2025.2/data/xilinx_vip/include" \
"../../../../arm_core.gen/sources_1/bd/main/ipshared/9a25/hdl/processing_system7_vip_v1_0_vl_rfs.sv" \

vlog -work xil_defaultlib -64 -incr -mfcu  "+incdir+../../../../arm_core.gen/sources_1/bd/main/ipshared/ec67/hdl" "+incdir+../../../../arm_core.gen/sources_1/bd/main/ipshared/9a25/hdl" "+incdir+../../../../../../../../DEV/FPGA/Xylinx/2025.2/data/rsb/busdef" "+incdir+/media/bartek/LEXAR/DEV/FPGA/Xylinx/2025.2/data/xilinx_vip/include" \
"../../../bd/main/ip/main_processing_system7_0_0/sim/main_processing_system7_0_0.v" \
"../../../bd/main/sim/main.v" \

vlog -work xil_defaultlib \
"glbl.v"

