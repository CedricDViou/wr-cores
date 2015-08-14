-------------------------------------------------------------------------------
-- Title      : Port monitoring system
-- Project    : White Rabbit 
-------------------------------------------------------------------------------
-- File       : xwr_pstats_pkg.vhd
-- Author     : Cesar Prados
-- Company    : GSI
-- Created    : 2015-08-11
-- Platform   : FPGA-generic
-- Standard   : VHDL
-------------------------------------------------------------------------------
-- Description:
-- Simply counters in tow layers organized. L1 is the basic counter and L2,
-- counts the overflow of L1. One bit to sign overflow of counter L1 and L2.
-------------------------------------------------------------------------------
-- Copyright (c) 2013 Cesar Prados c.prados@gsi.de / GSI
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author          Description
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

library work;
use work.wishbone_pkg.all;
use work.wr_pstats_pkg.all;

entity port_cntr is
  port(
    clk_i       : in  std_logic;
    rstn_i      : in  std_logic;
    cnt_eo_i    : in  std_logic;
    cnt_ovf_o   : out std_logic;
    cnt_o       : out t_cnt);
end port_cntr;

architecture rtl of port_cntr is

  signal s_L1_cnt : unsigned(c_L1_cnt_density - 1 downto 0);
  signal s_L2_cnt : unsigned(c_L2_cnt_density - 1 downto 0);
  signal s_L1_ovf : std_logic;

begin

  L1_CNT  : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rstn_i = '0' then
        s_L1_cnt  <= (others => '0');
      else
        if cnt_eo_i = '1' then
          s_L1_cnt <= s_L1_cnt + 1; 
        else
          s_L1_cnt <= s_L1_cnt; 
        end if;
      end if;
    end if;
  end process;

  s_L1_ovf <= '1' when s_L1_cnt = (2**c_L1_cnt_density - 1) else '0';   

  L2_CNT  : process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rstn_i = '0' then
        s_L2_cnt  <= (others => '0');
      else
        if s_L1_ovf = '1' then
          s_L2_cnt <= s_L2_cnt + 1; 
        else
          s_L2_cnt <= s_L2_cnt; 
        end if;
      end if;
    end if;
  end process;

  cnt_ovf_o <= '1' when s_L2_cnt = (2**c_L2_cnt_density - 1) else '0';

  cnt_o.L1_cnt <= std_logic_vector(s_L1_cnt); 
  cnt_o.L2_cnt <= std_logic_vector(s_L2_cnt);

end rtl;
