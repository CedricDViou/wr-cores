------------------------------------------------------------------------
-- Title      : Forward Error Correction
-- Project    : WhiteRabbit Node
-------------------------------------------------------------------------------
-- File       : wr_fec_en.vhd
-- Author     : Maciej Lipinski
-- Company    : CERN BE-Co-HT
-- Created    : 2011-04-12
-- Last update: 2011-07-27
-- Platform   : FPGA-generic
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: This is just a top entity of the FEC encoder.
-- it puts togother FEC engine and FEC interface. 
-- We separate these two to have some flexibility
-------------------------------------------------------------------------------
--
-- Copyright (c) 2011 Maciej Lipinski / CERN
--
-- This source file is free software; you can redistribute it   
-- and/or modify it under the terms of the GNU Lesser General   
-- Public License as published by the Free Software Foundation; 
-- either version 2.1 of the License, or (at your option) any   
-- later version.                                               
--
-- This source is distributed in the hope that it will be       
-- useful, but WITHOUT ANY WARRANTY; without even the implied   
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
-- PURPOSE.  See the GNU Lesser General Public License for more 
-- details.                                                     
--
-- You should have received a copy of the GNU Lesser General    
-- Public License along with this source; if not, download it   
-- from http://www.gnu.org/licenses/lgpl-2.1.html
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author   Description
-- 2011-04-0 2 1.0      mlipinsk Created
-- 2011-07-27  1.0      mlipinsk debugged
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.wr_fec_pkg.all;

entity wr_fec_en is
  port (
     clk_i   : in std_logic;
     rst_n_i : in std_logic;
    
     ---------------------------------------------------------------------------------------
     -- talk with outside word
     ---------------------------------------------------------------------------------------
     -- 32 bits wide wishbone slave RX input
     wbs_dat_i	 : in  std_logic_vector(wishbone_data_width_in-1 downto 0);
     wbs_adr_i	 : in  std_logic_vector(wishbone_address_width_in-1 downto 0);
     wbs_sel_i	 : in  std_logic_vector((wishbone_data_width_in/8)-1 downto 0);
     wbs_cyc_i	 : in  std_logic;
     wbs_stb_i	 : in  std_logic;
     wbs_we_i	  : in  std_logic;
     wbs_err_o	 : out std_logic;
     wbs_stall_o: out std_logic;
     wbs_ack_o	 : out std_logic;
    
     -- 32 bits wide wishbone Master TX input
      
     wbm_dat_o 	: out std_logic_vector(wishbone_data_width_out-1 downto 0);
     wbm_adr_o	 : out std_logic_vector(wishbone_address_width_out-1 downto 0);
     wbm_sel_o	 : out std_logic_vector((wishbone_data_width_out/8)-1 downto 0);
     wbm_cyc_o	 : out std_logic;
     wbm_stb_o	 : out std_logic;
     wbm_we_o	  : out std_logic;
     wbm_err_i	 : in std_logic;
     wbm_stall_i: in  std_logic;
     wbm_ack_i	 : in  std_logic
  );
end wr_fec_en;

architecture rtl of wr_fec_en is

 signal if_data_in        : std_logic_vector(c_fec_engine_data_width  - 1 downto 0);
 signal if_byte_sel_2_fec : std_logic_vector(c_fec_engine_Byte_sel_num  - 1 downto 0);
 signal if_data_out       : std_logic_vector(c_fec_engine_data_width  - 1 downto 0);
 signal if_byte_sel       : std_logic_vector(c_fec_engine_Byte_sel_num  - 1 downto 0);
 signal if_msg_size       : std_logic_vector(c_fec_msg_size_MAX_Bytes_width     - 1 downto 0);
 signal if_FEC_ID_ena     : std_logic;
 signal if_FEC_ID         : std_logic_vector(c_fec_FEC_header_FEC_ID_bits     - 1 downto 0);
 signal if_in_ctrl_in        : std_logic_vector(2 downto 0);
 signal if_in_settngs_ena : std_logic;
 signal if_in_etherType   : std_logic_vector(15 downto 0);
 signal if_in_ctrl_out        : std_logic;
 signal if_busy           : std_logic;
 signal if_out_ctrl_in       : std_logic;
 signal if_out_start_frame   : std_logic;
 signal if_out_frame_cyc   : std_logic;
 signal if_out_end_of_frame : std_logic;
 signal if_out_end_of_fec   : std_logic;
 signal if_out_ctrl_out       : std_logic;
 signal vlan_taggged_frame  : std_logic;
 signal if_out_MSG_num    : std_logic_vector(c_fec_out_MSG_num_MAX_width - 1 downto 0) ;    


