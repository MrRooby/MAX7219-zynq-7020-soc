# DIN / MOSI -> Pin 1 (Y18)
set_property -dict {PACKAGE_PIN Y18  IOSTANDARD LVCMOS33} [get_ports {d_out}];

# CS / LOAD  -> Pin 2 (Y19)
set_property -dict {PACKAGE_PIN Y19  IOSTANDARD LVCMOS33} [get_ports {load}];

# SCLK       -> Pin 3 (Y16)
set_property -dict {PACKAGE_PIN Y16  IOSTANDARD LVCMOS33} [get_ports {clk_out}];


# ----------------------------------------------------------------------------
# User LEDs - Bank 33
# ----------------------------------------------------------------------------
#set_property -dict { PACKAGE_PIN T22 IOSTANDARD LVCMOS33 } [get_ports {LED[0]}];  # "LED0"
#set_property -dict { PACKAGE_PIN T21 IOSTANDARD LVCMOS33 } [get_ports {LED[1]}];  # "LED1"
#set_property -dict { PACKAGE_PIN U22 IOSTANDARD LVCMOS33 } [get_ports {LED[2]}];  # "LED2"
#set_property -dict { PACKAGE_PIN U21 IOSTANDARD LVCMOS33 } [get_ports {LED[3]}];  # "LED3"
#set_property -dict { PACKAGE_PIN V22 IOSTANDARD LVCMOS33 } [get_ports {LED[4]}];  # "LED4"
#set_property -dict { PACKAGE_PIN W22 IOSTANDARD LVCMOS33 } [get_ports {LED[5]}];  # "LED5"
#set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports {LED[6]}];  # "LED6"
#set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } [get_ports {LED[7]}];  # "LED7"

# ----------------------------------------------------------------------------
# User DIP Switches - Bank 35
# ----------------------------------------------------------------------------
#set_property -dict { PACKAGE_PIN F22 IOSTANDARD LVCMOS18 } [get_ports {SW[0]}];  # "SW0"
#set_property -dict { PACKAGE_PIN G22 IOSTANDARD LVCMOS18 } [get_ports {SW[1]}];  # "SW1"
#set_property -dict { PACKAGE_PIN H22 IOSTANDARD LVCMOS18 } [get_ports {SW[2]}];  # "SW2"
#set_property -dict { PACKAGE_PIN F21 IOSTANDARD LVCMOS18 } [get_ports {SW[3]}];  # "SW3"
#set_property -dict { PACKAGE_PIN H19 IOSTANDARD LVCMOS18 } [get_ports {SW[4]}];  # "SW4"
#set_property -dict { PACKAGE_PIN H18 IOSTANDARD LVCMOS18 } [get_ports {SW[5]}];  # "SW5"
#set_property -dict { PACKAGE_PIN H17 IOSTANDARD LVCMOS18 } [get_ports {SW[6]}];  # "SW6"
#set_property -dict { PACKAGE_PIN M15 IOSTANDARD LVCMOS18 } [get_ports {SW[7]}];  # "SW7"

# ----------------------------------------------------------------------------
# User Push Buttons Switches - Bank 35
# ----------------------------------------------------------------------------
#set_property -dict { PACKAGE_PIN P16 IOSTANDARD LVCMOS18 } [get_ports {PB_C}];  # "BTNC"
#set_property -dict { PACKAGE_PIN R16 IOSTANDARD LVCMOS18 } [get_ports {PB_D}];  # "BTND"
#set_property -dict { PACKAGE_PIN N15 IOSTANDARD LVCMOS18 } [get_ports {PB_L}];  # "BTNL"
#set_property -dict { PACKAGE_PIN R18 IOSTANDARD LVCMOS18 } [get_ports {PB_R}];  # "BTNR"
#set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS18 } [get_ports {PB_U}];  # Button Up


# Note that the bank voltage for IO Bank 33 is fixed to 3.3V on ZedBoard.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];

# Set the bank voltage for IO Bank 34 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 34]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 34]];
# set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];


# Set the bank voltage for IO Bank 35 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 35]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 35]];
# set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 35]];
