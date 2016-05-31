---------------------------------------------------------------------------------------
-- Title          : Wishbone slave core for WR Transmission control and debug
---------------------------------------------------------------------------------------
-- File           : wr_transmission_wbgen2_pkg.vhd
-- Author         : auto-generated by wbgen2 from wr_transmission_wb.wb
-- Created        : Tue May 31 08:48:29 2016
-- Standard       : VHDL'87
---------------------------------------------------------------------------------------
-- THIS FILE WAS GENERATED BY wbgen2 FROM SOURCE FILE wr_transmission_wb.wb
-- DO NOT HAND-EDIT UNLESS IT'S ABSOLUTELY NECESSARY!
---------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package wr_transmission_wbgen2_pkg is
  
  
  -- Input registers (user design -> WB slave)
  
  type t_wr_transmission_in_registers is record
    rx_stat_rx_loss_cnt_i                    : std_logic_vector(31 downto 0);
    dbg_data_i                               : std_logic_vector(31 downto 0);
    end record;
  
  constant c_wr_transmission_in_registers_init_value: t_wr_transmission_in_registers := (
    rx_stat_rx_loss_cnt_i => (others => '0'),
    dbg_data_i => (others => '0')
    );
    
    -- Output registers (WB slave -> user design)
    
    type t_wr_transmission_out_registers is record
      rxctrl_rst_cnt_o                         : std_logic;
      rxctrl_rx_rst_latency_stats_o            : std_logic;
      dbg_ctrl_mux_o                           : std_logic;
      dbg_ctrl_start_byte_o                    : std_logic_vector(7 downto 0);
      end record;
    
    constant c_wr_transmission_out_registers_init_value: t_wr_transmission_out_registers := (
      rxctrl_rst_cnt_o => '0',
      rxctrl_rx_rst_latency_stats_o => '0',
      dbg_ctrl_mux_o => '0',
      dbg_ctrl_start_byte_o => (others => '0')
      );
    function "or" (left, right: t_wr_transmission_in_registers) return t_wr_transmission_in_registers;
    function f_x_to_zero (x:std_logic) return std_logic;
    function f_x_to_zero (x:std_logic_vector) return std_logic_vector;
end package;

package body wr_transmission_wbgen2_pkg is
function f_x_to_zero (x:std_logic) return std_logic is
begin
if x = '1' then
return '1';
else
return '0';
end if;
end function;
function f_x_to_zero (x:std_logic_vector) return std_logic_vector is
variable tmp: std_logic_vector(x'length-1 downto 0);
begin
for i in 0 to x'length-1 loop
if(x(i) = 'X' or x(i) = 'U') then
tmp(i):= '0';
else
tmp(i):=x(i);
end if; 
end loop; 
return tmp;
end function;
function "or" (left, right: t_wr_transmission_in_registers) return t_wr_transmission_in_registers is
variable tmp: t_wr_transmission_in_registers;
begin
tmp.rx_stat_rx_loss_cnt_i := f_x_to_zero(left.rx_stat_rx_loss_cnt_i) or f_x_to_zero(right.rx_stat_rx_loss_cnt_i);
tmp.dbg_data_i := f_x_to_zero(left.dbg_data_i) or f_x_to_zero(right.dbg_data_i);
return tmp;
end function;
end package body;
