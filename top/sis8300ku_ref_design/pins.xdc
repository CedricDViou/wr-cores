###################################################
##      Clocks
###################################################

set_property PACKAGE_PIN P5 [get_ports clk_mtca_n]
set_property PACKAGE_PIN P6 [get_ports clk_mtca_p]


###################################################
##       PCIe
###################################################

set_property PACKAGE_PIN N23 [get_ports pcie_rst_n]
set_property IOSTANDARD LVCMOS25 [get_ports pcie_rst_n]
set_property PULLUP true [get_ports pcie_rst_n]

set_property PACKAGE_PIN F2 [get_ports {pcie_rxp_i[0]}]
set_property PACKAGE_PIN F1 [get_ports {pcie_rxn_i[0]}]
set_property PACKAGE_PIN G4 [get_ports {pcie_txp_o[0]}]
set_property PACKAGE_PIN G3 [get_ports {pcie_txn_o[0]}]
set_property PACKAGE_PIN H2 [get_ports {pcie_rxp_i[1]}]
set_property PACKAGE_PIN H1 [get_ports {pcie_rxn_i[1]}]
set_property PACKAGE_PIN J4 [get_ports {pcie_txp_o[1]}]
set_property PACKAGE_PIN J3 [get_ports {pcie_txn_o[1]}]
set_property PACKAGE_PIN K2 [get_ports {pcie_rxp_i[2]}]
set_property PACKAGE_PIN K1 [get_ports {pcie_rxn_i[2]}]
set_property PACKAGE_PIN L4 [get_ports {pcie_txp_o[2]}]
set_property PACKAGE_PIN L3 [get_ports {pcie_txn_o[2]}]
set_property PACKAGE_PIN M2 [get_ports {pcie_rxp_i[3]}]
set_property PACKAGE_PIN M1 [get_ports {pcie_rxn_i[3]}]
set_property PACKAGE_PIN N4 [get_ports {pcie_txp_o[3]}]
set_property PACKAGE_PIN N3 [get_ports {pcie_txn_o[3]}]


###################################################
##      SFF optical links
###################################################

## Optical links (white rabbit)

set_property PACKAGE_PIN AD5 [get_ports mgtclk1_224_n_i]
set_property PACKAGE_PIN AD6 [get_ports mgtclk1_224_p_i]

## I2C + Present sff1

set_property PACKAGE_PIN AF30 [get_ports sfp1_scl_b]
set_property IOSTANDARD LVCMOS18 [get_ports sfp1_scl_b]

set_property PACKAGE_PIN AG30 [get_ports sfp1_sda_b]
set_property IOSTANDARD LVCMOS18 [get_ports sfp1_sda_b]

set_property PACKAGE_PIN AK33 [get_ports sfp1_prsnt_n_i]
set_property IOSTANDARD LVCMOS12 [get_ports sfp1_prsnt_n_i]
set_property PULLUP true [get_ports sfp1_prsnt_n_i]

## Link 1

set_property PACKAGE_PIN AK2 [get_ports sfp1_rxp_i]
set_property PACKAGE_PIN AK1 [get_ports sfp1_rxn_i]
set_property PACKAGE_PIN AL4 [get_ports sfp1_txp_o]
set_property PACKAGE_PIN AL3 [get_ports sfp1_txn_o]


###################################################
##      Analog Digital Converter
###################################################


###################################################
##  White Rabbit
###################################################


## Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AG11 [get_ports clk_20m_vcxo_i]
set_property IOSTANDARD LVCMOS25 [get_ports clk_20m_vcxo_i]

# Bank 48 voltage = 1.8V
set_property PACKAGE_PIN AA20 [get_ports wr_dac_din_o]
set_property IOSTANDARD LVCMOS18 [get_ports wr_dac_din_o]

# Bank 47 voltage = 1.8v
set_property PACKAGE_PIN AB20 [get_ports wr_dac_sclk_o]
set_property IOSTANDARD LVCMOS18 [get_ports wr_dac_sclk_o]

# Bank 47 voltage = 1.8v
set_property PACKAGE_PIN AB21 [get_ports wr_dac_pll25_sync_n_o]
set_property IOSTANDARD LVCMOS18 [get_ports wr_dac_pll25_sync_n_o]

# Bank 47 voltage = 1.8v
set_property PACKAGE_PIN AC21 [get_ports wr_dac_pll20_sync_n_o]
set_property IOSTANDARD LVCMOS18 [get_ports wr_dac_pll20_sync_n_o]



###################################################
##  diverse
###################################################


## LED signals

# Bank 64 voltage = 2.5V
set_property PACKAGE_PIN AM11 [get_ports led_serial_o]
set_property IOSTANDARD LVCMOS25 [get_ports led_serial_o]

#3 WATCHDOG signal

# Bank 47 voltage = 1.8V
set_property PACKAGE_PIN AC22 [get_ports fpga_watchdog_o]
set_property IOSTANDARD LVCMOS18 [get_ports fpga_watchdog_o]




