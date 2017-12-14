------------------------------------------------------------------------------
-- Title      : Deterministic Xilinx GTP wrapper - TX phase alignment
-- Project    : White Rabbit Switch
-------------------------------------------------------------------------------
-- File       : gtp_phase_align.vhd
-- Author     : Tomasz Wlostowski
-- Company    : CERN BE-CO-HT
-- Created    : 2010-11-18
-- Last update: 2011-09-12
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: TX phase alignment state machine, as recommended by Xilinx.
-------------------------------------------------------------------------------
--
-- Original EASE design (c) 2010 NIKHEF / Peter Jansweijer and Henk Peek
-- VHDL port (c) 2010 CERN
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
-- 2010-11-18  0.4      twlostow  Ported EASE design to VHDL 
-- 2011-02-07  0.5      twlostow  Verified on Spartan6 GTP
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gtp_phase_align is
  generic
    (g_simulation : integer);
  
  port (
    gtp_rst_i    : in std_logic;
    gtp_tx_clk_i : in std_logic;

    gtp_tx_en_pma_phase_align_o : out std_logic;
    gtp_tx_pma_set_phase_o      : out std_logic;

    align_en_i   : in  std_logic;
    align_done_o : out std_logic
    );

end gtp_phase_align;

architecture behavioral of gtp_phase_align is

  constant c_wait_en_phase_align  : integer := 32;
  constant c_wait_set_phase_align : integer := 512;
  constant c_phase_align_duration : integer := 8192;


  type t_align_state is (S_ALIGN_IDLE, S_ALIGN_PAUSE, S_ALIGN_WAIT, S_ALIGN_SET_PHASE, S_ALIGN_DONE);

  signal counter : unsigned(13 downto 0);
  signal state   : t_align_state;

  
begin  -- behavioral

  p_align : process(gtp_tx_clk_i, gtp_rst_i)
  begin
    if rising_edge(gtp_tx_clk_i) then
      if gtp_rst_i = '1' then
        gtp_tx_en_pma_phase_align_o <= '0';
        gtp_tx_pma_set_phase_o      <= '0';
        counter                     <= (others => '0');
        align_done_o                <= '0';
        state                       <= S_ALIGN_IDLE;
      else
        if(align_en_i = '0') then
          state <= S_ALIGN_IDLE;
        else

          case (state) is
            when S_ALIGN_IDLE =>
              gtp_tx_en_pma_phase_align_o <= '0';
              gtp_tx_pma_set_phase_o      <= '0';
              counter                     <= (others => '0');
              align_done_o                <= '0';

              if(align_en_i = '1') then
                state <= S_ALIGN_PAUSE;
              end if;

            when S_ALIGN_PAUSE =>
              counter <= counter + 1;
              if(counter = to_unsigned(c_wait_en_phase_align, counter'length)) then
                state <= S_ALIGN_WAIT;
              end if;

            when S_ALIGN_WAIT =>
              gtp_tx_en_pma_phase_align_o <= '1';
              counter                     <= counter + 1;
              if(counter = to_unsigned(c_wait_en_phase_align + c_wait_set_phase_align, counter'length)) then
                state <= S_ALIGN_SET_PHASE;
              end if;

            when S_ALIGN_SET_PHASE =>
              counter                <= counter +1;
              gtp_tx_pma_set_phase_o <= '1';

              if(counter = to_unsigned(c_wait_en_phase_align + c_wait_set_phase_align + c_phase_align_duration, counter'length)) then
                state <= S_ALIGN_DONE;
              end if;

            when S_ALIGN_DONE =>
              gtp_tx_pma_set_phase_o <= '0';
              counter                <= (others => '0');
              align_done_o           <= '1';
            when others => null;
          end case;
        end if;
      end if;
    end if;
  end process;
  

end behavioral;

