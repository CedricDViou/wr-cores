-------------------------------------------------------------------------------
-- Title      : GTX Reset Module
-- Project    : White Rabbit Switch
-------------------------------------------------------------------------------
-- File       : gtp_bitslide.vhd
-- Author     : Tomasz Wlostowski
-- Company    : CERN BE-CO-HT
-- Platform   : FPGA-generic
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Module implements a manual bitslide alignment state machine and
-- provides the obtained bitslide value to the MAC.
-------------------------------------------------------------------------------
--
-- Copyright (c) 2011 CERN
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity gtx_reset is
  
  port (
    clk_tx_i : in std_logic;
    rst_i  : in std_logic;

    txpll_lockdet_i : in  std_logic;
    gtx_test_o      : out std_logic_vector(12 downto 0)
    );

end gtx_reset;


architecture behavioral of gtx_reset is
  
  type t_state is (IDLE, PAUSE, FIRST_RST, PAUSE2, SECOND_RST, DONE);

  signal state   : t_state;
  signal counter : unsigned(15 downto 0);
  
begin  -- behavioral

  process(clk_tx_i)
  begin
    if rising_edge(clk_tx_i) then
      if rst_i = '1' then
        state   <= IDLE;
        counter <= (others => '0');
                  
      else
        if(txpll_lockdet_i = '0') then
          state <= IDLE;
        else
          case state is
            when IDLE =>
              counter    <= (others => '0');
              gtx_test_o <= "1000000000000";
              
              if(txpll_lockdet_i = '1') then
                state <= PAUSE;
              end if;

            when PAUSE =>
              counter    <= counter + 1;
              gtx_test_o <= "1000000000000";
              if(counter = 1024) then
                state <= FIRST_RST;
              end if;
              
            when FIRST_RST =>
              counter    <= counter + 1;
              gtx_test_o <= "1000000000010";
              if(counter = 1024 + 256) then
                state <= PAUSE2;
              end if;
            when PAUSE2=>
              counter    <= counter + 1;
              gtx_test_o <= "1000000000000";
              if(counter = 1024 + 2*256) then
                state <= SECOND_RST;
              end if;
            when SECOND_RST =>
              counter    <= counter + 1;
              gtx_test_o <= "1000000000010";
              if(counter = 1024 + 3*256) then
                state <= DONE;
              end if;

            when DONE =>
              gtx_test_o <= "1000000000000";
              
          end case;
        end if;
      end if;
    end if;
  end process;



end behavioral;
