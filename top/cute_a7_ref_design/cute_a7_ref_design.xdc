#####################################################
#################### Version ########################
#####################################################
set_property PACKAGE_PIN D10 [get_ports VER0]
set_property PACKAGE_PIN A14 [get_ports VER1]
set_property PACKAGE_PIN A13 [get_ports VER2]
set_property IOSTANDARD LVCMOS25 [get_ports VER0]
set_property IOSTANDARD LVCMOS25 [get_ports VER1]
set_property IOSTANDARD LVCMOS25 [get_ports VER2]

#####################################################
#################### Temp Sensor#####################
#####################################################
set_property PACKAGE_PIN U14 [get_ports ONE_WIRE]
set_property IOSTANDARD LVCMOS33 [get_ports ONE_WIRE]

#####################################################
################ Clock Signals  (LVDS) ##############
#####################################################
set_property PACKAGE_PIN T14 [get_ports CLK_62M5_DMTD]
set_property IOSTANDARD LVCMOS33 [get_ports CLK_62M5_DMTD]

set_property PACKAGE_PIN E15 [get_ports FPGA_GCLK_P]
set_property PACKAGE_PIN D15 [get_ports FPGA_GCLK_N]
set_property IOSTANDARD LVDS_25 [get_ports FPGA_GCLK_P]
set_property IOSTANDARD LVDS_25 [get_ports FPGA_GCLK_N]

set_property PACKAGE_PIN B6 [get_ports MGTREFCLK1_P]
set_property PACKAGE_PIN B5 [get_ports MGTREFCLK1_N]

set_property PACKAGE_PIN F14 [get_ports OE_125M]
set_property IOSTANDARD LVCMOS25 [get_ports OE_125M]
set_property PACKAGE_PIN D6 [get_ports MGTREFCLK0_P]
set_property PACKAGE_PIN D5 [get_ports MGTREFCLK0_N]

#####################################################
#################### DAC Signals ####################
#####################################################
set_property PACKAGE_PIN U12 [get_ports DAC_LDAC_N]
set_property PACKAGE_PIN V14 [get_ports DAC_SCLK]
set_property PACKAGE_PIN V12 [get_ports DAC_SDO]
set_property PACKAGE_PIN V13 [get_ports DAC_SYNC_N]
set_property PACKAGE_PIN T13 [get_ports DAC_SDI]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_LDAC_N]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_SCLK]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_SDO]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_SYNC_N]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_SDI]

set_property PACKAGE_PIN N17 [get_ports DAC_DMTD_LDAC_N]
set_property PACKAGE_PIN K17 [get_ports DAC_DMTD_SCLK]
set_property PACKAGE_PIN N18 [get_ports DAC_DMTD_SDO]
set_property PACKAGE_PIN M17 [get_ports DAC_DMTD_SYNC_N]
set_property PACKAGE_PIN L18 [get_ports DAC_DMTD_SDI]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_DMTD_LDAC_N]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_DMTD_SCLK]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_DMTD_SDO]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_DMTD_SYNC_N]
set_property IOSTANDARD LVCMOS33 [get_ports DAC_DMTD_SDI]

#####################################################
#################### GTP Signals#####################
#####################################################
set_property PACKAGE_PIN U17 [get_ports {SFP_DISABLE_O[0]}]
set_property PACKAGE_PIN V17 [get_ports {SFP_FAULT_I[0]}]
set_property PACKAGE_PIN P18 [get_ports {SFP_LOS_I[0]}]
set_property PACKAGE_PIN R18 [get_ports {SFP_MOD_DEF0_I[0]}]
set_property PACKAGE_PIN T18 [get_ports {SFP_MOD_DEF1_IO[0]}]
set_property PACKAGE_PIN T17 [get_ports {SFP_MOD_DEF2_IO[0]}]
set_property PACKAGE_PIN A3 [get_ports {SFP_I_N[0]}]
set_property PACKAGE_PIN A4 [get_ports {SFP_I_P[0]}]
set_property PACKAGE_PIN F1 [get_ports {SFP_O_N[0]}]
set_property PACKAGE_PIN F2 [get_ports {SFP_O_P[0]}]

