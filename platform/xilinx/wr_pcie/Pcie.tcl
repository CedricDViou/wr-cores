#-----------------------------------------------------------------------------
# Title      : Pcie.tcl
# Project    : White Rabbit SPEC7
#-----------------------------------------------------------------------------
# File       : Pcie.tcl
# Author     : Pascal Bos, Peter Jansweijer
# Company    : Nikhef
# Created    : 2020-02-24
# Last update: 2020-02-24
# Platform   : FPGA-generic
# Standard   : TCL
#-----------------------------------------------------------------------------
# Description: Script to generate PCIe endpoint for Xilinx 7-series FPGA
#-----------------------------------------------------------------------------
#
# Copyright (c) 2020 Nikhef
#
# This source file is free software; you can redistribute it   
# and/or modify it under the terms of the GNU Lesser General   
# Public License as published by the Free Software Foundation; 
# either version 2.1 of the License, or (at your option) any   
# later version.                                               
#
# This source is distributed in the hope that it will be       
# useful, but WITHOUT ANY WARRANTY; without even the implied   
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
# PURPOSE.  See the GNU Lesser General Public License for more 
# details.                                                     
#
# You should have received a copy of the GNU Lesser General    
# Public License along with this source; if not, download it   
# from http://www.gnu.org/licenses/lgpl-2.1.html
# 
#
#-----------------------------------------------------------------------------
# Revisions  :
# Date        Version  Author      Description
# 2020-02-24  0.1      Pascal Bos  Initial release based on Vivado block design generator
#-----------------------------------------------------------------------------


################################################################
# This is a generated script based on design: Pcie
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source Pcie_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part $device
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name Pcie

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:xdma:4.1\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################



# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set M00_AXI_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M00_AXI_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {62500000} \
   CONFIG.HAS_REGION {0} \
   CONFIG.PROTOCOL {AXI4} \
   ] $M00_AXI_0

  set pcie_mgt_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie_mgt_0 ]


  # Create ports
  set aclk1_0 [ create_bd_port -dir I -type clk -freq_hz 62500000 aclk1_0 ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI_0} \
 ] $aclk1_0
  set pcie_clk [ create_bd_port -dir I -type clk pcie_clk ]
  set pcie_rst_n [ create_bd_port -dir I -type rst pcie_rst_n ]
  set user_lnk_up_0 [ create_bd_port -dir O user_lnk_up_0 ]
  set usr_irq_ack_0 [ create_bd_port -dir O -from 0 -to 0 usr_irq_ack_0 ]
  set usr_irq_req_0 [ create_bd_port -dir I -from 0 -to 0 usr_irq_req_0 ]

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_CLKS {2} \
   CONFIG.NUM_SI {1} \
 ] $smartconnect_0

  # Create instance: xdma_0, and set properties
  set xdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xdma:4.1 xdma_0 ]
  set_property -dict [ list \
   CONFIG.PF0_DEVICE_ID_mqdma {9022} \
   CONFIG.PF2_DEVICE_ID_mqdma {9022} \
   CONFIG.PF3_DEVICE_ID_mqdma {9022} \
   CONFIG.axilite_master_en {true} \
   CONFIG.axilite_master_scale {Kilobytes} \
   CONFIG.axilite_master_size {256} \
   CONFIG.axisten_freq {125} \
   CONFIG.cfg_mgmt_if {false} \
   CONFIG.pcie_extended_tag {false} \
   CONFIG.pf0_device_id {7022} \
   CONFIG.pf0_link_status_slot_clock_config {false} \
   CONFIG.pf0_msi_enabled {false} \
   CONFIG.pf0_msix_cap_pba_bir {BAR_1} \
   CONFIG.pf0_msix_cap_table_bir {BAR_1} \
   CONFIG.pl_link_cap_max_link_speed {5.0_GT/s} \
   CONFIG.pl_link_cap_max_link_width {X2} \
   CONFIG.plltype {QPLL1} \
   CONFIG.xdma_axi_intf_mm {AXI_Stream} \
 ] $xdma_0

  # Create interface connections
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_ports M00_AXI_0] [get_bd_intf_pins smartconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net xdma_0_M_AXIS_H2C_0 [get_bd_intf_pins xdma_0/M_AXIS_H2C_0] [get_bd_intf_pins xdma_0/S_AXIS_C2H_0]
  connect_bd_intf_net -intf_net xdma_0_M_AXI_LITE [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins xdma_0/M_AXI_LITE]
  connect_bd_intf_net -intf_net xdma_0_pcie_mgt [get_bd_intf_ports pcie_mgt_0] [get_bd_intf_pins xdma_0/pcie_mgt]

  # Create port connections
  connect_bd_net -net aclk1_0_1 [get_bd_ports aclk1_0] [get_bd_pins smartconnect_0/aclk1]
  connect_bd_net -net sys_clk_0_1 [get_bd_ports pcie_clk] [get_bd_pins xdma_0/sys_clk]
  connect_bd_net -net sys_rst_n_0_1 [get_bd_ports pcie_rst_n] [get_bd_pins xdma_0/sys_rst_n]
  connect_bd_net -net usr_irq_req_0_1 [get_bd_ports usr_irq_req_0] [get_bd_pins xdma_0/usr_irq_req]
  connect_bd_net -net xdma_0_axi_aclk [get_bd_pins smartconnect_0/aclk] [get_bd_pins xdma_0/axi_aclk]
  connect_bd_net -net xdma_0_axi_aresetn [get_bd_pins smartconnect_0/aresetn] [get_bd_pins xdma_0/axi_aresetn]
  connect_bd_net -net xdma_0_user_lnk_up [get_bd_ports user_lnk_up_0] [get_bd_pins xdma_0/user_lnk_up]
  connect_bd_net -net xdma_0_usr_irq_ack [get_bd_ports usr_irq_ack_0] [get_bd_pins xdma_0/usr_irq_ack]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces xdma_0/M_AXI_LITE] [get_bd_addr_segs M00_AXI_0/Reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


