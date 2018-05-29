-------------------------------------------------------------------------------
-- Title      : Programmable Statistics Counters (RMON)
-- Project    : White Rabbit MAC/Endpoint
-------------------------------------------------------------------------------
-- File       : ep_rmon_counters.vhd
-- Author     : Tomasz Włostowski
-- Company    : CERN BE-CO-HT
-- Created    : 2010-11-18
-- Last update: 2011-10-18
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Module implements a configurable counter block for gathering
-- RMON statistics. The block is RAM-based to reduce the FPGA footprint and hence
-- has some limitations on the maximum frequency of the incoming triggers.
-------------------------------------------------------------------------------
--
-- Copyright (c) 2009-2011 CERN / BE-CO-HT
--
-- Copyright and related rights are licensed under the Solderpad Hardware
-- License, Version 0.51 (the “License”) (which enables you, at your option,
-- to treat this file as licensed under the Apache License 2.0); you may not
-- use this file except in compliance with the License. You may obtain a copy
-- of the License at http://solderpad.org/licenses/SHL-0.51.
-- Unless required by applicable law or agreed to in writing, software,
-- hardware and materials distributed under this License is distributed on an
-- “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
-- or implied. See the License for the specific language governing permissions
-- and limitations under the License.
--
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author    Description
-- 2010-11-18  0.4      twlostow  Created (separeted from wrsw_endpoint)
-- 2011-02-07  0.5      twlostow  Tested on Spartan6 GTP
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.endpoint_private_pkg.all;

entity ep_rmon_counters is
  
  generic (
    g_num_counters   : integer;
    g_ram_addr_width : integer);

  port (
    clk_sys_i : in std_logic;
    rst_n_i: in std_logic;

    cntr_rst_i   : in std_logic;

    cntr_pulse_i : in std_logic_vector(g_num_counters-1 downto 0);

    ram_addr_o : out std_logic_vector(g_ram_addr_width-1 downto 0);
    ram_data_i : in  std_logic_vector(31 downto 0);
    ram_data_o : out std_logic_vector(31 downto 0);
    ram_wr_o   : out std_logic;

    cntr_overflow_o : out std_logic
    );


end ep_rmon_counters;

architecture behavioral of ep_rmon_counters is

  constant c_subcounter_size : integer := 5;

  type t_subcounter_array is array(0 to g_num_counters-1) of unsigned(c_subcounter_size-1 downto 0);
  type t_mem_state is (MEM_READ, MEM_WRITE_INC);

  signal sub_cnt : t_subcounter_array;

  signal pulse_sync_d0, pulse_sync_d1, pulse_det : std_logic_vector(g_num_counters-1 downto 0);
  signal sub_rst                                 : std_logic_vector(g_num_counters-1 downto 0);

  signal cur_subcnt : unsigned(4 downto 0);
  signal mem_toggle : std_logic;
  signal mem_reset  : std_logic;
  signal state      : t_mem_state;

  signal ram_addr : unsigned(g_ram_addr_width-1 downto 0);

  signal reset_int : std_logic;
  
  
begin  -- behavioral

  reset_int <= '1' when (rst_n_i = '0' or cntr_rst_i = '1') else '0';
  
  edge_detect : process(clk_sys_i, reset_int)
  begin
    if rising_edge(clk_sys_i) then

      if reset_int = '1' then
        pulse_det     <= (others => '0');
        pulse_sync_d1 <= (others => '0');
        pulse_sync_d0 <= (others => '0');
      else
        pulse_sync_d0 <= cntr_pulse_i;
        pulse_sync_d1 <= pulse_sync_d0;
        pulse_det     <= (not pulse_sync_d1)and pulse_sync_d0;
      end if;
    end if;
  end process;

  count : process(clk_sys_i, reset_int)
  begin
    if rising_edge(clk_sys_i) then
      if reset_int = '1' then
        for i in 0 to g_num_counters-1 loop
          sub_cnt (i) <= (others => '0');
        end loop;  -- i 
      else
        for i in 0 to g_num_counters-1 loop
          if(sub_rst(i) = '1' and pulse_det(i) = '0' and state = MEM_WRITE_INC) then
            sub_cnt(i) <= to_unsigned(0, c_subcounter_size);
          elsif(sub_rst(i) = '1' and pulse_det(i) = '1' and state = MEM_WRITE_INC) then
            sub_cnt(i) <= to_unsigned(1, c_subcounter_size);
          elsif (pulse_det(i) = '1') then
            sub_cnt(i) <= sub_cnt(i) + 1;
          end if;
        end loop;  -- i 
      end if;
    end if;
  end process;

  update_ram : process(clk_sys_i, reset_int)
  begin
    if rising_edge(clk_sys_i) then
      if reset_int = '1' then
        cur_subcnt                     <= (others => '0');
        ram_addr                       <= (others => '0');
        mem_reset                      <= '1';
        state                          <= MEM_WRITE_INC;
        sub_rst(0)                     <= '1';
        sub_rst(sub_rst'high downto 1) <= (others => '0');
      else

        case state is
          when MEM_READ =>
            state <= MEM_WRITE_INC;
          when MEM_WRITE_INC =>
            if(cur_subcnt = to_unsigned(g_num_counters-1, cur_subcnt'length)) then
              cur_subcnt                     <= (others => '0');
              ram_addr                       <= (others => '0');
              sub_rst(0)                     <= '1';
              sub_rst(sub_rst'high downto 1) <= (others => '0');
              mem_reset <= '0';
            else
              sub_rst <= sub_rst(sub_rst'high-1 downto 0) & '0';
              cur_subcnt <= cur_subcnt + 1;
              ram_addr   <= ram_addr + 1;
            end if;
            state <= MEM_READ;
          when others => null;
        end case;
      end if;
    end if;
  end process;


  ram_addr_o <= std_logic_vector(ram_addr);
  ram_wr_o   <= '1'         when (state = MEM_WRITE_INC) else '0';
  ram_data_o <= x"00000000" when mem_reset = '1'         else std_logic_vector(unsigned(ram_data_i) + unsigned(sub_cnt(to_integer(cur_subcnt))));


end behavioral;