begin

 FEC_IF: wr_fec_en_interface 
  port map(
     clk_i                 => clk_i,
     rst_n_i               => rst_n_i,
     ---------------------------------------------------------------------------------------
     -- talk with outside word
     ---------------------------------------------------------------------------------------
     -- 32 bits wide wishbone slave RX input
     wbs_dat_i	            => wbs_dat_i,
     wbs_adr_i	            => wbs_adr_i,
     wbs_sel_i             => wbs_sel_i,
     wbs_cyc_i             => wbs_cyc_i,
     wbs_stb_i	            => wbs_stb_i,
     wbs_we_i	             => wbs_we_i,
     wbs_err_o             => wbs_err_o,
     wbs_stall_o           => wbs_stall_o,
     wbs_ack_o	            => wbs_ack_o,
    
     -- 32 bits wide wishbone Master TX input
     wbm_dat_o 	           => wbm_dat_o,
     wbm_adr_o	            => wbm_adr_o,
     wbm_sel_o	            => wbm_sel_o,
     wbm_cyc_o	            => wbm_cyc_o,
     wbm_stb_o	            => wbm_stb_o,
     wbm_we_o	             => wbm_we_o,
     wbm_err_i	            => wbm_err_i,
     wbm_stall_i           => wbm_stall_i,
     wbm_ack_i	            => wbm_ack_i,
     
     ---------------------------------------------------------------------------------------
     -- talk with FEC ENGINE
     ---------------------------------------------------------------------------------------
     if_data_o             => if_data_in,
     if_byte_sel_o         => if_byte_sel_2_fec,
     if_data_i             => if_data_out,
     if_byte_sel_i         => if_byte_sel,
     if_msg_size_o         => if_msg_size,
     if_FEC_ID_ena_o       => if_FEC_ID_ena,
     if_FEC_ID_o           => if_FEC_ID,
     if_in_ctrl_o          => if_in_ctrl_in,
     if_in_settngs_ena_o   => if_in_settngs_ena,
     if_in_etherType_o     => if_in_etherType,
     if_in_ctrl_i          => if_in_ctrl_out,
     if_busy_i             => if_busy,
     if_out_ctrl_i         => if_out_ctrl_in,
     if_out_frame_cyc_i    => if_out_frame_cyc,
     if_out_start_frame_i  => if_out_start_frame,
     if_out_end_of_frame_i => if_out_end_of_frame,
     if_out_end_of_fec_i   => if_out_end_of_fec,
     if_out_ctrl_o         => if_out_ctrl_out,
     --vlan_taggged_frame_o  => vlan_taggged_frame,
     if_out_MSG_num_o      => if_out_MSG_num
  );

FEC_ENGINE :  wr_fec_en_engine
  port map(
     clk_i                 => clk_i,
     rst_n_i               => rst_n_i,
     if_data_in            => if_data_in,
     if_byte_sel_i         => if_byte_sel_2_fec,
     if_data_o             => if_data_out,
     if_byte_sel_o         => if_byte_sel,
     if_msg_size_i         => if_msg_size,
     if_FEC_ID_ena_i       => if_FEC_ID_ena,
     if_FEC_ID_i           => if_FEC_ID,
     if_in_ctrl_i          => if_in_ctrl_in,
     if_in_settngs_ena_i   => if_in_settngs_ena,
     if_in_etherType_i     => if_in_etherType,      
     if_in_ctrl_o          => if_in_ctrl_out,
     if_busy_o             => if_busy,
     if_out_ctrl_o         => if_out_ctrl_in,
     if_out_frame_cyc_o    => if_out_frame_cyc,
     if_out_start_frame_o  => if_out_start_frame,
     if_out_end_of_frame_o => if_out_end_of_frame,
     if_out_end_of_fec_o   => if_out_end_of_fec,
     if_out_ctrl_i         => if_out_ctrl_out,
     --vlan_taggged_frame_i  => vlan_taggged_frame,
     if_out_MSG_num_i      => if_out_MSG_num
  );
 
 
 
end rtl;