#set_property PACKAGE_PIN N16 [get_ports { SFP_RATE_SELECT[0] } ]
set_property PACKAGE_PIN M15 [get_ports {SFP_DISABLE_O[1]}]
set_property PACKAGE_PIN L14 [get_ports {SFP_FAULT_I[1]}]
set_property PACKAGE_PIN P15 [get_ports {SFP_LOS_I[1]}]
set_property PACKAGE_PIN T12 [get_ports {SFP_MOD_DEF0_I[1]}]
set_property PACKAGE_PIN N14 [get_ports {SFP_MOD_DEF1_IO[1]}]
set_property PACKAGE_PIN M14 [get_ports {SFP_MOD_DEF2_IO[1]}]
set_property PACKAGE_PIN G3 [get_ports {SFP_I_N[1]}]
set_property PACKAGE_PIN G4 [get_ports {SFP_I_P[1]}]
set_property PACKAGE_PIN B1 [get_ports {SFP_O_N[1]}]
set_property PACKAGE_PIN B2 [get_ports {SFP_O_P[1]}]
#set_property PACKAGE_PIN R13 [get_ports { SFP_RATE_SELECT[1] } ]

set_property IOSTANDARD LVCMOS33 [get_ports {SFP_DISABLE_O[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SFP_FAULT_I[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SFP_LOS_I[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SFP_MOD_DEF0_I[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SFP_MOD_DEF1_IO[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SFP_MOD_DEF2_IO[0]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SFP_RATE_SELECT[0]} ]
set_property IOSTANDARD LVCMOS33 [get_ports {SFP_DISABLE_O[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SFP_FAULT_I[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SFP_LOS_I[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SFP_MOD_DEF0_I[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SFP_MOD_DEF1_IO[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {SFP_MOD_DEF2_IO[1]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {SFP_RATE_SELECT[1]} ]

#####################################################
########################  LED  ######################
#####################################################
set_property PACKAGE_PIN H14 [get_ports {led_green_o[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {led_green_o[0]}]
set_property PACKAGE_PIN G14 [get_ports {led_red_o[0]}]
set_property IOSTANDARD LVCMOS25 [get_ports {led_red_o[0]}]
set_property PACKAGE_PIN H17 [get_ports {led_green_o[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {led_green_o[1]}]
set_property PACKAGE_PIN E18 [get_ports {led_red_o[1]}]
set_property IOSTANDARD LVCMOS25 [get_ports {led_red_o[1]}]

#####################################################
###################### UART #########################
#####################################################
set_property PACKAGE_PIN R16 [get_ports RX]
set_property PACKAGE_PIN R17 [get_ports TX]
set_property PACKAGE_PIN K15 [get_ports TEST]
#set_property PACKAGE_PIN T15 [get_ports CLK_25M_BAK]
set_property IOSTANDARD LVCMOS33 [get_ports RX]
set_property IOSTANDARD LVCMOS33 [get_ports TX]
set_property IOSTANDARD LVCMOS33 [get_ports TEST]
#set_property IOSTANDARD LVCMOS33 CLK_25M_BAK

#####################################################
###################### TIME #########################
#####################################################

set_property IOSTANDARD LVDS_25 [get_ports SYNC_DATA0_N]
set_property IOSTANDARD LVDS_25 [get_ports SYNC_DATA0_P]
set_property PACKAGE_PIN B9 [get_ports SYNC_DATA0_P]
set_property PACKAGE_PIN A9 [get_ports SYNC_DATA0_N]
set_property IOSTANDARD LVDS_25 [get_ports SYNC_DATA1_N]
set_property IOSTANDARD LVDS_25 [get_ports SYNC_DATA1_P]
set_property PACKAGE_PIN D8 [get_ports SYNC_DATA1_P]
set_property PACKAGE_PIN C8 [get_ports SYNC_DATA1_N]

#####################################################
################### Delay Chip#######################
#####################################################
set_property PACKAGE_PIN J18 [get_ports DELAY_EN]
set_property PACKAGE_PIN K18 [get_ports DELAY_SCLK]
set_property PACKAGE_PIN M16 [get_ports DELAY_SLOAD]
set_property PACKAGE_PIN J14 [get_ports DELAY_SDIN]
set_property IOSTANDARD LVCMOS33 [get_ports DELAY_EN]
set_property IOSTANDARD LVCMOS33 [get_ports DELAY_SCLK]
set_property IOSTANDARD LVCMOS33 [get_ports DELAY_SLOAD]
set_property IOSTANDARD LVCMOS33 [get_ports DELAY_SDIN]

#####################################################
###################### FLASH ########################
#####################################################
set_property PACKAGE_PIN L15 [get_ports QSPI_CS]
set_property IOSTANDARD LVCMOS33 [get_ports QSPI_CS]
set_property PACKAGE_PIN K16 [get_ports QSPI_DQ0]
set_property IOSTANDARD LVCMOS33 [get_ports QSPI_DQ0]
set_property PACKAGE_PIN L17 [get_ports QSPI_DQ1]
set_property IOSTANDARD LVCMOS33 [get_ports QSPI_DQ1]
#set_property PACKAGE_PIN J15 [get_ports QSPI_DQ2]
#set_property IOSTANDARD LVCMOS33 [get_ports QSPI_DQ2]
#set_property PACKAGE_PIN J16 [get_ports QSPI_DQ3]
#set_property IOSTANDARD LVCMOS33 [get_ports QSPI_DQ3]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 1 [current_design]
set_property CONFIG_MODE SPIx1 [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]

#####################################################
############### main PLL AD9516 #####################
#####################################################
set_property PACKAGE_PIN V9 [get_ports PLL_CS]
set_property PACKAGE_PIN U15 [get_ports PLL_REFSEL]
set_property PACKAGE_PIN U11 [get_ports PLL_RESET]
set_property PACKAGE_PIN V11 [get_ports PLL_SCLK]
set_property PACKAGE_PIN U10 [get_ports PLL_SDO]
set_property PACKAGE_PIN P16 [get_ports PLL_SYNC]
set_property PACKAGE_PIN U16 [get_ports PLL_LOCK]
set_property PACKAGE_PIN U9 [get_ports PLL_SDI]
set_property PACKAGE_PIN V16 [get_ports PLL_STAT]

set_property IOSTANDARD LVCMOS33 [get_ports PLL_CS]
set_property IOSTANDARD LVCMOS33 [get_ports PLL_REFSEL]
set_property IOSTANDARD LVCMOS33 [get_ports PLL_RESET]
set_property IOSTANDARD LVCMOS33 [get_ports PLL_SCLK]
set_property IOSTANDARD LVCMOS33 [get_ports PLL_SDO]
set_property IOSTANDARD LVCMOS33 [get_ports PLL_SYNC]
set_property IOSTANDARD LVCMOS33 [get_ports PLL_LOCK]
set_property IOSTANDARD LVCMOS33 [get_ports PLL_SDI]
set_property IOSTANDARD LVCMOS33 [get_ports PLL_STAT]

## NORMAL
#create_clock -period 100.000 -name clk_ext_p_i     -waveform {0.000 50.000} [get_ports clk_ext_p_i]
create_clock -period 8.000 -name CLK_62M5_DMTD -waveform {0.000 4.000} [get_ports CLK_62M5_DMTD]
create_clock -period 8.000 -name MGTREFCLK0_P -waveform {0.000 4.000} [get_ports MGTREFCLK0_P]
create_clock -period 8.000 -name MGTREFCLK1_P -waveform {0.000 4.000} [get_ports MGTREFCLK1_P]
create_clock -period 4.000 -name clk_serdes_i -waveform {0.000 2.000} [get_ports FPGA_GCLK_P]
create_clock -period 16.000 -name RXOUTCLK0 -waveform {0.000 8.000} [get_pins {cmp_xwrc_platform/gen_phy_artix7.cmp_gtp/U_GTP_INST/gen_GT_INTS[0].GT_INST/gtpe2_i/RXOUTCLK}]
create_clock -period 16.000 -name TXOUTCLK0 -waveform {0.000 8.000} [get_pins {cmp_xwrc_platform/gen_phy_artix7.cmp_gtp/U_GTP_INST/gen_GT_INTS[0].GT_INST/gtpe2_i/TXOUTCLK}]
create_clock -period 16.000 -name RXOUTCLK1 -waveform {0.000 8.000} [get_pins {cmp_xwrc_platform/gen_phy_artix7.cmp_gtp/U_GTP_INST/gen_GT_INTS[1].GT_INST/gtpe2_i/RXOUTCLK}]
create_clock -period 16.000 -name TXOUTCLK1 -waveform {0.000 8.000} [get_pins {cmp_xwrc_platform/gen_phy_artix7.cmp_gtp/U_GTP_INST/gen_GT_INTS[1].GT_INST/gtpe2_i/TXOUTCLK}]

set_property IOB TRUE [get_ports SYNC_DATA1_P]

set_clock_groups -name g1 -asynchronous -group CLK_62M5_DMTD -group MGTREFCLK0_P
set_clock_groups -name g2 -asynchronous -group CLK_62M5_DMTD -group MGTREFCLK1_P
set_clock_groups -name g3 -asynchronous -group CLK_62M5_DMTD -group RXOUTCLK0
set_clock_groups -name g4 -asynchronous -group CLK_62M5_DMTD -group RXOUTCLK1
set_clock_groups -name g5 -asynchronous -group CLK_62M5_DMTD -group TXOUTCLK0
set_clock_groups -name g6 -asynchronous -group CLK_62M5_DMTD -group TXOUTCLK1
#set_clock_groups -name g8 -asynchronous -group CLK_62M5_DMTD -group clk_serdes_i
set_clock_groups -name g9 -asynchronous -group CLK_62M5_DMTD -group clk_gtp_ref1_div2

#set_max_delay -from [get_clocks MGTREFCLK1_P] -to [get_clocks clk_serdes_i] 3.200
set_property ASYNC_REG true [get_cells {cmp_board_cute_a7/cmp_xwr_core/WRPC/U_SOFTPLL/U_Wrapped_Softpll/gen_ref_dmtds[0].DMTD_REF/gen_builtin.U_Sampler/gen_straight.clk_i_d0_reg}]
set_property ASYNC_REG true [get_cells {cmp_board_cute_a7/cmp_xwr_core/WRPC/U_SOFTPLL/U_Wrapped_Softpll/gen_ref_dmtds[0].DMTD_REF/gen_builtin.U_Sampler/gen_straight.clk_i_d3_reg}]
set_property ASYNC_REG true [get_cells {cmp_board_cute_a7/cmp_xwr_core/WRPC/U_SOFTPLL/U_Wrapped_Softpll/gen_ref_dmtds[2].DMTD_REF/gen_builtin.U_Sampler/gen_straight.clk_i_d0_reg}]
set_property ASYNC_REG true [get_cells {cmp_board_cute_a7/cmp_xwr_core/WRPC/U_SOFTPLL/U_Wrapped_Softpll/gen_ref_dmtds[2].DMTD_REF/gen_builtin.U_Sampler/gen_straight.clk_i_d3_reg}]
set_property ASYNC_REG true [get_cells {cmp_board_cute_a7/cmp_xwr_core/WRPC/U_SOFTPLL/U_Wrapped_Softpll/gen_ref_dmtds[1].DMTD_REF/gen_builtin.U_Sampler/gen_straight.clk_i_d0_reg}]
set_property ASYNC_REG true [get_cells {cmp_board_cute_a7/cmp_xwr_core/WRPC/U_SOFTPLL/U_Wrapped_Softpll/gen_ref_dmtds[1].DMTD_REF/gen_builtin.U_Sampler/gen_straight.clk_i_d3_reg}]
set_property ASYNC_REG true [get_cells {cmp_board_cute_a7/cmp_xwr_core/WRPC/U_SOFTPLL/U_Wrapped_Softpll/gen_ref_dmtds[3].DMTD_REF/gen_builtin.U_Sampler/gen_straight.clk_i_d0_reg}]
set_property ASYNC_REG true [get_cells {cmp_board_cute_a7/cmp_xwr_core/WRPC/U_SOFTPLL/U_Wrapped_Softpll/gen_ref_dmtds[3].DMTD_REF/gen_builtin.U_Sampler/gen_straight.clk_i_d3_reg}]

set_false_path -from [get_clocks -of_objects [get_pins cmp_xwrc_platform/gen_phy_artix7.cmp_gtp_ref1_dedicated_clk/ODIV2]] -to [get_clocks clk_serdes_i]

set_property LOC RAMB36_X0Y13 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram3_reg_0_7]
set_property LOC RAMB36_X0Y16 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram3_reg_0_6]
set_property LOC RAMB36_X0Y15 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram3_reg_0_5]
set_property LOC RAMB36_X0Y11 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram3_reg_0_4]
set_property LOC RAMB36_X0Y12 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram3_reg_0_3]
set_property LOC RAMB36_X1Y10 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram3_reg_0_2]
set_property LOC RAMB36_X1Y14 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram3_reg_0_1]
set_property LOC RAMB36_X0Y14 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram3_reg_0_0]
set_property LOC RAMB36_X0Y3 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram2_reg_0_7]
set_property LOC RAMB36_X1Y2 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram2_reg_0_6]
set_property LOC RAMB36_X0Y2 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram2_reg_0_5]
set_property LOC RAMB36_X1Y4 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram2_reg_0_4]
set_property LOC RAMB36_X1Y3 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram2_reg_0_3]
set_property LOC RAMB36_X0Y4 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram2_reg_0_2]
set_property LOC RAMB36_X0Y6 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram2_reg_0_1]
set_property LOC RAMB36_X0Y5 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram2_reg_0_0]
set_property LOC RAMB36_X1Y7 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram1_reg_0_7]
set_property LOC RAMB36_X0Y7 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram1_reg_0_6]
set_property LOC RAMB36_X2Y7 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram1_reg_0_5]
set_property LOC RAMB36_X0Y8 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram1_reg_0_4]
set_property LOC RAMB36_X0Y9 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram1_reg_0_3]
set_property LOC RAMB36_X1Y5 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram1_reg_0_2]
set_property LOC RAMB36_X1Y6 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram1_reg_0_1]
set_property LOC RAMB36_X2Y6 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram1_reg_0_0]
set_property LOC RAMB36_X2Y12 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram0_reg_0_7]
set_property LOC RAMB36_X2Y13 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram0_reg_0_6]
set_property LOC RAMB36_X1Y9 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram0_reg_0_5]
set_property LOC RAMB36_X2Y9 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram0_reg_0_4]
set_property LOC RAMB36_X2Y10 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram0_reg_0_3]
set_property LOC RAMB36_X2Y8 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram0_reg_0_2]
set_property LOC RAMB36_X1Y8 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram0_reg_0_1]
set_property LOC RAMB36_X2Y11 [get_cells cmp_board_cute_a7/cmp_xwr_core/WRPC/DPRAM/U_DPRAM/gen_splitram.U_RAM_SPLIT/ram0_reg_0_0]
